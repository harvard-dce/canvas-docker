FROM ubuntu:14.04

MAINTAINER Jay Luker <jay_luker@harvard.edu>

ENV POSTGRES_VERSION 9.3
ENV RAILS_ENV development

# add nodejs and recommended ruby repos
RUN apt-get update \
    && apt-get -y install curl software-properties-common \
    && add-apt-repository ppa:brightbox/ppa \
    && add-apt-repository ppa:brightbox/ruby-ng \
    && apt-get update
RUN curl -sL https://deb.nodesource.com/setup_0.12 | bash

# install deps for building/running canvas
RUN echo "postfix postfix/mailname string localhost" |debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" |debconf-set-selections
RUN apt-get install -y \
    ruby2.1 ruby2.1-dev zlib1g-dev libxml2-dev libxslt1-dev \
    imagemagick libpq-dev libxmlsec1-dev libcurl4-gnutls-dev \
    libxmlsec1 build-essential openjdk-7-jre unzip curl \
    python g++ make git-core nodejs supervisor redis-server \
    libpq5 libsqlite3-dev mailutils \
    postgresql-$POSTGRES_VERSION \
    postgresql-client-$POSTGRES_VERSION \
    postgresql-contrib-$POSTGRES_VERSION \
    && echo 'myhostname = localhost' >> /etc/postfix/main.cf \
    && apt-get clean \
    && rm -Rf /var/cache/apt

# work around for AUFS bug
# as per https://github.com/docker/docker/issues/783#issuecomment-56013588
RUN mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private

RUN gem install bundler --version 1.11.2

# Set the locale to avoid active_model_serializers bundler install failure
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN groupadd -r canvasuser -g 433 && \
    adduser --uid 431 --system --gid 433 --home /opt/canvas --shell /sbin/nologin canvasuser && \
    adduser canvasuser sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN cd /opt/canvas \
    && git clone https://github.com/instructure/canvas-lms.git

COPY assets/database.yml /opt/canvas/canvas-lms/config/database.yml
COPY assets/redis.yml /opt/canvas/canvas-lms/config/redis.yml
COPY assets/cache_store.yml /opt/canvas/canvas-lms/config/cache_store.yml
COPY assets/development-local.rb /opt/canvas/canvas-lms/config/environments/development-local.rb
COPY assets/outgoing_mail.yml /opt/canvas/canvas-lms/config/outgoing_mail.yml
COPY assets/supervisord.conf /etc/supervisor/supervisord.conf

COPY assets/dbinit.sh /opt/canvas/dbinit.sh
COPY assets/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
RUN sed -i "/^#listen_addresses/i listen_addresses='*'" /etc/postgresql/9.3/main/postgresql.conf
COPY assets/start.sh /opt/canvas/start.sh

RUN chmod 755 /opt/canvas/*.sh
RUN chown -R canvasuser: /opt/canvas

WORKDIR /opt/canvas/canvas-lms
USER canvasuser

RUN bundle install --path vendor/bundle --without="mysql"

# config setup
RUN for config in amazon_s3 delayed_jobs domain file_store security external_migration \
       ; do cp config/$config.yml.example config/$config.yml \
       ; done

RUN mkdir -p log tmp/pids public/assets public/stylesheets/compiled \
    && touch Gemmfile.lock

RUN npm install
RUN bundle exec rake canvas:compile_assets
RUN sudo npm install -g coffee-script@1.6.2

RUN sudo service postgresql start && /opt/canvas/dbinit.sh

# postgres
EXPOSE 5432
# redis
EXPOSE 6379
# canvas
EXPOSE 3000

USER root
CMD ["/opt/canvas/start.sh"]
