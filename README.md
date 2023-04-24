# Christopher Robin, a honey pot story

## Prerequisites for OSX

[brew](https://docs.brew.sh/Installation) must be installed


## Installation

All install steps are compatible with MacOS

Install `terraform`

```bash
# install from hashicorp tap
$ brew tap hashicorp/tap
$ brew install hashicorp/tap/terraform
$ brew update
$ brew upgrade hashicorp/tap/terraform

# verify install, v1.4 is latest when this doc was written
$ terraform --version
```

### AWS

Install `aws` cli, instructions can be found [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). v2.11.X is latest as of creation of this doc.

**Note:** Prior to running `terraform plan` ensure that `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` is configured correctly

### Azure

Prior to provisioning infra via terraform, complete the following:

1. Create a [Microsoft Azure account](https://azure.microsoft.com/free/)
2. Install [AzureRM Client](https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-windows-bash?tabs=bash)
3. Login via az client `az login`

### GCP

Prior to booting up infrastructure complete the following:

1. Create a GCP account
2. Create a GCP project
3. Create a related service account for the project

### Environment Variables / Runtime environments

- You must create a `terraform.tfvars` file that matches the example at `root/infra/terraform/terraform.tfvars` to provision resources

- To run data analysis scripts and produce artifacts you must install the python runtime dependencies defined at `root/analysis/requirements.txt` 

- To run the honeypot you must install python runtime requirements defined at `root/honey_pot/requirements.txt`


## Walkthrough

I suggest walking through the code in the following order to better understand the capabilities of this projects

- Honeypot code can be found at `root/honey_pot/app.py` this is the dev flask app, production honeypot runs via wsgi server

- Infrastructure code is defined in `root/infra`, here you can see terraform code, specifically 4 modules: core, aws, azure, gcp

- Lambda code can be found at `root/infra/lambdas` these do no work locally, and can only be tested via AWS console. There are two lambdas `data_writer` and `data_ingest` 

- Raw and scrubbed data can be found at `root/data` 

- Scripts to massage and analyze the data can be found at `root/analysis` 

- Artifacts (charts/graphs/etc) can be found at `root/analysis/artifacts`
