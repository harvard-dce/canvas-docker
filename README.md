[![](https://images.microbadger.com/badges/image/lbjay/canvas-docker.svg)](http://microbadger.com/images/lbjay/canvas-docker "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/lbjay/canvas-docker.svg)](http://microbadger.com/images/lbjay/canvas-docker "Get your own version badge on microbadger.com")

# canvas-docker

## Overview

**docker-canvas** aims to provide a simple, disposable, containerized Canvas instance for fast(ish) integration testing of LTI applications.

## Prerequisites

* [docker](https://www.docker.com/) (developed & tested w/ v1.12.1)

## Running

`docker run --name canvas-docker -p 3000:3000 -d lbjay/canvas-docker`

This repo is [registered](https://registry.hub.docker.com/u/lbjay/canvas-docker/) at Docker Hub as an automated build. So you should also be able to `docker pull lbjay/canvas-docker` to get the pre-built image.

## Building

1. Clone this repo somewhere. 
2. Build the image: `docker build -t canvas-docker .`
3. Start the container: `docker run -t -i -p 3000:3000 --name canvas-docker canvas-docker`
4. Point your browser to [http://localhost:3000](http://localhost:3000). The admin user/pass login is `canvas@example.edu` / `canvas-docker`.

## The "fat" container

The `Dockerfile` and associated build scripts create a resulting docker image where all necessary services of the Canvas instance are run within a single container. This approach is sometimes called a "fat" container. This admittedly goes against the "Docker Philosophy" of *one concern per container*, but for the intended purposes of the image it offers a couple of advantages, chief among them, faster spin-up times. The functionality focus is on creating a tool for integration testing of external (LTI) apps, not general canvas development, scalability, or, god forbid, actual deployment.

## Default developer_key & API access token

The image build includes the injection of default `developer_key` and `access_token` entries into the database. 

* **developer key**: test_developer_key
* **access token**: canvas-docker

API requests should be possible, e.g.,

`curl -H "Authorization: Bearer canvas-docker" http://localhost:3000/api/v1/courses`

The developer key is for use with Canvas's [OAuth2 Token Request Flow](https://canvas.instructure.com/doc/api/file.oauth.html). 
For example, if you're making use of [harvard-dce/django-canvas-api-token](https://github.com/harvard-dce/django-canvas-api-token).

## Outgoing Email

By default the instance's outgoing email `delivery_method` will be set to "test", meaning outgoing emails, such as user registration messages, will be 
sent to the container's stdout. 

To configure 'smtp' delivery set the following $ENV values at runtime:

* **EMAIL_DELIVERY_METHOD** (set this to "smtp")
* **SMTP_ADDRESS**
* **SMTP_PORT**
* **SMTP_USER**
* **SMTP_PASS**

Example using [Mandrill](https://mandrillapp.com/):

```
docker run -d --name=canvas -p 3000:3000 -e EMAIL_DELIVERY_METHOD=smtp -e SMTP_ADDRESS=smtp.mandrillapp.com -e SMTP_PORT=587 -e SMTP_USER=<mandrill_user> -e SMTP_PASS=<mandrill_api_key> lbjay/canvas-docker
```

## Details

* The resulting canvas image is built and run using `RAILS_ENV=development`. At some point I might try creating a separate "production" flavor, but, because docker doesn't allow the setting of build-time variables except in the `Dockerfile`, it would require a separate `Dockerfile`. Also, when I did try building with `RAILS_ENV=production`, the resulting instance had issues with routing errors to the compiled assets, and the `db:initial_setup` rake task threw lots of warnings about missing triggers (?). So that.
* Everything is currently somewhat "opinionated" in that things that would be nice to have configurable are hard-coded, e.g., postgres and canvas usernames, postgres network settings, path to the postgres data, etc.
* The `Dockerfile` build process mostly follows Canvas's [Quick Start](https://github.com/instructure/canvas-lms/wiki/Quick-Start) guidelines with a few exeptions:
    * as mentioned above, `RAILS_ENV=development`
    * redis is installed, configured and used
    * the `delated_job` background task is executed
    * postgres is configured to not require a password for local connections, or for connections originating within a network defined by Docker's default network bridge setup: 172.17.0.0/16.

## Contributors

* Jay Luker - [lbjay](https://github.com/lbjay)

## License

Apache 2.0

## Copyright

2016 President and Fellows of Harvard College
