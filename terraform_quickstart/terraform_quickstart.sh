# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started

export GOOGLE_APPLICATION_CREDENTIALS="secret-as-dev-ga4-flattener-320623-terraform-test.json"


# https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli?in=terraform%2Fgcp-get-started

brew tap hashicorp/tap

brew install hashicorp/tap/terraform

brew update

brew upgrade hashicorp/tap/terraform

terraform -help

cd terraform_quickstart


terraform init

terraform apply

terraform destroy