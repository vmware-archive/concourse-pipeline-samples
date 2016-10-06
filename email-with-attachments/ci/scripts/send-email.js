var fs = require('fs');
var nodemailer = require("nodemailer");

// create reusable transporter object using the default SMTP transport
var transporter = nodemailer.createTransport('smtps://'+process.env.SMTP_USERNAME+':'+process.env.SMTP_PASSWORD+'@'+process.env.SMTP_HOST+':'+process.env.SMTP_PORT);

var emailSubject="";
if (process.env.EMAIL_SUBJECT_TEXT) {
  emailSubject=process.env.EMAIL_SUBJECT_TEXT;
} else {
  var emailSubjectFile=process.env.EMAIL_SUBJECT_FILE;
  emailSubject=fs.readFileSync(emailSubjectFile, 'utf8');
}

var emailText="";
if (process.env.EMAIL_BODY_TEXT) {
  emailText=process.env.EMAIL_BODY_TEXT;
} else {
  var emailTextFile=process.env.EMAIL_BODY_FILE;
  emailText=fs.readFileSync(emailTextFile, 'utf8');
}

// setup e-mail data with unicode symbols
var mailOptions = {
  from: process.env.EMAIL_FROM,
  to: process.env.EMAIL_TO, // receiver
  subject: emailSubject, // subject
  text: emailText, // body
  html: '<p>'+emailText+'</p>' // html body
};
if (process.env.EMAIL_ATTACHMENTS) {
  mailOptions.attachments=JSON.parse(process.env.EMAIL_ATTACHMENTS);
    // attachment object must be json array with the following format:
    // '[{ "filename": "email-text-success.txt","path": "./email-text/email-text-success.txt", "contentType":"text/plain"}]'
}

// send mail with defined transport object
transporter.sendMail(mailOptions, function(error, info){
    if(error){
        return console.log(error);
    }
    // console.log('Message sent: ' + info.response);
});
