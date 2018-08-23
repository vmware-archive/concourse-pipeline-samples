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
      http_proxy_url: <http_proxy_url>:<http_proxy_port>
      https_proxy_url: <https_proxy_url>:<http_proxy_port>
      no_proxy:
      - localhost
      - 127.0.0.1
      - mydomain.com
      - 10.190
```

Documentation on accepted groundcrew job's parameters:
https://bosh.io/jobs/groundcrew?source=github.com/concourse/concourse#p=http_proxy_url

In order to verify if the proxy configuration was applied after redeploying Concourse with the updates above, intercept the container of a pipeline task and check its environment variables (`env` command). It should contain the corresponding `http_proxy`,`https_proxy` and `no_proxy` variables along with their configured values from the Concourse deployment manifest.

The garden job has similar parameters which may or may not need to be set.

Note: no_proxy is not always supported for CIDRs. Some libraries will support it and
some will not. You can however add IP ranges by doing the following:

```
10.190  -> will match 10.190.0.0 - the equivalent of 10.190.0.0/16
```



#### Known issues

- **Problem**: Even with proxy config, connectivity fails with a message similar to  
  `Cloning into /tmp/git-resource-repo-cache\...
fatal: unable to access ... : Failed to connect to <proxy_ip> port 1080: Connection timed out`  
  **Possible root cause**: socks proxy may be running on a non-standard port.  
  **Potential solution**: explicitly declare the proxy port number in the deployment manifest (*even for http and port 80*) and re-deploy Concourse.  
  Example:  
```
  ...
  properties:
    http_proxy_url: http://10.160.0.29:80
    https_proxy_url: http://10.160.0.29:80
    ...
```

#### [Back to Concourse Pipeline Hacks](..)
