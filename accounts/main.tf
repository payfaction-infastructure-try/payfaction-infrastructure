provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
  region     = "${var.AWS_REGION}"
}

provider "circleci" {
  api_token    = "${CIRCLECI_API_TOKEN}"
  vcs_type     = "${CIRCLECI_VCS_TYPE}"
  organization = "${CIRCLECI_ORGANIZATION}"
}

data "terraform_remote_state" "main_infrastructure" {
  backend = "remote"
  config = {
    organization = "${var.REMOTE_ORGANIZATION}"
    workspaces = {
      name = "${var.REMOTE_WORKSPACE}"
    }
  }
}

module "vpc" {
  source  = "../app_infrastructure"

  aws_resource_name_prefix = var.AWS_RESOURCE_NAME_PREFIX
  vpc_id = data.terraform_remote_state.main_infrastructure.outputs.vpc_id
  load_balancer_id =  data.terraform_remote_state.main_infrastructure.outputs.load_balancer_id
  load_balancer_security_group_id = data.terraform_remote_state.main_infrastructure.outputs.load_balancer_security_group_id
  cluster_id = data.terraform_remote_state.main_infrastructure.outputs.cluster_id
  private_subnets = data.terraform_remote_state.main_infrastructure.outputs.private_subnets
}

resource "circleci_context" "context" {
  name  = "${var.AWS_RESOURCE_NAME_PREFIX}"
}

resource "circleci_context_environment_variable" "context" {
  for_each = {
    AWS_RESOURCE_NAME_PREFIX = "${var.AWS_RESOURCE_NAME_PREFIX}"
  }

  variable   = each.key
  value      = each.value
  context_id = circleci_context.aws.id
}
