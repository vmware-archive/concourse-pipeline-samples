<!-- <img src="https://cdn1.iconfinder.com/data/icons/universal-signs-symbols/128/recycle-green-512.png" alt="Rotate" height="70"/>&nbsp;&nbsp;<img src="https://www.whatissslcertificate.com/wp-content/uploads/2016/10/tls13.jpg" alt="Certs" height="70"/>

# Rotate PCF Non-Configurable Certificates

This sample pipeline invokes the PCF Ops Manager API to regenerate and renew all [internal (i.e. non-configurable) certificates](https://docs.pivotal.io/pivotalcf/security/pcf-infrastructure/api-cert-rotation.html#rotate-non-config) for the foundation components by using the currently configured active certificate authority.

---

## How to use this pipeline

1) Update [`pcf_params.yml`](pcf_params.yml) by following the instructions in the file.  

   This parameter file contains information about the PCF foundation's Ops Manager and Director required to obtain information about its certificates.  

2) Create the pipeline in Concourse:  

   `fly -t <target> set-pipeline -p regenerate-internal-certificates -c pipeline.yml -l pcf_params.yml`

3) Un-pause and run pipeline `regenerate-internal-certificates`

--- -->
