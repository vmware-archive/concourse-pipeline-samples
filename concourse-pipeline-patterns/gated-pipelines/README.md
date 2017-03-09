# Pipelines with a manually triggered step (a.k.a. "gated")

Gated pipelines provide control for administrators and release managers on *when* a given release is deployed to a tightly protected environment (e.g. production).

The execution of jobs that perform certain tasks (e.g. deployment) targeting the downstream environment beyond a "gate" step is done only upon an explicit manual trigger of such step.

Here are a few samples of this pattern:

1. [A very simple gated pipeline](01-simple)  

1. [The _Ship-it!_ example](02-shipit)  

1. [A more sophisticated gated pipeline](03-shipit-enhanced)  

1. Using Git Pull Requests to control a gated step of a pipeline (TBD)
