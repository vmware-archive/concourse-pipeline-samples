FROM ubuntu:14.04

# Install.
RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install build-essential ruby ruby-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev zlib1g-dev wget nfs-common cifs-utils smbclient && \
  gem install bosh_cli --no-ri --no-rdoc && \
  wget -O cfcli.tgz "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" && \
  tar -xvzf cfcli.tgz && \
  chmod 755 cf && \
  mv cf /usr/bin && \
  apt-get -y install git && \
  apt-get -y install sshpass && \
  wget https://github.com/pivotalservices/cfops/releases/download/v2.2.29/cfops_binaries.tgz && \
  tar xvf ./cfops_binaries.tgz && \
  mv ./pipeline/output/builds/linux64/cfops /usr/bin && \
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
