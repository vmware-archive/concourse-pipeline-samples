![Emails with attachments in Concourse pipelines](https://raw.githubusercontent.com/pivotalservices/concourse-pipeline-samples/master/common/images/email_with_attachment.png)

# Emails with file attachments in Concourse pipelines
This is an example of a Concourse pipeline that sends emails with file attachments by leveraging the [Nodemailer Node.js package](https://nodemailer.com/).  

To add it to your pipeline, extract [this project](https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/email-with-attachments) from github and copy the following files to your pipeline scripts and tasks directory:
- [send-email.yml](https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/email-with-attachments/ci/tasks/send-email.yml)
- [send-email.js](https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/email-with-attachments/ci/scripts/send-email.js)

Then update the last line of *send-email.yml* to point to your resource name and sub-directory where *send--email.js* is located:  
```
      node <your-resource-directory-path-goes-here>/send-email.js     
```  

In your pipeline definition file, this is how you define a task to send an email with attachments:
```
    - task: email-notification-failure
      file: <your-resource-directory-location-goes-here>/send-email.yml
      params:
        SMTP_HOST: <<your-smtp-host-goes-here  e.g. smtp.gmail.com>
        SMTP_PORT: <<your-smtp-server-port-number  e.g. 465>
        SMTP_USERNAME: <<your-email-id-with-encoded-@-sign  e.g. myemail%40gmai.com >
        SMTP_PASSWORD: <your-email-password>
        EMAIL_FROM: <the-sender-email-address-without-enconding   e.g. myemail@gmail.com>
        EMAIL_TO: <the-list-of-comma-separated-destination-emails-without-encoding  e.g. him@there.com,her@here.net>
        EMAIL_SUBJECT_TEXT: <email-subject-message   e.g. Hello there>
        EMAIL_BODY_TEXT: <email-body-text   e.g. This is my email body.>
        EMAIL_ATTACHMENTS: <json-array-with-attachments-info. See format below. Omit this field if no attachment is needed>
```
Example of input for the the ```EMAIL_ATTACHMENTS``` parameter:  
- For one attachment file:
```
   EMAIL_ATTACHMENTS: '[{ "filename": "my-attachment.txt","path": "./pipeline-scripts/email-with-attachments/my-attachment.txt", "contentType":"text/plain"}]'
```
- For two or more attachment files:
```
   EMAIL_ATTACHMENTS: '[{ "filename": "myfile1.txt","path": "./my-path/myfile1.txt", "contentType":"text/plain"},{ "filename": "report.json","path": "./my-path/report.json", "contentType":"application/json"}]'
```


You are now ready to run your pipeline and send emails with attachments from it.


**Note**: some SMTP hosts, such as Gmail, enforce restrict security roles about the source app that requests emails. See [this note](https://nodemailer.com/using-gmail/) on how to configure your account to avoid your emails from being rejected by the server.  

---
## How to setup and run the sample pipeline
If you want to see the full sample pipeline provided in action, here is how you can set it up on your own Concourse server:

##### Pre-requisites to setup this example on your Concourse server

1. An instance of [Concourse installed](http://concourse.ci/installing.html) up-and-running.  
1. The [Concourse Fly command line interface](http://concourse.ci/fly-cli.html) installed on your local machine.

##### Configuration steps
1. Clone the sample git repository on your local machine  
     __clone https://github.com/pivotalservices/concourse-pipeline-samples.git__  
     __cd concourse-pipeline-samples/email-with-attachments__  

1. Setup the pipeline credentials file
  * Make a copy of the sample credentials file  
  __cp ci/credentials.yml.sample ci/credentials.yml__  

  * Edit _ci/credentials.yml_ and fill out all the required credentials:  
  .  
_```git-project-url```:_ the URL of the git repositor containing the pipeline scripts  
_```smtp-host```:_ your smtp host  (e.g. ```smtp.gmail.com```)  
_```smtp-port```:_ your smtp server port number  (e.g. ```465```)   
_```smtp-username```:_ your userId/email-address with the smtp server with encoded @ sign  (e.g. ```myemail%40gmai.com```)   
_```smtp-password```:_ your userId/email-address password  
_```email-from```:_ the sender email address without enconding   (e.g. ```myemail@gmail.com```)  
_```email-to```:_ the list of comma separated destination emails without encoding  (e.g. ```him@there.com,her@here.net```)   

3. Configure the sample pipeline in Concourse with the following commands:  
   __fly -t <your-concourse-alias> set-pipeline -p email-pipeline -c ci/pipeline.yml -l ci/credentials.yml__  

4. Access to the Concourse web interface, click on the list of pipelines, un-pause the _email-pipeline_ and then click on its link to visualize its pipeline diagram
5. To execute the pipeline, click on the ```send-email-with-attachment``` job and then click on the ```+``` sign to execute the pipeline.

The recipients listed you your ```email-from``` parameter should receive an email shortly after the pipeline is run successfully.

--------------
**Note 1**: as of the writing of this sample, the existing email resources for Concourse do not provide a mechanism to attach files to emails (or at least they are not documented), thus the motivation to write another simple email mechanism like this.  
**Note 2**: the assets created in this sample (e.g. scripts and docker image) can be used as the starting point for a new email resource implementation for Concourse. Time permitting, that may be my next small project in the near future.
