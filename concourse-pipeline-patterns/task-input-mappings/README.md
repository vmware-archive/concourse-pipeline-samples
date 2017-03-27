![Pipeline image](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/icons/concourse-timers.png)

# Tasks with parameterized inputs and outputs

Concourse allows for the execution of a common task multiple times with parameterized inputs and outputs in a pipeline.
The [input-mappings](http://concourse.ci/task-step.html#input_mapping) and [output-mappings](http://concourse.ci/task-step.html#output_mapping) attributes enable a task to mutate its behavior during run time.

### Typical use-case
Execution of unit- or acceptance-test of a new release against multiple environments with distinct characteristics while re-using a common orchestrator task    
