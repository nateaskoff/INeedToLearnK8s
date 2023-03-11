### main TG file
terraform {
  source = "module/"
}

locals {
  TF_HOSTNAME             = "app.terraform.io"
  TF_ORG                  = "INeedToLearnK8s"
  TF_VERSION              = get_env("TF_VERSION")
  TF_AWS_PROVIDER_VERSION = get_env("TF_AWS_PROVIDER_VERSION")

  AWS_ACCESS_KEY_ID     = get_env("AWS_ACCESS_KEY_ID")
  AWS_SECRET_ACCESS_KEY = get_env("AWS_SECRET_ACCESS_KEY")
  AWS_ACCOUNT_ID        = get_env("AWS_ACCOUNT_ID")
  AWS_ENV               = get_env("AWS_ENV")
  AWS_REGION            = get_env("AWS_REGION")
  AWS_ROLE_NAME         = get_env("AWS_ROLE_NAME")
  AWS_REGION_SHORT      = join("", [for tok in split("-", local.AWS_REGION) : substr(tok, 0, 1)])
  TF_WORKSPACE          = "INTLK-${upper(local.AWS_ENV)}-${upper(local.AWS_REGION_SHORT)}"

}

generate "terragrunt-tfvars" {
  path              = "terragrunt.auto.tfvars"
  if_exists         = "overwrite"
  disable_signature = true
  contents          = <<-EOF
  aws_env              = "${local.AWS_ENV}"
  aws_region           = "${local.AWS_REGION}"
  aws_tf_rel_role_name = "${local.AWS_ROLE_NAME}"
EOF
}

generate "versions-tf" {
  path              = "versions.tf"
  if_exists         = "overwrite"
  disable_signature = true
  contents          = <<-EOF
terraform {
  required_version = ">= ${local.TF_VERSION}"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> ${local.TF_AWS_PROVIDER_VERSION}"
    }
  }
}
EOF
}

generate "remote-state-tf" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "remote" {
    hostname      = "${local.TF_HOSTNAME}"
    organization  = "${local.TF_ORG}"
    workspaces {
      name = "${local.TF_WORKSPACE}"
    }
  }
}
EOF
}

generate "provider-tf" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
provider "aws" {
  region      = "${local.AWS_REGION}"
  access_key  = "${local.AWS_ACCESS_KEY_ID}"
  secret_key  = "${local.AWS_SECRET_ACCESS_KEY}"
  assume_role {
    role_arn = "arn:aws:iam::${local.AWS_ACCOUNT_ID}:role/${local.AWS_ROLE_NAME}"
  }
}
EOF
}
