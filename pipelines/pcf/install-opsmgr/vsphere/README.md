# Install Ops Manager pipeline

**Experimental - Work in progress**

This pipeline install Ops Manager and the Director tile.


## How to use this pipeline

1) Update [`pcf_params.yml`](pcf_params.yml) by following the instructions in the file.  

   This parameter file contains information about the PCF foundation (e.g. Ops Manager and Director) to which the tile will be deployed to.  

2) Update [`global_params.yml`](global_params.yml) by following the instructions in the file.  

  This parameter file contains information about global properties that typically apply to any PCF pipeline (e.g. Pivotal Network token).  

  This parameters file is separate from the others for reuse purposes, since any other PCF tile install or upgrade pipeline will use the same properties. If you already have this type of file created for another PCF tile pipeline, you can reuse it here.

3) Create the pipeline in Concourse:   

   `fly -t <target> sp -p install-opsmgr -c pipeline.yml -l global_params.yml  -l pcf_params.yml`


4) Un-pause and run pipeline `install-opsmgr`
