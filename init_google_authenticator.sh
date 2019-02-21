#!/bin/bash -e

# this file is placed in /etc/profile.d/init_goole_authenticator.sh
# Owner = root
# group = root

# initialize google authenticator only if its not already configured and the user is not root
if [ ! -e ~/.google_authenticator ]  &&  [ "$USER" != "root" ]; then
      echo -e " -----------------------------------------------------------------------------------------\n"
      echo -e " ----- Initializing google-authenticator -----\n"
      echo -e " -----------------------------------------------------------------------------------------\n"
      google-authenticator --time-based --disallow-reuse --force --rate-limit=3 --rate-time=30 --window-size=3
      echo -e " -----------------------------------------------------------------------------------------\n"
      echo -e " ----- IMPORTANT ----- IMPORTANT ----- IMPORTANT ----- IMPORTANT -----\n"
      echo -e " -----------------------------------------------------------------------------------------\n"
      echo -e "Save the generated emergency scratch codes and use secret key or scan the QR code to register your device for multi-factor authentication.\n"
      echo -e "Login again using your ssh key pair and the generated one-time password on your registered device.\n"
      logout
   fi
