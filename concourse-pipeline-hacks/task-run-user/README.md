![Task-run-user](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/icons/concourse-root.png)

# Run a task container with a user other than `root`

### The problem
By default, Concourse runs pipeline tasks with user `root`.  
Of course, this will not work for you if one of your task's image/container requires to be executed with a another user (e.g. postgres).

### The solution

To accommodate that requirement, Concourse provides a [`user` parameter](http://concourse.ci/running-tasks.html#task-run-user) for you to explicitly set the user to run a task container with.


#### Sample pipeline

The pipeline sample below declares the `user` attribute (`postgres`) as part of the task's `run` definition.


```
---
jobs:
- name: run-postgres-task
  plan:
  - do:
    - task: task-with-user-postgres
      config:
        platform: linux
        image_resource:
          type: docker-image
          source:
            repository: postgres
        run:
          user: postgres   # <====
          path: sh
          args:
          - -exc
          - |
            whoami
```

The  definition file for the sample above is available for download [here](pipeline.yml).


#### [Back to Concourse Pipeline Hacks](..)
