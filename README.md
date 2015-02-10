# canvas-docker

## Overview

This project aims to provide a simple, containerized Canvas instance running separate, networked containers for canvas, postgres and redis. The initial container provisioning via the Dockerfile follows the Canvas "Production Start". However, it was created for the purposes of developing and testing LTI applications, not for running a production Canvas.

## Prerequisites

* [docker](https://www.docker.com/) (developed & tested w/ v1.4.1)
* [fig](http://fig.sh) (requires python >= 2.7, docker >= 1.3)

## Quick Start

1. Clone this repo somewhere. 
2. Why would you not create and activate a virtualenv?
3. `pip install -r requirements.txt`
4. Copy one of either `fig.yml.standard` or `fig.yml.fat` to `fig.yml`
5. `fig up`
6. Point your browser to [http://localhost:3000](http://localhost:3000). The default admin user/pass login is `canvas@example.edu` / `canvas`.

## Fat vs Standard

This project contains Dockerfiles, scripts and `fig` configurations for building either a "standard", multi-container instance, or a "fat" image where all components are run in a single container. Both should work interchangeably for the purposes of running a dev/test instance of canvas. The "fat" image has the advantage of being much faster to spin up as the canvas database init rake tasks have already been run during the image build. The "standard" approach, OTOH, adheres to the general Docker philosophy of one responsibility/service per container. Which one is better?  ¯\\_(ツ)_/¯

## Tweaks

See the `environment:` section of the respective `fig.yml.*` files for configurable settings. 

## Contributors

* Jay Luker - [lbjay](https://github.com/lbjay)

## License

Apache 2.0

## Copyright

2015 President and Fellows of Harvard College
