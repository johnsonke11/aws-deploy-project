resource aws_iam_role "ecs_task_execution_role"{
    name = "ecs_task_execution_role"
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
        }
    )
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_policy" "secrets_policy" {
  name = "ecs-secrets-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "secretsManager:GetSecretValue"
            ]
            Resource = aws_secretsmanager_secret.db_url.arn
        }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "secrets_policy_attachment" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets_policy.arn
}
resource "aws_iam_policy" "logs_policy" {
  name = "ecs_logs_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
            Resource = "arn:aws:logs:us-east-1:882282737373:*"
        }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "logs_policy_attachment" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.logs_policy.arn
}