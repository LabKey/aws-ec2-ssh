#!/bin/bash -e

# define bold and normal text
bold=$(tput bold)
normal=$(tput sgr0)

REMOVEMFA="false"
echo -e " -----------------------------------------------------------------------------------------\n"
echo-e  " ----- This script will disable MFA authentication for SSH -----\n "
echo -e " -----------------------------------------------------------------------------------------\n"
#test to see if its already configured....
if grep "AuthenticationMethods publickey,keyboard-interactive" /etc/ssh/sshd_config
    then
    echo -e " --- ${bold} MFA Appears to be configured! ${normal}--- \n"
    echo -e " --- ${bold} Do you want to disable MFA for SSH? ${normal} (Yes or No?) no exits this script ---\n"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) echo -e " ---${bold} Disabling MFA on SSH ${normal}----\n" && REMOVEMFA="true" ; break;;
            No ) echo -e " ---${bold} exiting - no action taken ${normal} ----\n" && exit;;
        esac
    done
   else
        echo -e " --- MFA does not appear to be configured! exiting no action taken--- \n"
        exit
   fi

# do the work to disable....
if [ "${REMOVEMFA}" == "true" ]; then

   sed -i '/auth       required     pam_google_authenticator.so nullok/d' /etc/pam.d/sshd
   sed -e '/#auth       substack     password-auth/s/^#//' -i /etc/pam.d/sshd
   sed -e '/#ChallengeResponseAuthentication no/s/^#//' -i /etc/ssh/sshd_config
   sed -e '/ChallengeResponseAuthentication yes/ s/^#*/#/' -i /etc/ssh/sshd_config
   sed -e '/AuthenticationMethods publickey,keyboard-interactive/d' -i /etc/ssh/sshd_config
   # fix up ec2-user - rename instead of remove
   if [ -f "/home/ec2-user/.google_authenticator" ]; then
      sudo mv /home/ec2-user/.google_authenticator /home/ec2-user/.bak.google_authenticator
      fi
   # disable init-profile script
   if [ -f "/etc/profile.d/init_google_authenticator.sh" ]; then
       sudo mv /etc/profile.d/init_google_authenticator.sh /etc/profile.d/init_google_authenticator.sh.bak
      fi
   #restart SSHD service for changes to take affect
   sudo service sshd restart
  fi



