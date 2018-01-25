FROM ubuntu:14.04
MAINTAINER Paddy "rapbhan@gmail.com"
ARG DEBIAN_FRONTEND=noninteractive

ENV APP_HOME /var/local/openhub
WORKDIR $APP_HOME

# Create 'serv-deployer' user and add to sudoer without password
RUN adduser --disabled-password --gecos '' serv-deployer \
    && adduser serv-deployer sudo \
    && echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 16126D3A3E5C1192

RUN sudo apt-get update

RUN sudo apt-get install --yes --force-yes curl wget git-core build-essential libpq-dev zlib1g-dev libssl-dev \
     libreadline-dev libyaml-dev libcurl4-openssl-dev gcc libmagic-dev libpcre3-dev libexpat1-dev gettext zip \
     apt-transport-https imagemagick


#Install SVN 1.9.7
RUN sudo sh -c 'echo "deb http://opensource.wandisco.com/ubuntu `lsb_release -cs` svn19" >> /etc/apt/sources.list.d/subversion19.list'
RUN sudo wget -q http://opensource.wandisco.com/wandisco-debian.gpg -O- | sudo apt-key add -
RUN sudo apt-get update
RUN sudo apt-get install --yes --force-yes subversion

#Install Git 2.15.1 (as in Production)
RUN cd /tmp && wget --quiet https://github.com/git/git/archive/v2.15.1.zip -O git.zip && unzip git.zip && cd git-* \
            && make prefix=/usr all && sudo make prefix=/usr install

#Install Ruby2.2
RUN cd /tmp && wget https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.5.tar.gz && tar -xzvf ruby-2.2.5.tar.gz && cd ruby-2.2.5 && ./configure && make && sudo make install
RUN gem install bundler

#Install PG
RUN sudo apt-get -y install software-properties-common python-software-properties
RUN sudo apt-get install --yes --force-yes software-properties-common
RUN sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main"
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN sudo apt-get update
RUN sudo apt-get install --yes --force-yes postgresql-client-9.6
RUN sudo apt-get clean

RUN mkdir -p $APP_HOME
ADD . $APP_HOME
RUN bundle install

# Set the container user to 'serv-deployer'
USER serv-deployer
