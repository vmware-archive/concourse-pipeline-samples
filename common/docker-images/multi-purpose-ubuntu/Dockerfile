FROM ubuntu:14.04

ENV LAST_UPDATE=2017-03-01

# Install.
RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install build-essential curl ruby ruby-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev zlib1g-dev wget nfs-common cifs-utils smbclient python python-pip && \
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
  wget https://github.com/pivotalservices/cfops/releases/download/v3.0.5/cfops && \
  mv cfops /usr/bin && \
  cd /usr/bin && mkdir plugins && cd plugins && \
  wget https://pivotal-cfops.s3.amazonaws.com/mysql-plugin-release/linux64/v0.0.22/cfops-mysql-plugin && \
  chmod 755 cfops-mysql-plugin && \
  wget https://pivotal-cfops.s3.amazonaws.com/redis-plugin-release/linux64/v0.0.14/cfops-redis-plugin && \
  chmod 755 cfops-redis-plugin && \
  wget https://pivotal-cfops.s3.amazonaws.com/rabbit-plugin-release/linux64/v0.0.5/cfops-rabbitmq-plugin && \
  chmod 755 cfops-rabbitmq-plugin && \
  wget https://pivotal-cfops.s3.amazonaws.com/nfs-plugin-release/linux64/v0.0.4/cfops-nfs-plugin && \
  chmod 755 cfops-nfs-plugin && cd / && \
  gem install cf-uaac && \
  cd /tmp && \
  wget https://github.com/spf13/hugo/releases/download/v0.16/hugo_0.16_linux-64bit.tgz && \
  tar xvf ./hugo_0.16_linux-64bit.tgz && \
  chmod 755 ./hugo && mv ./hugo /usr/bin && \
  rm hugo_0.16_linux-64bit.tgz && rm *.md

RUN localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && useradd -m -s /bin/bash pcfdev \
    && echo 'pcfdev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER pcfdev

RUN pip install --upgrade --user awscli
