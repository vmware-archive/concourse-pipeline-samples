![Email with attachments in Concourse pipelines](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/bg-pipeline-icon.jpg)

# Email with attachments in Concourse pipelines

*WORK IN PROGRESS...*   

This is an example of a Concourse pipeline that sends emails with attachments by leveraging the [Nodemailer Node.js package](https://github.com/nodemailer/nodemailer).  

As of the writing of this sample, the existing email resources for Concourse do not provide a mechanism to attach files to emails (or at least they are not documented), thus the motivation to write a simple email mechanism like this.  

The mechanism leverages a task that invokes a Node.js script under-the-covers.

---

A CI pipeline may be required to send notification emails containing one or more attachments to its users and subscribers. An example of a use case is of a pipeline that produces files and/or reports that need to be sent directly to users instead of being stored in an artifact repository.  
