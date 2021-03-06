#!/bin/bash

set -e

rm setup.zip

if [ -f private.key ]
then
  # Set up GPG
  export GPG_TTY=$(tty)
  gpg --batch --import private.key

  # Set up SSH key
  gpg --decrypt id_rsa.gpg > id_rsa
  gpg --decrypt secrets.bash.gpg > secrets.bash
  rm secrets.bash.gpg id_rsa.gpg
fi

if [ -f id_rsa ]
then
  eval `ssh-agent -s`
  chmod 400 id_rsa
  ssh-add id_rsa

  # Clone repos
  for repo in $(cat ./repos.txt)
  do
    git clone $repo
  done
else
  echo "No SSH key for Github, no repositories cloned."
fi

# Install deps
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# @TODO: Reduce to configuration.
apt-get update && apt-get install -y nodejs yarn make
