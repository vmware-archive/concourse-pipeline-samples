FROM ubuntu:14.04

ENV LAST_UPDATE=2017-03-01

RUN localedef -i en_US -f UTF-8 en_US.UTF-8

# install base tools, including cfcli, jq, and cf-uaac
RUN \
  apt-get update && \
  apt-get install -y software-properties-common && \
  apt-add-repository ppa:brightbox/ruby-ng && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install build-essential curl ruby2.4 ruby2.4-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev zlib1g-dev wget nfs-common cifs-utils smbclient python python-pip && \
  gem install bosh_cli --no-ri --no-rdoc && \
  wget -O cfcli.tgz "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" && \
  tar -xvzf cfcli.tgz && \
  chmod 755 cf && \
  mv cf /usr/bin && \
  wget -O jq "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" && \
  chmod 755 ./jq && \
  mv ./jq /usr/bin && \
  apt-get -y install git && \
  apt-get -y install sshpass && \
  gem install cf-uaac

# install cfops and plugins
RUN \
  wget https://github.com/pivotalservices/cfops/releases/download/v3.0.5/cfops && \
  mv ./cfops /usr/bin && \
  chmod 755 /usr/bin/cfops && \
  mkdir /usr/bin/plugins && \
  wget https://github.com/pivotalservices/cfops-mysql-plugin/releases/download/v0.0.22/cfops-mysql-plugin_binaries.tgz && \
  tar xvf ./cfops-mysql-plugin_binaries.tgz && \
  mv ./pipeline/output/builds/linux64/cfops-mysql-plugin /usr/bin/plugins && \
  chmod 755 /usr/bin/plugins/cfops-mysql-plugin && \
  wget https://github.com/pivotalservices/cfops-redis-plugin/releases/download/v0.0.14/cfops-redis-plugin_binaries.tgz && \
  tar xvf ./cfops-redis-plugin_binaries.tgz && \
  mv ./pipeline/output/builds/linux64/cfops-redis-plugin /usr/bin/plugins && \
  chmod 755 /usr/bin/plugins/cfops-redis-plugin && \
  wget https://github.com/pivotalservices/cfops-rabbitmq-plugin/releases/download/v0.0.5/cfops-rabbitmq-plugin_binaries.tgz && \
  tar xvf ./cfops-rabbitmq-plugin_binaries.tgz && \
  mv ./pipeline/output/linux64/cfops-rabbitmq-plugin /usr/bin/plugins && \
  chmod 755 /usr/bin/plugins/cfops-rabbitmq-plugin && \
  wget https://github.com/pivotalservices/cfops-nfs-plugin/releases/download/v0.0.4/cfops-nfs-plugin_binaries.tgz && \
  tar xvf ./cfops-nfs-plugin_binaries.tgz && \
  mv ./pipeline/output/builds/linux64/cfops-nfs-plugin /usr/bin/plugins && \
  chmod 755 /usr/bin/plugins/cfops-nfs-plugin && \
  cd /

# install awscli
RUN \
  pip install awscli --upgrade
