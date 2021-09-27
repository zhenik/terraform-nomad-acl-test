# Terraform nomad acl test

Unexpected response code: 403 (Permission denied) for Nomad ACL bootstrap token on second deploy.
```
❯ terraform apply
module.some_dependency.time_sleep.simulate_nomad_vm_deploy: Refreshing state... [id=2021-09-27T09:30:16Z]
nomad_acl_policy.dev: Refreshing state... [id=tezt1]

Error: error checking for ACL policy "tezt1": &errors.errorString{s:"Unexpected response code: 403 (Permission denied)"}
```

## Steps to reproduce
1. `make` - run vagrant box with consul, vault and nomad (software available on localhost ports [:8500](http://localhost:8500), [:8200](http://localhost:8200) and [:4646](http://localhost:4646) )
2. `terraform init && terraform apply`
```terraform
module.some_dependency.time_sleep.simulate_nomad_vm_deploy: Creating...
module.some_dependency.time_sleep.simulate_nomad_vm_deploy: Creation complete after 2s [id=2021-09-27T09:30:16Z]
data.vault_generic_secret.nomad_bootstrap_token: Reading...
data.vault_generic_secret.nomad_bootstrap_token: Read complete after 0s [id=secret/example/nomad-bootstrap-token]
nomad_acl_policy.dev: Creating...
nomad_acl_policy.dev: Creation complete after 0s [id=tezt1]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```
3. Deployment is successful. terraform exit 0
4. Uncomment line 8 in [main.tf](main.tf)
```terraform
//  wait_time = "1s"
```
to
```terraform
wait_time = "1s"
```
5. `terraform apply`
```
❯ terraform apply
module.some_dependency.time_sleep.simulate_nomad_vm_deploy: Refreshing state... [id=2021-09-27T09:30:16Z]
nomad_acl_policy.dev: Refreshing state... [id=tezt1]

Error: error checking for ACL policy "tezt1": &errors.errorString{s:"Unexpected response code: 403 (Permission denied)"}
```
## Problem
Unexpected response code: 403 (Permission denied)

### Additional Log

Show terraform state list
```
❯ terraform state list
data.vault_generic_secret.nomad_bootstrap_token
nomad_acl_policy.dev
module.some_dependency.time_sleep.simulate_nomad_vm_deploy
```
Show terraform state of resource `data.vault_generic_secret.nomad_bootstrap_token`
```
❯ terraform state show data.vault_generic_secret.nomad_bootstrap_token
# data.vault_generic_secret.nomad_bootstrap_token:
data "vault_generic_secret" "nomad_bootstrap_token" {
    data             = (sensitive value)
    data_json        = (sensitive value)
    id               = "secret/example/nomad-bootstrap-token"
    lease_duration   = 0
    lease_renewable  = false
    lease_start_time = "RFC1111119"
    path             = "secret/example/nomad-bootstrap-token"
    version          = -1
}
```

Read nomad acl token from generic secret backend on nomad (its stored there for test purposes)
```
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=master
❯ vault kv get secret/example/nomad-bootstrap-token
====== Metadata ======
Key              Value
---              -----
created_time     2021-09-27T09:18:44.406899036Z
deletion_time    n/a
destroyed        false
version          1

======= Data =======
Key            Value
---            -----
accessor-id    3887104e-081a-c052-6eed-6f515a4ee4f8
secret-id      e79ff38f-4652-f8de-3ec7-452a20f1b133
```

Token is ok. It is acl nomad bootstrap token which has access to all resources in nomad cluster. 
```
❯ export NOMAD_TOKEN=e79ff38f-4652-f8de-3ec7-452a20f1b133
❯ export NOMAD_ADDR=http://localhost:4646
❯ nomad acl policy list
Name             Description
consumer-policy  Consumer policy
producer-policy  Producer policy
tezt1            Submit jobs to the dev environment.
❯ nomad acl policy info tezt1
Name        = tezt1
Description = Submit jobs to the dev environment.
Rules       = namespace "dev" {
  policy = "write"
}
CreateIndex = 27
ModifyIndex = 27
```


## Versions

### Providers
versions:
- hashicorp/time v0.7.2
- hashicorp/nomad v1.4.15
- hashicorp/vault v2.24.0

### Hashistack
Vault, consul and nomad dev mode cluster based on [vagrant-hashistack](https://github.com/Skatteetaten/vagrant-hashistack)

[Vagrant-hashistack](https://github.com/Skatteetaten/vagrant-hashistack)

| Software        | version           |
| ------------- |:-------------:|
| terraform | 0.14.9 |
| nomad | 1.0.2 |
| consul | 1.9.1 |
| vault | 1.6.1 |
