#!/bin/bash -e

bold=$(tput bold)
normal=$(tput sgr0)

ENABLEMFA="false"

if (( EUID != 0 )); then
    echo -e "----- Please run as root! -----\n"
    exit
  fi

echo " -----------------------------------------------------------------------------------------"
echo " ----- This script will Enable MFA authentication for SSH ----- "
echo " ----- Please see this AWS blog post for more information about this capability -----"
echo " ----- https://aws.amazon.com/blogs/startups/securing-ssh-to-amazon-ec2-linux-hosts/ -----"
echo " -----------------------------------------------------------------------------------------"

if ! grep "AuthenticationMethods publickey,keyboard-interactive" /etc/ssh/sshd_config
    then
    echo " --- ${bold} Checking to see if MFA configured... ${normal}--- "
    echo " --- ${bold} MFA is not configured! ${normal}--- "
    echo " --- ${bold} Do you want to Enable MFA for SSH? ${normal} (Yes or No?) no exits this script --- "
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) echo " ---${bold} Enabling MFA on SSH ${normal}----" && ENABLEMFA="true" ; break;;
            No ) echo " ---${bold} exiting - no action taken ${normal} ----" && exit;;
        esac
    done
   else
        echo " --- MFA appears to be configured already! exiting no action taken--- "
        exit
   fi

if [ "${ENABLEMFA}" == "true" ]; then
   echo -e " -----------------------------------------------------------------------------------------\n"
   echo -e " ----- Installing  Google Authenticator -----\n"
   echo -e " -----------------------------------------------------------------------------------------\n"
   yum install google-authenticator -y
   echo -e " ----- configuring sshd settings -----\n"
   echo "auth       required     pam_google_authenticator.so nullok" >> /etc/pam.d/sshd
   sed -e '/auth       substack     password-auth/ s/^#*/#/' -i /etc/pam.d/sshd
   sed -e '/ChallengeResponseAuthentication no/ s/^#*/#/' -i /etc/ssh/sshd_config
   sed -e '/#ChallengeResponseAuthentication yes/s/^#//' -i /etc/ssh/sshd_config
   {
   echo "AuthenticationMethods publickey,keyboard-interactive"
   echo "Match User ec2-user"
   echo "AuthenticationMethods publickey"
   } >> /etc/ssh/sshd_config
   echo  " ----- Installing /etc/profile.d/init script -----"
   cp -a ./init_google_authenticator.sh /etc/profile.d/init_google_authenticator.sh
   chown root:root /etc/profile.d/init_google_authenticator.sh
   chmod 644 /etc/profile.d/init_google_authenticator.sh
   service sshd restart
   echo -e " -----------------------------------------------------------------------------------------\n"
   echo -e " ----- MFA for SSH using Google Authenticator has been configured -----\n"
   echo -e " ----- MFA will be initialized for each user on their next login  -----\n"
   echo -e " -----------------------------------------------------------------------------------------\n"
  fi

