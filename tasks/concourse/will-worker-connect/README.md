<img src="https://pivotal.gallerycdn.vsassets.io/extensions/pivotal/vscode-concourse/0.1.3/1517353139519/Microsoft.VisualStudio.Services.Icons.Default" alt="Concourse" height="70"/>&nbsp;&nbsp;<img src="https://png.icons8.com/color/1600/disconnected.png" alt="Connectivity" height="70"/>

## Test Worker Connectivity

This sample task can be used to test connectivity from Concourse workers to a routable network address.

Under the covers, the task simply issues a `curl` command targeted at the provided `CONNECT_TO_URL` parameter and with extra command options from `EXTRA_COMMAND_PARAMETERS`.


#### What to use this task for

To quickly test the connectivity from Concourse workers (or even from specific set of tagged workers when using the `tag` option) to a defined domain name or ip address.


#### How to use this task

This task can be used as part of a pipeline, but the easiest way to use it is with the `fly execute` command.

1. Clone this repository and then cd into the parent folder of this README.  
   e.g. `cd concourse-pipeline-samples/tasks/concourse/will-worker-connect`

2. Using `fly` CLI, login to Concourse   

   e.g `fly -t mytarget login`    

3. Set the task parameters as environment variables  

     `export CONNECT_TO_URL="http://google.com"`  
     `export EXTRA_COMMAND_PARAMETERS="-k --connect-timeout 10"`  

4. Execute the `fly execute` command for the task  

   e.g. to test connectivity from a default worker:  
   `fly -t mytarget execute -c ./task.yml`  

   e.g. to test connectivity from a tagged worker:  
   `fly -t mytarget execute -c ./task.yml --tag my-worker-tag`  

The task will be executed and the connection test result from the `curl` command will be displayed in the command's output.
