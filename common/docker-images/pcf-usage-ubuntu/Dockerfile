FROM ubuntu:14.04

# Install.
RUN \
  apt-get update && \
  apt-get -y install build-essential curl ruby ruby-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev zlib1g-dev wget nfs-common && \
  gem install bosh_cli --no-ri --no-rdoc && \
  wget -O cfcli.tgz "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" && \
  tar -xvzf cfcli.tgz && \
  chmod 755 cf && \
  mv cf /usr/bin && \
  wget -O jq "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" && \
  chmod 755 ./jq && \
  mv ./jq /usr/bin && \
  apt-get -y install git && \
  gem install cf-uaac && \
  curl -sL https://deb.nodesource.com/setup_6.x | sudo bash - && \
  apt-get -y install nodejs
