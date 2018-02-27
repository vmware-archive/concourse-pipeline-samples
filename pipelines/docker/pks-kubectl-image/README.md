![Concourse and a Private Docker Registry](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/concourse-and-private-registry.jpg)

# Pipeline for creating or updating a Docker image in Docker Hub

Sample pipeline that creates a Docker image that contains PCF PKS CLIs: `pks` and `kubectl`.

It downloads the `pks` and `kubectl` CLIs from the Pivotal Network and adds it to a Docker image: [`pivotalservices/pks-kubectl`](https://hub.docker.com/r/pivotalservices/pks-kubectl/).

The new image created gets tagged both as `latest` and as the same version of the PKS tile version in Docker Hub.
