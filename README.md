# Cloud Desktop

## What does this code do ?

- Spins up an EC2 Ubuntu Focal (:heart:) 
- Configures it with my most used softwares - VSCode,NMap,Nuclei,Semgrep,awscli and some pentest tools.
- Configures the IDE on a domain of your choice, provided its configured in Route53.
- Have a Source IP restriction such that it is accessible only from a specific IP Address like my home ip.

## Setup

- Firstly, you need a hosted zone in your Route53 , for this fire the below command using an privileged user in AWS.
`aws route53 create-hosted-zone --name www.domain.com --caller-reference $(date +%s)`

> if you have a sub-domain, you can enter the sub-domain too , but your Domain Authority must support DNS delegation for sub-domains.

- Fire the following command to setup the variables
`mv terraform.auto.tfvars.bak terraform.auto.tfvars`

- Populate the `terraform.auto.tfvars` file with requisite parameter values

- Being in the same directory as this repository, fire the following command

`terraform init && terraform apply --auto-approve`

## Destroy

- To destroy the environment fire the following command

`terraform destroy --auto-approve`

- Destroy the Hosted Zone else you'll be charged $0.5 USD per month

`aws route53 delete-hosted-zone --id $(aws route53 list-hosted-zones --query "HostedZones[?Name == 'www.domain.com.'].Id" --output text | sed 's|/hostedzone/||')`



