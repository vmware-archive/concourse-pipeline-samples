![Proxy](https://github.com/lsilvapvt/misc-support-files/raw/master/docs/images/http-proxy.png)

# How to configure Concourse with an HTTP/HTTPS proxy

### The problem

Concourse workers require an HTTP/HTTPS proxy to access external artifacts from the internet.


### The solution

Deploy Concourse workers with appropriate proxy configuration for the `groundcrew` job.

```
- name: worker
  ...
  jobs:
  - name: groundcrew
    release: concourse
    properties:
      http_proxy_url: <http_proxy_url>
      https_proxy_url: <https_proxy_url>
      no_proxy:
      - localhost
      - 127.0.0.1
      - 10.1.1.0/24   # subnet CIDR
      - mydomain.com  
```

Documentation on accepted groundcrew job's parameters:
https://bosh.io/jobs/groundcrew?source=github.com/concourse/concourse#p=http_proxy_url

In order to verify if the proxy configuration was applied after redeploying Concourse with the updates above, intercept the container of a pipeline task and check its environment variables (`env` command). It should contain the corresponding `http_proxy`,`https_proxy` and `no_proxy` variables along with their configured values from the Concourse deployment manifest.


#### [Back to Concourse Pipeline Hacks](..)
