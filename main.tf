provider "aws" {
  region = "us-east-1"
}

#=========================================

resource "aws_db_subnet_group" "my_subnet" {
  name       = "my_subnet"
  subnet_ids = aws_subnet.private_subnets[*].id
}

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier     = "aurora-cluster-demo"
  engine                 = "aurora-postgresql"
  engine_version         = "13.3"
  availability_zones     = ["us-east-1a", "us-east-1b"]
  database_name          = "chain"
  master_username        = "postgres"
  master_password        = "123"
  db_subnet_group_name   = aws_db_subnet_group.my_subnet.name
  vpc_security_group_ids = ["aws_security_group.my_server.id"]
  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "cluster_instance" {
  count              = 1
  cluster_identifier = aws_rds_cluster.postgresql.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.postgresql.engine
  engine_version     = aws_rds_cluster.postgresql.engine_version
}
