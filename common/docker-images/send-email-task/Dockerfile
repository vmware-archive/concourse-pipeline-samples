FROM ubuntu:14.04

# Install.
RUN \
  apt-get update && \
  apt-get -y install build-essential curl wget git && \
  wget -O jq "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" && \
  chmod 755 ./jq && \
  mv ./jq /usr/bin && \
  curl -sL https://deb.nodesource.com/setup_6.x | sudo bash - && \
  apt-get -y install nodejs && \
  mkdir app && cd app && \
  npm install nodemailer
