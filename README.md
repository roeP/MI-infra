# MI-infra


### To Discuss
* Use official modules
* Seperate VPC (mgmt+prod)
* dont use default vpc
* eks api is public
* jenkins https
* seperate tf modules repo
* 1 subnet id to save cost
* TF state bucket - enable versioning
* setup packer ami for jenkins + slave
* setup jenkins slave using spot fleet
* add healthchecks
* add resource requests/limits
* mv helm to template




### Manual Steps
* created sh key
* crated tf state bucket
* tag subnets

### To fix
* fix istio request ( small instance )
* fix jenkins random restarts
* enable aws-node-termination-handler (small instance)
