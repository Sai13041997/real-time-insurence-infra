module "soap_api_gateway" {
  source        = "git::https://github.com/kfbmic/tf-module-api-gateway.git?ref=v1.1.0"
  name          = "${var.application_name}-${var.env_tier}-soap-api-gateway"
  is_production = false
  jwt_audience  = ["${var.entra_audience}"]

  custom_ip_whitelist = [
    "192.0.2.10/32",   # replace with real SOAP consumer IP
    "192.0.2.20/32",   # replace with real SOAP consumer IP
    "198.51.100.5/32", # replace with real SOAP consumer IP
  ]

  domain_name              = var.soap_api_domain_name
  regional_certificate_arn = aws_acm_certificate.soap_api.arn
  mtls_truststore_uri = "s3://${aws_s3_bucket.soap_api_truststore.bucket}/soap-truststore/truststore.pem"
  
  routes = [
    {
      path       = "/soap"
      method     = "GET"
      lambda_arn = module.sample_lambda.lambda_function_arn
    }
  ]
}
