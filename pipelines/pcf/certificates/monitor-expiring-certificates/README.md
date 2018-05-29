<img src="https://pivotal.gallerycdn.vsassets.io/extensions/pivotal/vscode-concourse/0.1.3/1517353139519/Microsoft.VisualStudio.Services.Icons.Default" alt="Concourse" height="70"/>&nbsp;&nbsp;<img src="https://www.whatissslcertificate.com/wp-content/uploads/2016/10/tls13.jpg" alt="Certs" height="70"/>

# Monitor Expiring PCF Certificates

This sample pipeline checks for expiring certificates of a PCF deployment.

It gets automatically triggered on a regular basis by a time resource to check for the list of certificates about to expire from the corresponding PCF Ops Manager.

The pipeline monitors five types of PCF certificates:
- [Configurable Certificates](https://docs.pivotal.io/pivotalcf/security/pcf-infrastructure/api-cert-rotation.html#rotate-config)
- [Non-Configurable Certificates](https://docs.pivotal.io/pivotalcf/security/pcf-infrastructure/api-cert-rotation.html#rotate-non-config)
- [CA Certificates](https://docs.pivotal.io/pivotalcf/security/pcf-infrastructure/api-cert-rotation.html#rotate-ca)
- [Bosh Director Trusted Certificates](https://docs.pivotal.io/pivotalcf/customizing/trusted-certificates.html)
- [Ops Manager Root Certificates](https://docs.pivotal.io/pivotalcf/security/pcf-infrastructure/api-cert-rotation.html#rotate-root)

If a certificate is about to expire within the given `EXPIRATION_TIME_FRAME` pipeline parameter, then the pipeline will throw an error and send out a notification (e.g. email) to the configured recipients.

---

## How to use this pipeline

1) Update [`pcf_params.yml`](pcf_params.yml) by following the instructions in the file.  

   This parameter file contains information about the PCF foundation's Ops Manager and Director required to obtain information about its certificates.  

2) If automatic email notification is desired, update the corresponding parameters for resource `send-an-email` (e.g. smtp_host, credentials) in the `pipeline.yml` file.

3) Adjust how often the `time-trigger` resource should trigger the pipeline execution by updating its `interval` parameter in `pipeline.yml` to the desired time interval.

4) Adjust parameter `EXPIRATION_TIME_FRAME` in `pipeline.yml` to the desired time frame to check for about-to-expire certificates (e.g. within the next 3 months=`3m`)

5) Create the pipeline in Concourse:  

   `fly -t <target> set-pipeline -p monitor-certificates -c pipeline.yml -l pcf_params.yml`

6) Un-pause and run pipeline `monitor-certificates`

---
