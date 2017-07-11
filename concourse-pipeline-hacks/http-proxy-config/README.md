![Proxy](https://github.com/lsilvapvt/misc-support-files/raw/master/docs/images/http-proxy.png)

# Configure Concourse with an HTTP/HTTPS proxy

### The problem

Concourse workers require an HTTP/HTTPS proxy to access external artifacts from the internet.

  
### The solution

Deploy Concourse workers with appropriate proxy configuration for its `groundcrew` job.

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

https://bosh.io/jobs/groundcrew?source=github.com/concourse/concourse#p=http_proxy_url


#### [Back to Concourse Pipeline Hacks](..)
