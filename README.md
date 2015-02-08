# canvas-docker

## Overview

This project aims to provide a simple, containerized Canvas instance running separate, networked containers for canvas, postgres and redis. The initial container provisioning via the Dockerfile follows the Canvas "Production Start". However, it was created for the purposes of developing and testing LTI applications, not for running a production Canvas.

## Prerequisites

* [docker](https://www.docker.com/) (developed & tested w/ v1.4.1)
* [fig](http://fig.sh) (requires python >= 2.7, docker >= 1.3)

## Getting Started

1. Clone this repo somewhere. 
2. Why would you not create and activate a virtualenv?
3. `pip install -r requirements.txt`
4. `cp fig.yml.example fig.yml`
5. Edit fig.yml and change the default postgres password if desired. You need to change both **DBPASS** in the *canvas:* section and **POSTGRES_PASSWORD** in the *pg:* section.
6. `fig up`
7. Point your browser to http://localhost:3000. The admin user/pass login is `canvas@example.edu` / `canvas`.

## Contributors

* Jay Luker - [lbjay](https://github.com/lbjay)

## License

Apache 2.0

## Copyright

2015 President and Fellows of Harvard College
