# Catalogue MySQL (Sock Shop) - single-AZ lab. Password lives in Secrets Manager (not git).

resource "random_password" "catalogue_db" {
  length  = 24
  special = false
}

resource "aws_db_subnet_group" "catalogue" {
  name       = "${var.name_prefix}-catalogue"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name      = "${var.name_prefix}-catalogue"
    Component = "rds-catalogue"
  }
}

resource "aws_security_group" "catalogue_db" {
  name_prefix = "${var.name_prefix}-catalogue-db-"
  description = "RDS MySQL catalogue - allow 3306 from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  # No open egress: SG is stateful; return traffic for allowed ingress is permitted.

  tags = {
    Name      = "${var.name_prefix}-catalogue-db"
    Component = "rds-catalogue"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# checkov:skip=CKV_AWS_157:Lab uses single-AZ RDS to control cost
# checkov:skip=CKV_AWS_353:Lab disables Performance Insights
# checkov:skip=CKV_AWS_354:Lab disables Performance Insights
resource "aws_db_instance" "catalogue" {
  identifier = "${var.name_prefix}-catalogue"

  engine                = "mysql"
  engine_version        = var.catalogue_db_engine_version
  instance_class        = var.catalogue_db_instance_class
  allocated_storage     = var.catalogue_db_allocated_storage
  max_allocated_storage = var.catalogue_db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.catalogue_db_name
  username = var.catalogue_db_username
  password = random_password.catalogue_db.result
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.catalogue.name
  vpc_security_group_ids = [aws_security_group.catalogue_db.id]
  publicly_accessible    = false
  multi_az               = false
  availability_zone      = var.azs[0]

  backup_retention_period = var.catalogue_db_backup_retention_period
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  tags = {
    Name      = "${var.name_prefix}-catalogue"
    Component = "rds-catalogue"
    App       = "sockshop-catalogue"
  }

  depends_on = [module.eks]
}

# checkov:skip=CKV2_AWS_57:Lab rotates catalogue DB secret manually / out-of-band
resource "aws_secretsmanager_secret" "catalogue_db" {
  name                    = "${var.name_prefix}/sockshop/catalogue-db"
  description             = "Sock Shop catalogue MySQL credentials (RDS)"
  recovery_window_in_days = 0

  tags = {
    Name      = "${var.name_prefix}-catalogue-db"
    Component = "rds-catalogue"
  }
}

resource "aws_secretsmanager_secret_version" "catalogue_db" {
  secret_id = aws_secretsmanager_secret.catalogue_db.id
  secret_string = jsonencode({
    engine   = "mysql"
    host     = aws_db_instance.catalogue.address
    port     = aws_db_instance.catalogue.port
    dbname   = aws_db_instance.catalogue.db_name
    username = aws_db_instance.catalogue.username
    password = random_password.catalogue_db.result
    # Go catalogue DSN flag shape
    dsn = "${aws_db_instance.catalogue.username}:${random_password.catalogue_db.result}@tcp(${aws_db_instance.catalogue.address}:${aws_db_instance.catalogue.port})/${aws_db_instance.catalogue.db_name}"
  })
}
