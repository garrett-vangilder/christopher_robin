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

### GCP

Prior to booting up infrastructure complete the following:

1. Create a GCP account
2. 