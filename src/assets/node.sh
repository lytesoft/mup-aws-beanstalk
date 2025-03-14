#!/bin/bash
NODE_VERSION=<%= nodeVersion %>
NPM_VERSION=<%= npmVersion %>
MAJOR_NODE_VERSION=`echo $NODE_VERSION | awk -F. '{print $1}'`
MINOR_NODE_VERSION=`echo $NODE_VERSION | awk -F. '{print $2}'`
PATCH_NODE_VERSION=`echo $NODE_VERSION | awk -F. '{print $3}'`
METEOR_VERSION=<%= meteorVersion %>

echo "Node: $NODE_VERSION"
echo "Major: $MAJOR_NODE_VERSION"
echo "Minor: $MINOR_NODE_VERSION"
echo "Patch: $PATCH_NODE_VERSION"

export NVM_DIR="/.nvm"
# Install nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

if [[ $MAJOR_NODE_VERSION == "14" && $MINOR_NODE_VERSION -ge 21 && $PATCH_NODE_VERSION -ge 4 ]]; then
  #Install latests 14 version so the folder structure is there when trying to download custom node version
  nvm install 14

  # Install Meteor's custom NodeJS v14 LTS version
  NODE_INSTALL_PATH="/.nvm/versions/node/v$NODE_VERSION"

  if [ -d $NODE_INSTALL_PATH ]; then
    echo "Meteor's custom v14 LTS Node version is already installed ($NODE_VERSION)"
  else
    echo "Using Meteor's custom NodeJS v14 LTS version"

    # https://hub.docker.com/layers/meteor/node/14.21.4/images/sha256-f4e19b4169ff617118f78866c2ffe392a7ef44d4e30f2f9fc31eef2c35ceebf3?context=explore
    curl "https://static.meteor.com/dev-bundle-node-os/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" | tar xzf - -C /tmp/
    mv /tmp/node-v$NODE_VERSION-linux-x64 "$NODE_INSTALL_PATH"
    ls -l $NODE_INSTALL_PATH
  fi
else
  echo "Using NVM"
  nvm install $NODE_VERSION
fi

# Verify installed Node.js and npm versions
echo "Node.js version: $(node -v)"
echo "NPM version before update: $(npm -v)"

nvm use $NODE_VERSION
nvm alias default $NODE_VERSION
npm i -g npm@$NPM_VERSION

# AWS Linux 2 / 2023
[[ -z "$APP_PATH" ]] && APP_PATH="$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppStagingDir)"
echo "APP_PATH: $APP_PATH"

cd "$APP_PATH"
echo "Installing npm dependencies"
cd programs/server && npm install --unsafe-perm