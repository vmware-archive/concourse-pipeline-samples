![Check-Resource](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/icons/concourse-check-resource.png)

# Make Concourse retrieve an older version of a resource

After Concourse retrieves the latest version of a newly configured resource, it will not retrieve previous versions of that resource automatically anymore, even if refer those old versions in your pipeline parameters.

In order to force Concourse to retrieve an older version of a resource, use the fly CLI command [`check-resource`](https://concourse.ci/fly-check-resource.html).

For example, in the sample pipeline further below, when you try to run job `unit-test` for the first time, it will be stuck waiting for the specified resource version even though [it exists](https://github.com/concourse/concourse/releases/tag/v2.6.0):

```
waiting for a suitable set of input versions
concourse-release - pinned version {"tag":"v2.6.0"} is not available
```

For the job to run, execute the following `fly` command to force Concourse to retrieve version `2.5.0` of the `fly-release` resource:
```
fly -t <your-target-alias> check-resource --resource <your-pipeline-name>/fly-release --from tag:v2.5.0
```

### Sample pipeline

```
---
resources:
- name: fly-release
  type: github-release
  source:
    user: concourse
    repository: concourse
jobs:
- name: unit-test
  plan:
  - do:
    - get: concourse-release
      version: { tag: 'v2.5.0' }
      params: { globs: ["fly_linux_amd64"] }
    - task: test-release
      config:
        platform: linux
        image_resource:
          type: docker-image
          source: { repository: alpine }
        inputs:
        - name: fly-release
        run:
          path: sh
          args:
          - -exc
          - |
            cat ./fly-release/version
```

The complete definition file for the sample pipeline above is available for download [here](pipeline.yml).


#### [Back to Concourse Pipeline Hacks](..)
