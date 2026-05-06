module "hello_lambda" {
  source      = "git::https://github.com/kfbmic/tf-module-lambda-function.git?ref=v1.0.0"
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

module "sample_lambda" {
  source      = "git::https://github.com/kfbmic/tf-module-lambda-function.git?ref=v1.0.0"
  name = "${var.application_name}-${var.env_tier}-sample-lambda"
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
