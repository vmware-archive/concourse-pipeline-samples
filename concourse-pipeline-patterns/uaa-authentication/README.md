<img src="https://dtb5pzswcit1e.cloudfront.net/assets/images/product_logos/icon-concourse@2x.png" alt="Concourse" height="70"/>&nbsp;
<img src="https://dtb5pzswcit1e.cloudfront.net/assets/images/product_logos/icon_ipsec_add_on@2x.png" alt="PCF" height="70"/>





# Authenticating Concourse team members with PCF UAA

Concourse can be [integrated with a Cloud Foundry UAA server](http://concourse.ci/teams.html#uaa-cf-auth) to authenticate and authorize members of a specific team based on CF Organization/Space membership.

The authorization of the users for a Concourse team is validated against the user membership of a specific `space` in Cloud Foundry.

```
┌────────────────────────────────────────────────────────┐                                    
│                                                        │                                    
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─                ┌────────────┐   │             ┌─────────────────────┐
│   Orgs and Spaces DB: │               │            │   │             │ ┌─────────┐         │
│  │      - Org 1                       │            │ ◀─┼────────────▶│ │         │         │
│          - Space 1  ◀─┼──────────────▶│            │   │             │ │ Team 1  │         │
│  │         - user1                    │    UAA     │   │   Auth      │ │         │         │
│            - user2    │               │            │   │             │ └─────────┘         │
│  │          ...                       │            │   │             │                     │
│                       │               │            │   │             │      Concourse      │
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─                │            │   │             │                     │
│                          PCF          └────────────┘   │             └─────────────────────┘
│                                                        │                                    
└────────────────────────────────────────────────────────┘                                    
```

Such integration requires two steps:

#### 1. Create a client-id and a client-secret on the UAA server side

Concourse needs to have a UAA client-id and client-secret to be able to request UAA to authenticate and authorize team user logins.

From a machine that can connect to PCF UAA (e.g. PCF Ops Managr VM) and where the [UAAC cli](https://docs.cloudfoundry.org/uaa/uaa-user-management.html) is installed, create a client ID/secret. For example:

```
uaac target uaa.<pcf-system-domain> --skip-ssl-validation

uaac token client get admin   
     ## get the admin secret from Ops Mngr > Elastic Runtime > Credentials > UAA - Admin Client Credentials )

uaac client add concourse \
  --name concourse \
  --scope cloud_controller.read \
  --authorized_grant_types "authorization_code,refresh_token" \
  --access_token_validity 3600 \
  --refresh_token_validity 3600 \
  --secret <your-client-secret-goes-here> \     
  --redirect_uri https://<your-concourse-domain>/auth/uaa/callback
```


#### 2. Configure a Concourse team that delegates authentication to UAA

From a machine that can connect to Concourse via [FLY cli](http://concourse.ci/fly-cli.html), set the Concourse team with UAA authentication:

```
fly -t <your-target> set-team -n <team-name> \
  --uaa-auth-client-id concourse \
  --uaa-auth-client-secret <your-client-secret-goes-here> \
  --uaa-auth-auth-url https://login.<pcf-system-domain>/oauth/authorize \
  --uaa-auth-token-url https://login.<pcf-system-domain>/oauth/token \
  --uaa-auth-cf-url https://api.<pcf-system-domain>\
  --uaa-auth-cf-space <space-guid> \             ## cf space <space-name> --guid
  --uaa-auth-cf-ca-cert <file-with-root-CA.crt>      
         ## get trusted certs from PCF Ops Mgr Director tile > Settings tab > Security > Trusted Certificates field
```

After the team is created, you can go to the Concourse UI and try to login into the new team.
You should get re-routed to the UAA login page (e.g. PCF login) and then sent back to the Concourse UI once authenticated.

#### [Back to Concourse Pipeline Patterns](..)
