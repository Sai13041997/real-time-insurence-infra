module "soap_api_gateway" {
  source        = "git::https://github.com/kfbmic/tf-module-api-gateway.git?ref=feature/T012SP/CPE-178"  #v1.1.1
  name          = "${var.application_name}-${var.env_tier}-soap-api-gateway"
  is_production = false
  jwt_audience  = null
  
  #["${var.entra_audience}"]

  custom_ip_whitelist = [
    #Non-Producation IPs
    "3.217.110.156/32"   #KentuckyIVS Testing Ip
  ]

  domain_name              = var.soap_api_domain_name
  regional_certificate_arn = aws_acm_certificate.soap_api.arn
  mtls_truststore_uri = "s3://${aws_s3_bucket.soap_api_truststore.bucket}/soap-truststore/truststore.pem"
  
  routes = [
    {
      path       = "/soap"
      method     = "POST"
      lambda_arn = module.soap_verification_lambda.lambda_function_arn
    }
  ]
}
