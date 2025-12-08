# --------------------------
# VPC + Networking
# --------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"

  name = "react-app-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = false
}

# --------------------------
# ECR Repository
# --------------------------
resource "aws_ecr_repository" "react_app" {
  name = "react-app"
  image_tag_mutability = "MUTABLE"
  force_delete = true # Change to false if you want to keep images, true for dev work
}

# --------------------------
# ECS Cluster
# --------------------------
resource "aws_ecs_cluster" "this" {
  name = "react-app-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# --------------------------
# Load Balancer
# --------------------------
resource "aws_lb" "public" {
  name               = "react-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "tg" {
  name     = "react-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# --------------------------
# Security Groups
# --------------------------
resource "aws_security_group" "lb_sg" {
  name   = "alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --------------------------
# ECS Task Definition
# --------------------------
resource "aws_ecs_task_definition" "react_app" {
  family                   = "react-app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "react-app"
      image     = "${aws_ecr_repository.react_app.repository_url}:latest"
      essential = true

      portMappings = [{
        containerPort = 8080
        # hostPort      = 8080
      }]
    }
  ])
}

# --------------------------
# ECS Service
# --------------------------
resource "aws_ecs_service" "react_app" {
  name            = "react-app-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.react_app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = module.vpc.public_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "react-app"
    container_port   = 8080
  }

  depends_on = [
    aws_lb_listener.http
  ]
}
