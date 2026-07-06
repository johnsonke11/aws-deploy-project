resource "aws_cloudwatch_event_rule" "stock_fetch" {
  name = "stock-fetch-schedule"
  description = "Fetches stock price every 15 minutes"
  schedule_expression = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "stock_fetch_target" {
  rule = aws_cloudwatch_event_rule.stock_fetch.name
  target_id = "stock-fetch-target"
  arn = aws_lambda_function.stock_fetch.arn
}
resource "aws_lambda_function" "stock_fetch" {
  filename         = "lambda_stock_fetch.zip"
  function_name    = "stock-fetch"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("lambda_stock_fetch.zip")
  environment {
    variables = {
      API_URL = "https://${aws_cloudfront_distribution.flask_api.domain_name}"
    }
  }
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stock_fetch.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stock_fetch.arn
}

resource "aws_iam_role" "lambda_role" {
  name = "stock-fetch-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  }
  )
}
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
