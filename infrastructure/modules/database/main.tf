resource "aws_db_subnet_group" "rds" {
  name       = "${var.project_name}-rds-subnet"
  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id]
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.project_name}-db"
  engine                  = "postgres"
  engine_version          = "15"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_name                 = "ecommerce"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [var.rds_sg_id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 1

  tags = { Name = "${var.project_name}-db" }
}
