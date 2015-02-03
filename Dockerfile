FROM ubuntu:14.04

MAINTAINER Jay Luker <jay_luker@harvard.edu>

ENV DEBIAN_FRONTEND noninteractive

# add nodejs and recommended ruby repos
RUN apt-get update \
    && apt-get -y install software-properties-common python-software-properties \
    && add-apt-repository ppa:chris-lea/node.js \
    && add-apt-repository ppa:brightbox/ppa \
    && apt-get update

# install deps for building/running canvas
RUN apt-get -y install ruby1.9.3 \
    zlib1g-dev libxml2-dev libxslt1-dev \
    imagemagick libpq-dev libxmlsec1-dev libcurl4-gnutls-dev \
    libxmlsec1 build-essential openjdk-7-jre unzip \
    python g++ make git-core nodejs

ENV DEBIAN_FRONTEND newt

RUN gem install bundler --version 1.7.2

# Set the locale to avoid active_model_serializers bundler install failure
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# install canvas
RUN cd /opt \
    && git clone https://github.com/instructure/canvas-lms.git \
    && cd /opt/canvas-lms \
    && bundle install --path vendor/bundle --without=sqlite mysql

# config setup
RUN cd /opt/canvas-lms \
    && for config in amazon_s3 delayed_jobs domain file_store outgoing_mail security external_migration \
       ; do cp config/$config.yml.example config/$config.yml \
       ; done
ADD assets/database.yml /opt/canvas-lms/config/database.yml
ADD assets/redis.yml /opt/canvas-lms/config/redis.yml

CMD ["bin/bash"]
