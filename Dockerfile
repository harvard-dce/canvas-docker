FROM phusion/baseimage:latest

MAINTAINER Jay Luker <jay_luker@harvard.edu>

RUN apt-get update

RUN apt-get -y install \
    ruby1.9.1 ruby1.9.1-dev zlib1g-dev rubygems1.9.1 irb1.9.1 \
    libxml2-dev libxslt1-dev  libsqlite3-dev libhttpclient-ruby \
    imagemagick libxmlsec1-dev postgresql \
    python-software-properties software-properties-common

RUN add-apt-repository ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get install -y nodejs
