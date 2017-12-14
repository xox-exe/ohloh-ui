FROM ubuntu:14.04
MAINTAINER Paddy "rapbhan@gmail.com"
ARG DEBIAN_FRONTEND=noninteractive

ENV APP_HOME /var/local/openhub
WORKDIR $APP_HOME

# Create 'serv-deployer' user and add to sudoer without password
RUN adduser --disabled-password --gecos '' serv-deployer \
    && adduser serv-deployer sudo \
    && echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt-get update

RUN sudo apt-get install --yes --force-yes curl wget git-core build-essential libpq-dev zlib1g-dev libssl-dev \
     libreadline-dev libyaml-dev libcurl4-openssl-dev gcc libmagic-dev libpcre3-dev imagemagick zsh

RUN sudo apt-get install --yes --force-yes software-properties-common
RUN sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main"
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN apt-get update
RUN sudo apt-get install --yes --force-yes postgresql-client-9.6

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

RUN apt-get clean

RUN cd /tmp && wget https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.5.tar.gz && tar -xzvf ruby-2.2.5.tar.gz && cd ruby-2.2.5 && ./configure && make && sudo make install
RUN gem install bundler


RUN mkdir -p $APP_HOME
ADD . $APP_HOME
RUN bundle install

# Set the container user to 'serv-deployer'
USER serv-deployer
