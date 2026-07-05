resource "aws_ecs_cluster" "main" {
  name = "flask-app-cluster"
}

resource "aws_ecs_task_definition" "flask_app" {
  family                   = "flask-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "flask-app"
      image     = "${aws_ecr_repository.flask_app.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
      secrets = [
        {
          name = "DATABASE_URL"
          valueFrom = aws_secretsmanager_secret.db_url.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" = "/ecs/flask-app"
          "awslogs-region" = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group" = "true"
        }
      }
    }
  ])
}
