resource "aws_secretsmanager_secret" "db_url" {
  name = "flask-app-db-url"
}
resource "aws_secretsmanager_secret_version" "name" {
  secret_id = aws_secretsmanager_secret.db_url.id
  secret_string = "postgresql://dbadmin:${var.db_password}@flask-app-db.cuxui6ey6cxj.us-east-1.rds.amazonaws.com:5432/stocktracker"
}