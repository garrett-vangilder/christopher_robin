# Christopher Robin, a honey pot story

## Prerequisites

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
<!-- TODO: Complete pre-reqs -->
