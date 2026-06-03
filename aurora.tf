resource "aws_db_subnet_group" "aurora" {
  name       = "${var.application_name}-${var.env_tier}-db-subnet-group"
  subnet_ids = var.aurora_subnet_ids
  tags = {
    Name = "${var.application_name}-${var.env_tier}-db-subnet-group"
  }
}

module "aurora_security_group" {
  source      = "git::https://github.com/kfbmic/tf-module-vpc-security-group.git?ref=v1.0.0"
  name        = "${var.application_name}-${var.env_tier}-aurora-sg"
  description = "Allows access for developers and applications to connect"
  vpc_id      = var.vpc_id

  inbound_rules = [
    {
      "description" : "Secure Desctops",
      "ip_protocol" : "-1",
      "cidr_ipv4" : "10.214.0.0/16",
    },
    {
      "description" : "App Non Prod",
      "ip_protocol" : "-1",
      "cidr_ipv4" : "10.235.1.0/24",
    },
    {
      "description" : "Non Prod MainFrame",
      "ip_protocol" : "-1",
      "cidr_ipv4" : "10.238.1.0/24",
    },
    {
      "description" : "Non Prod Database",
      "ip_protocol" : "-1",
      "cidr_ipv4" : "10.236.1.0/24",
    },
    {
      "description" : "Genaric Server VLAN",
      "ip_protocol" : "-1",
      "cidr_ipv4" : "10.215.0.0/16",
    },
    {
      "description" : "Shared Services",
      "ip_protocol" : "-1",
      "cidr_ipv4" : "10.217.3.0/24",
    },
    {
      "description" : "Non Prod to Non Prod",
      "ip_protocol" : "-1",
      "cidr_ipv4" : "10.212.0.0/16",
    },
    {
      "description" : "AWS Shared Services",
      "ip_protocol" : "-1",
      "cidr_ipv4" : "10.225.0.0/16",
    },
    {
      "description" : "Avamar",
      "ip_protocol" : "-1",
      "cidr_ipv4" : "10.218.12.0/24",
    },
    {
      "description" : "Non Production F5 App Vlan",
      "ip_protocol" : "-1",
      "cidr_ipv4" : "10.218.17.0/24",
    }
  ]

  outbound_rules = [
    {
      "ip_protocol" : "-1",
      "cidr_ipv4" : "0.0.0.0/0"
    }
  ]
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "${var.application_name}-${var.env_tier}-aurora-cluster"

  engine         = "aurora-postgresql"
  engine_version = "17.7"

  # IMPORTANT:
  # Aurora Serverless v2 uses engine_mode = "provisioned" (Serverless v1 used engine_mode="serverless")
  engine_mode = "provisioned"
  
  master_username             = "kfb_aurora_admin"
  manage_master_user_password = true

  iam_database_authentication_enabled = true
  performance_insights_enabled = true


  skip_final_snapshot     = false
  backup_retention_period = 7
  apply_immediately       = true

  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [module.aurora_security_group.sg_id]

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.db_engine_mode == "serverless" ? [1] : []
    content {
      min_capacity = var.serverless_v2_min_acu
      max_capacity = var.serverless_v2_max_acu
    }
  }

  tags = {
    Name = "${var.application_name}-${var.env_tier}-aurora-cluster"
  }
}

resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${var.application_name}-${var.env_tier}-aurora-cluster-writer"
  cluster_identifier = aws_rds_cluster.aurora.id

  engine         = aws_rds_cluster.aurora.engine
  engine_version = aws_rds_cluster.aurora.engine_version

  # Serverless v2 requires "db.serverless". Provisioned uses your chosen class.
  instance_class = var.db_engine_mode == "serverless" ? "db.serverless" : var.instance_class

  publicly_accessible = false

  tags = {
    Name = "${var.application_name}-${var.env_tier}-aurora-cluster-writer"
  }
}

resource "aws_rds_cluster_instance" "reader" {
  count = var.replicas

  identifier         = "${var.application_name}-${var.env_tier}-aurora-cluster-reader-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora.id

  engine         = aws_rds_cluster.aurora.engine
  engine_version = aws_rds_cluster.aurora.engine_version

  # Serverless v2 requires "db.serverless". Provisioned uses your chosen class.
  instance_class = var.db_engine_mode == "serverless" ? "db.serverless" : var.instance_class

  publicly_accessible = false

  tags = {
    Name = "${var.application_name}-${var.env_tier}-aurora-cluster-reader-${count.index + 1}"
  }
}
