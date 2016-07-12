# Multi-purpose Ubuntu Docker image

This Dockerfile contains the image definition to build a multi-purpose Ubuntu image containing Bosh CLI, Bosh Init, Git client, CF CLI, Spruce, Spiff and CFOps cli.

A complete description of the image and current sofware versions installed in it can be found at its Docker Hub location:
https://hub.docker.com/r/silval/ubuntu-bosh-spruce-cf-fly/

In Concourse task's definition, refer to the image as docker:///silval/ubuntu-bosh-spruce-cf-fly

In order to create your own image with this file, perform the following steps after saving it on your local system:
- Install the [Docker Toolbox](https://www.docker.com/products/docker-toolbox) on your system
- In the same directory where the Dockerfile is located,  run command ```docker build .```
- Check the created image ID by running command ```docker images```
- Rename the image: ```docker tag <img-id> <your-docker-id>/<your-image-name>:latest```
- Login into Docker Hub using your Docker credentials: ```docker login```
- Push the new image to Docker Hub: ```docker push <your-docker-id>/<name>:latest```
