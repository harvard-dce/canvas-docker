FROM ubuntu:14.04

MAINTAINER Jay Luker <jay_luker@harvard.edu>

ENV DEBIAN_FRONTEND noninteractive
ENV POSTGRES_VERSION 9.3

# add nodejs and recommended ruby repos
RUN apt-get update \
    && apt-get -y install software-properties-common python-software-properties \
    && add-apt-repository ppa:chris-lea/node.js \
    && add-apt-repository ppa:brightbox/ppa \
    && apt-get update

# install deps for building/running canvas
RUN apt-get install -y \
    ruby1.9.3  zlib1g-dev libxml2-dev libxslt1-dev \
    imagemagick libpq-dev libxmlsec1-dev libcurl4-gnutls-dev \
    libxmlsec1 build-essential openjdk-7-jre unzip \
    python g++ make git-core nodejs supervisor redis-server \
    libpq5 \
    postgresql-$POSTGRES_VERSION \
    postgresql-client-$POSTGRES_VERSION \
    postgresql-contrib-$POSTGRES_VERSION \
    && apt-get clean \
    && rm -Rf /var/cache/apt

ENV DEBIAN_FRONTEND dialog

RUN gem install bundler --version 1.7.10

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

RUN cd /opt/canvas-lms \
    &&  npm install --unsafe-perm \
    && bundle exec rake canvas:compile_assets

COPY assets/database.yml /opt/canvas-lms/config/database.yml
COPY assets/redis.yml /opt/canvas-lms/config/redis.yml
COPY assets/supervisord.conf /etc/supervisor/supervisord.conf
COPY assets/setenv.sh /setenv.sh
COPY assets/dbinit.sh /dbinit.sh
RUN chmod 755 /dbinit.sh /setenv.sh

RUN sed -i -e 's/local\s\+all\s\+all\s\+peer/local all all md5/g' /etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf
RUN service postgresql start && /dbinit.sh

# postgres
EXPOSE 5432
# redis
EXPOSE 6379
# canvas
EXPOSE 3000

ENTRYPOINT ["/setenv.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
