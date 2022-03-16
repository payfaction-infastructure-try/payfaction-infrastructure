variable "AWS_ACCESS_KEY_ID" {
    description = "AWS access key id"
}

variable "AWS_SECRET_ACCESS_KEY" {
    description = "AWS secret access key"
}

variable "AWS_REGION" {
  description = "AWS region e.g. us-east-1 (Please specify a region supported by the Fargate launch type)"
}

variable "AWS_RESOURCE_NAME_PREFIX" {
  description = "Should be named as image name in ecr repository. Prefix to be used in the naming of some of the created AWS resources e.g. demo-webapp"
}

variable "REMOTE_ORGANIZATION" {
  description = "Organization name which remote state should be used"
}

variable "REMOTE_WORKSPACE" {
  description = "Workspace name which remote state should be used"
}
