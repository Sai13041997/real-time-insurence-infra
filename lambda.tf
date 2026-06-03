module "hello_lambda" {
  source      = "git::https://github.com/kfbmic/tf-module-lambda-function.git?ref=v1.1.0"
  name = "${var.application_name}-${var.env_tier}-hello-lambda"
  runtime = "python3.13"
  handler = "index.handler"
  timeout     = 10
  memory_size = 128
  code_managed_elsewhere = true
  vpc_enabled = true
  vpc_id      = var.vpc_id
  subnet_ids  = var.lambda_subnet_ids

  tags = {}
}

module "soap_verification_lambda" {
  source      = "git::https://github.com/kfbmic/tf-module-lambda-function.git?ref=v1.1.0"
  name = "${var.application_name}-${var.env_tier}-soap-verification-lambda"
  runtime = "python3.13"
  handler = "main.lambda_handler"
  timeout     = 10
  memory_size = 128
  code_managed_elsewhere = true
  vpc_enabled = true
  vpc_id      = var.vpc_id
  subnet_ids  = var.lambda_subnet_ids
  environment_variables = {
		db_endpoint = aws_rds_cluster.aurora.reader_endpoint
		db_user     = "lambda_svc"
    db_region   = "us-east-1"
    db_name     = "${var.application_name}_${var.env_tier}"
	}
  extra_policy_statements = [
    {
      Effect   = "Allow"
      Action   = ["rds-db:connect"]
      Resource = ["arn:aws:rds-db:us-east-1:${var.destination_account_id}:dbuser:${aws_rds_cluster.aurora.cluster_resource_id}/lambda_svc"]
    }
  ]

  tags = {}
}
