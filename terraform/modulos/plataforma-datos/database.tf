resource "aws_db_instance" "rds_instance" {
  #checkov:skip=CKV_AWS_157: Entorno de demostracion de una sola zona; Multi-AZ duplica el costo de la instancia.
  #checkov:skip=CKV_AWS_118: El monitoreo avanzado requiere un rol IAM adicional y tiene costo; se usa CloudWatch basico.
  identifier            = "plataforma-datos-rds-instance"
  db_name               = "plataformadatosdb"
  allocated_storage     = 20
  engine                = "mysql"
  engine_version        = "8.0.35"
  instance_class        = "db.t3.micro"
  username              = "admin"
  password              = random_password.rds_password.result
  parameter_group_name  = "default.mysql8.0"
  skip_final_snapshot   = true
  storage_encrypted     = true
  copy_tags_to_snapshot = true

  deletion_protection                 = var.deletion_protection
  iam_database_authentication_enabled = true
  enabled_cloudwatch_logs_exports     = ["error", "general", "slowquery"]

  auto_minor_version_upgrade = true
  vpc_security_group_ids     = [aws_security_group.rds_sg.id]
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet_group.name
}

resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
