resource "aws_db_instance" "postgres" {
  identifier = "flask-ask-db"
  engine = "postgres"
  engine_version = "15"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  storage_type = "gp2"
  db_name = "stocktracker"
  username = "dbadmin"
  password = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot = true
  publicly_accessible = false

  tags = {
    Name = "flask-app-db"
  }
}
output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}