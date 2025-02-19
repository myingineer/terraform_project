# Setting up the RDS instance

## Subnet group for RDS
resource "aws_db_subnet_group" "prod_db_subnet_group" {
  name        = "prod-db-subnet-group"
  description = "Subnet group for RDS instances"

  subnet_ids  = var.private_subnets_id

  tags = {
    Name = "DBSubnetGroup"
  }
}

## Set up the RDS
resource "aws_db_instance" "prod_postgres" {
  engine               = "postgres"   # Specify the PostgreSQL engine
  engine_version       = "13.3"       # Version of PostgreSQL
  multi_az             = true         # Enable multi-AZ deployment for standby
  identifier           = "habit-tracker-instance"  # Database identifier
  allocated_storage    = 10           # Storage size in GB
  storage_type         = "gp2"        # General-purpose SSD storage
  instance_class       = "db.t2.micro" # Small instance type 
  username             = "admin"      # Database admin username
  password             = var.db_password  # Database admin password
  db_subnet_group_name = aws_db_subnet_group.prod_db_subnet_group.name 
  vpc_security_group_ids = [ var.db_sg ] # Security group for the RDS instance
  backup_retention_period = 7         # Backup retention period in days
  publicly_accessible  = false        # Private subnets
  skip_final_snapshot  = true         # Skip snapshot on deletion
  db_name              = "habit-tracker-database"          # Database name

  tags = {
    Name = "prod_postgres_db"
  }
}




