![Pipeline image](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/icons/concourse-gate-pipelines.png)

# Gated CI pipelines

Gated pipelines provide control for administrators and release managers on *when* a given software release is deployed to a tightly protected environment (e.g. production).

The execution of jobs that perform certain tasks (e.g. deployment) targeting the downstream environment beyond the "gate" step is done only upon either an approval coming from an external Change Control system or an explicit manual trigger of such step.

Here are a few samples of this pattern:

1. [A simple gated pipeline](01-simple)  

1. [Ship-it!_ A gated pipeline with notifications](02-shipit)  

1. [A more sophisticated gated pipeline](03-shipit-enhanced)  

1. [A gated pipeline controlled by GitHub Pull Requests](04-github-pull-request)  



![ShipIt gated pipeline screenshot](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/images/shipit-gated-pipeline.png)
