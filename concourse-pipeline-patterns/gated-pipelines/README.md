# Pipelines with Manually triggered steps (a.k.a. "Gated")

Gated pipelines provide control for administrators and release managers on *when* a given release is deployed to a protected environment (e.g. production).

The execution of a job (e.g. deployment) that targets the downstream environment beyond the "gated" step is only done upon an explicit manual trigger of that job.

Here are a few samples of this pattern:

1. (A very simple gated pipeline)[01-simple]  

1. (The _Ship-it!_ example)[02-shipit]  

1. (A more sophisticated gated pipeline)[03-shipit-enhanced]  
