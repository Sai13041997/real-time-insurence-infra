# --------------------------------------------------
# Ingest REST API Gateway
# Used for Guidewire App Event webhook integration
# JWT authentication via Entra
# --------------------------------------------------

module "api_gateway" {
  source        = "git::https://github.com/kfbmic/tf-module-api-gateway.git?ref=main"
  name          = "${var.application_name}-${var.env_tier}-api-gateway"
  is_production = false
  jwt_audience  = ["${var.entra_audience}"]

  routes = [
    {
      # Health check endpoint
      path       = "/hello"
      method     = "GET"
      lambda_arn = module.hello_lambda.lambda_function_arn
    }
  ]
}

# --------------------------------------------------
# SOAP API Gateway (Kentucky IVS integration)
# Receives SOAP 1.1 CoverageRequest from Kentucky IVS
# mTLS authentication using Kentucky IVS client cert
# Truststore stored in S3 bucket
# Routes to Lambda SOAP Handler
# --------------------------------------------------

module "soap_api_gateway" {
  source        = "git::https://github.com/kfbmic/tf-module-api-gateway.git?ref=main"
  name          = "${var.application_name}-${var.env_tier}-soap-api-gateway"
  is_production = var.is_production

  # No JWT - mTLS handles authentication
  jwt_audience = []

  # mTLS configuration
  # Truststore contains Kentucky IVS client certificate
  mtls_enabled        = true
  truststore_uri      = "s3://${var.truststore_bucket}/${var.truststore_key}"
  custom_domain_name  = var.soap_domain_name
  acm_certificate_arn = var.soap_acm_certificate_arn

  routes = [
    {
      # SOAP verification endpoint
      # Kentucky IVS sends CoverageRequest SOAP XML here
      path       = "/verify"
      method     = "POST"
      lambda_arn = module.sample_lambda.lambda_function_arn
    }
  ]
}
