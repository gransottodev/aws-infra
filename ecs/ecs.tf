resource "aws_ecs_cluster" "application_cluster" {
  name = "application-cluster"
}

resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs-service-sg"
  description = "Security group for ECS service"
  vpc_id      = var.vpc_id

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

  tags = {
    Name = "ecs-service-sg"
  }
}

resource "aws_ecs_service" "application-service" {
  name            = "application-service"
  cluster         = aws_ecs_cluster.application_cluster.id
  task_definition = aws_ecs_task_definition.application_task.arn
  desired_count   = 2

  launch_type = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet]
    security_groups  = [aws_security_group.ecs_service_sg.id]
  }
}

resource "aws_ecs_task_definition" "application_task" {
  family = "application-task"
  container_definitions = jsonencode([{
    name      = "application-container"
    image     = "${var.repository_url}:latest"

    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

    required_compatibilities = ["FARGATE"]

    cpu       = 256
    memory    = 512

    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/application"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "repository_url" {
  description = "ECR repository URL"
  type        = string
}

variable "private_subnet" {
  description = "Private subnet ID"
  type        = string
}
