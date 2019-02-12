![build-metadata](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/email_with_attachment.png)

# Insert build metadata into user notifications in Concourse

Metadata about running builds, such as build ID, job or pipeline name, is available as environment variables for get or put operations in Concourse.

Such information is very useful to provide to pipeline users when notifying them about their builds' success or failure. The list of available variables is listed in the [Concourse documentation](https://concourse-ci.org/implementing-resources.html#resource-metadata).

See link below for an example of a pipeline definition file that inserts such variables into an email message for pipeline users using the email resource.

The same can be done for other notification resources such as the ones for Slack or Twitter.

[Sample pipeline from github](https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/pipelines/notifications/email-with-attachments/ci/email_with_metadata.yml).

### Running the sample on your Concourse server

Once you have a Concourse server setup to deploy this sample pipeline:

1. Download the sample pipeline YML file and pipeline files [from github](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/pipelines/notifications/email-with-attachments/ci) to your local machine.

2. Replace the email address placeholders with the appropriateemail addresses (e.g. search for YOUR-DESTINATION-EMAIL-ADDRESS-GOES-HERE), leaving the square brackets where existing

3. Setup the pipeline in Concourse with the fly command:  
   `fly -t local set-pipeline -p email-with-metadata -c email_with_metadata.yml`  


4. Go into the Concourse web interface, unpause the new pipeline and run the send-email-with-metadata job.

---
### Notes and hints

- Task `prep-email-text` sets the subject and body text of the emails by creating text files in an output directory that will be consumed by the send-email put action later on. Those text files contain references to the build metadata variables (you will find them in double curly brackets in the echo commands), which will in turn be replaced by the email resource as part of its put action.   

- Some resources may have trouble dealing with some environment variables. For example, as of the publishing date of this article, the email resource used in this example failed to render variable `ATC_EXTERNAL_URL` in the body of the email message. So, if you don't get an email sent as expected, even though there is no error message in the send-email step of your pipeline, you may want to try removing some of those environment variable references from the email message body/subjects to check if that might be causing such behavior.

- To simulate a build failure and get the email with the build failure email content sent out, just uncomment the `exit 1` command line from the `do-your-stuff-here` task of the pipeline. That will force the task to return an error code, halt the pipeline execution and execute the on_failure step that will send the failure email out.  
