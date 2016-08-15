FROM ubuntu:14.04

# Install.
RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install build-essential ruby ruby-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev zlib1g-dev wget python-pip nfs-common rsync && \
  gem install bosh_cli --no-ri --no-rdoc && \
  wget -O fly "http://192.168.100.4:8080/api/v1/cli?arch=amd64&platform=linux" && \
  chmod 755 fly && \
  mv fly /usr/bin && \
  wget -O spruce "https://github.com/geofffranks/spruce/releases/download/v1.1.2/spruce-linux-amd64" && \
  chmod 755 spruce && \
  mv spruce /usr/bin && \
  wget -O spiff "https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_linux_amd64" && \
  chmod 755 spiff && \
  mv spiff /usr/bin && \
  wget -O cfcli.tgz "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" && \
  tar -xvzf cfcli.tgz && \
  chmod 755 cf && \
  mv cf /usr/bin && \
  apt-get -y install git && \
  wget -O bosh-init https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-0.0.81-linux-amd64 && \
  chmod 755 bosh-init && \
  mv bosh-init /usr/bin && \
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
  rm hugo_0.16_linux-64bit.tgz && rm *.md && \
  pip install shyaml && \
  wget https://github.com/virtmerlin/rabbitmq-dump-queue/raw/master/release/rabbitmq-dump-queue-1.1-linux-amd64/rabbitmq-dump-queue && \
  chmod 755 rabbitmq-dump-queue && mv rabbitmq-dump-queue /usr/bin && \
  wget https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/rabbitmq_v3_6_3/bin/rabbitmqadmin && \
  chmod 755 rabbitmqadmin && mv rabbitmqadmin /usr/bin && \
  DEBIAN_FRONTEND=noninteractive apt-get -q -y install mysql-server
