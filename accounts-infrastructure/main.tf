provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
  region     = "${var.AWS_REGION}"
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




# resource "aws_lb_target_group" "nodejs_app" {
#   name        = "${local.aws_alb_target_group_name}"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = data.terraform_remote_state.main_infrastructure.outputs.vpc_id
#   target_type = "ip"
# }

# resource "aws_lb_listener" "port_80_listener" {
#   load_balancer_arn = data.terraform_remote_state.main_infrastructure.outputs.load_balancer_id
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     target_group_arn = aws_lb_target_group.nodejs_app.id
#     type             = "forward"
#   }
# }

# data "aws_iam_role" "ecs_task_execution_role" {
#   name = "ecsTaskExecutionRole"
# }

# data "aws_ecr_repository" "nodejs_app" {
#   name = "${local.aws_ecr_repository_name}"
# }

# resource "aws_ecs_task_definition" "nodejs_app" {
#   family                   = "${local.aws_ecs_service_name}"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = 1024
#   memory                   = 2048
#   execution_role_arn       = "${data.aws_iam_role.ecs_task_execution_role.arn}"

#   container_definitions = <<DEFINITION
#     [
#       {
#         "essential": true,
#         "image": "${data.aws_ecr_repository.nodejs_app.repository_url}",
#         "cpu": 1024,
#         "memory": 2048,
#         "name": "${local.aws_ecs_service_name}",
#         "networkMode": "awsvpc",
#         "portMappings": [
#           {
#             "containerPort": 80,
#             "hostPort": 80,
#             "protocol" : "tcp"
#           }
#         ]
#       }
#     ]
#     DEFINITION
# }

# resource "aws_security_group" "nodejs_app_task" {
#   name        = "${local.aws_ecs_service_security_group_name}"
#   vpc_id      = data.terraform_remote_state.main_infrastructure.outputs.vpc_id

#   ingress {
#     protocol        = "tcp"
#     from_port       = 80
#     to_port         = 80
#     security_groups = [data.terraform_remote_state.main_infrastructure.outputs.load_balancer_security_group_id]
#   }

#   egress {
#     protocol    = "-1"
#     from_port   = 0
#     to_port     = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_ecs_service" "nodejs_app" {
#   name            = "${local.aws_ecs_service_name}"
#   cluster         = data.terraform_remote_state.main_infrastructure.outputs.cluster_id
#   task_definition = aws_ecs_task_definition.nodejs_app.arn
#   launch_type     = "FARGATE"
#   desired_count   = 1

#   network_configuration {
#     security_groups = [aws_security_group.nodejs_app_task.id]
#     subnets         = data.terraform_remote_state.main_infrastructure.outputs.private_subnets
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.nodejs_app.id
#     container_name   = "${local.aws_ecs_service_name}"
#     container_port   = 80
#   }

#   depends_on = [aws_lb_listener.port_80_listener]
# }
