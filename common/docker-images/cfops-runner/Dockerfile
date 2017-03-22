FROM ubuntu:14.04

ENV LAST_UPDATE=2017-03-01

# Install.
RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y ruby ruby-dev && \
  wget https://github.com/pivotalservices/cfops/releases/download/v3.0.5/cfops && \
  mv cfops /usr/bin && \
  gem install cf-uaac && \

RUN localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && useradd -m -s /bin/bash pcfdev \
    && echo 'pcfdev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER pcfdev
