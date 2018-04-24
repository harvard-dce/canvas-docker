FROM ubuntu:14.04

MAINTAINER Jay Luker <jay_luker@harvard.edu>

ARG REVISION=master
ENV RAILS_ENV development
ENV GEM_HOME /opt/canvas/.gems
ENV YARN_VERSION 0.27.5-1

# add nodejs and recommended ruby repos
RUN apt-get update \
    && apt-get -y install curl software-properties-common \
    && add-apt-repository -y ppa:brightbox/ruby-ng \
    && apt-get update \
    && apt-get install -y ruby2.4 ruby2.4-dev supervisor redis-server \
        zlib1g-dev libxml2-dev libxslt1-dev libsqlite3-dev postgresql \
        postgresql-contrib libpq-dev libxmlsec1-dev curl make g++ git \
        unzip fontforge libicu-dev

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs \
        yarn="$YARN_VERSION" \
        unzip \
        fontforge

RUN apt-get clean && rm -Rf /var/cache/apt

# Set the locale to avoid active_model_serializers bundler install failure
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN groupadd -r canvasuser -g 433 && \
    adduser --uid 431 --system --gid 433 --home /opt/canvas canvasuser && \
    adduser canvasuser sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN if [ -e /var/lib/gems/$RUBY_MAJOR.0/gems/bundler-* ]; then BUNDLER_INSTALL="-i /var/lib/gems/$RUBY_MAJOR.0"; fi \
  && gem uninstall --all --ignore-dependencies --force $BUNDLER_INSTALL bundler \
  && gem install bundler --no-document -v 1.15.2 \
  && chown -R canvasuser: $GEM_HOME

#RUN gem install bundler --version 1.14.6

COPY assets/dbinit.sh /opt/canvas/dbinit.sh
COPY assets/start.sh /opt/canvas/start.sh
RUN chmod 755 /opt/canvas/*.sh

COPY assets/supervisord.conf /etc/supervisor/supervisord.conf
COPY assets/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
RUN sed -i "/^#listen_addresses/i listen_addresses='*'" /etc/postgresql/9.3/main/postgresql.conf

RUN cd /opt/canvas \
    && git clone https://github.com/instructure/canvas-lms.git \
    && cd canvas-lms \
    && git checkout $REVISION

WORKDIR /opt/canvas/canvas-lms

COPY assets/database.yml config/database.yml
COPY assets/redis.yml config/redis.yml
COPY assets/cache_store.yml config/cache_store.yml
COPY assets/development-local.rb config/environments/development-local.rb
COPY assets/outgoing_mail.yml config/outgoing_mail.yml

RUN for config in amazon_s3 delayed_jobs domain file_store security external_migration \
       ; do cp config/$config.yml.example config/$config.yml \
       ; done

RUN $GEM_HOME/bin/bundle install --jobs 8 --without="mysql"
RUN yarn install --pure-lockfile
RUN COMPILE_ASSETS_NPM_INSTALL=0 $GEM_HOME/bin/bundle exec rake canvas:compile_assets_dev

RUN mkdir -p log tmp/pids public/assets public/stylesheets/compiled \
    && touch Gemmfile.lock

RUN service postgresql start && /opt/canvas/dbinit.sh

RUN chown -R canvasuser: /opt/canvas
RUN chown -R canvasuser: /tmp/attachment_fu/

# postgres
EXPOSE 5432
# redis
EXPOSE 6379
# canvas
EXPOSE 3000

CMD ["/opt/canvas/start.sh"]
