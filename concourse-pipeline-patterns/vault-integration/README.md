![Vault image](https://raw.githubusercontent.com/lsilvapvt/misc-support-files/master/docs/icons/concourse-and-vault.png)

# How to integrate Concourse pipelines with Vault

Starting in release 3.3.1, Concourse supports the [retrieval of pipeline credentials directly from a HashiCorp's Vault server](http://concourse.ci/creds.html) during a pipeline's execution time. This feature eliminates the need to feed credentials to pipelines via plain-text parameter files, which is a major security enhancement for Concourse pipelines.  

From a pipeline definition standpoint, to have Vault secrets retrieved by Concourse, you simply need to add the desired secret name to a `resources` or `params` section of the pipeline with surrounding double parenthesis, for example:

```
jobs:
- name: hello-world
  plan:
  - task: say-hello
    params:
      SYS_USERNAME: ((vault-system-username))
```

Then, when Concourse runs that pipeline/job, it will search for the corresponding secret in Vault, using a [pre-determined search order](http://concourse.ci/creds.html#vault), and execute the task appropriately with the retrieved values.

Hint: you may not need to touch an existing pipeline YML files at all in order to replace its current double curly brackets `{{ }}` variables with double parenthesis `(( ))` variables, instead, you can simply change the parameter files that feed the pipeline setup during the `fly` CLI command execution.

For example, if your `hello-world.yml` looks like this:

```
jobs:
- name: hello-world
  plan:
  - task: say-hello
    params:
      SYSTEM_PASSWORD: {{system-password}}
    ...
```

and your `params.yml` file looked like this:

```
---
system-password: mypassw0rd123
```

Then you can simply change `params.yml` to contain the secret key from Vault:

```
---
system-password: ((system-password-from-vault-key))
```

Once you update that pipeline in Concourse with the `fly` CLI, the vault key ID will be injected into the pipeline YML along with the double parenthesis and it will work just fine.  

The most involving steps to make the Concourse-Vault integration work consists are the actual configuration of the Vault and Concourse servers as follows.

# Configuring the Vault server

These instructions assume that you already have a Vault server up and running. Please refer to [Vault's installation documentation](https://www.vaultproject.io/docs/install/index.html) for more information.

On an [unsealed](https://www.vaultproject.io/docs/concepts/seal.html) Vault server while authenticated with a [root token](https://www.vaultproject.io/docs/concepts/tokens.html), perform the following configuration steps using the [Vault CLI](https://www.vaultproject.io/docs/commands/index.html):

* Create a mount in value for use by concourse pipelines  
  `vault mount -path=/concourse -description="Secrets for concourse pipelines" generic`  

* Create a policy file (e.g. `policy.hcl`) with the following content  

  ```path "concourse/*" {
    policy = "read"
    capabilities =  ["read", "list"]
  }
  ```  

* Register the policy above with Vault  
  `vault policy-write policy-concourse policy.hcl`

* Initialize Vault and create a periodic token using the new policy  
  `vault token-create --policy=policy-concourse -period="600h" -format=json`  
  Write down the token number created.  

* Populate all the variables in Vault under `concourse/<team-name>/`  

  - Write secrets to Vault using the following syntax  
    `vault write concourse/<team-name>/<variable-name> value=<variable-value>`  

    Examples:  
    `vault write concourse/main/username value=admin`   
    `vault write concourse/pcf/om-password value=pa$$w0rd`   

  -  Hint: all common parameters used across multiple pipelines within a Concourse team can be defined in `concourse/<team-name>/` and pipeline specific parameters can be defined in `concourse/<team-name>/<pipeline-name>`  


# Configuring the Concourse server

Copy the token value from the step above and set it in the Concourse server.

* For binary-based Concourse deployments, see [the Concourse documentation](http://concourse.ci/creds.html) for required setup.

* For Bosh-based Concourse deployments, update the `atc` job properties in the deployment manifest as described below and then redeploy Concourse:

```...
instance_groups:
- name: web ...
  jobs:
  - name: atc
    release: concourse
    properties: ...
      vault:
        path_prefix: /concourse
        url: YOUR-VAULT-ADDRESS-GOES-HERE  # e.g. http://192.168.10.15:8200
        auth:
          client_token: YOUR-VAULT-TOKEN-GOES-HERE
```  

For a complete list of vault setup parameters for the `atc` job, please consult the [ATC job's documentation](https://bosh.io/jobs/atc?source=github.com/concourse/concourse#p=vault).


Run the pipelines and you should see secret keys being replaced with the corresponding values retrieved by Concourse from the Vault server.

For more information, please refer to Concourse's [Credentials Management documentation page](http://concourse.ci/creds.html).

#### [Back to Concourse Pipeline Patterns](..)
