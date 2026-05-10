# --------------------------------------------------
# Sandbox Environment Variables
# --------------------------------------------------

application_name       = "realtimeinsurance"
env_tier               = "sandbox"
destination_account_id = "332504859566"
vpc_id                 = "vpc-0678e3b232c59bd64"
entra_audience         = "api://585f3a95-8bf5-4df4-b80b-585ca5ca2071"
lambda_subnet_ids      = ["subnet-012ce60243ca69a31", "subnet-09e1f6bb939d9d0f6"]
aurora_subnet_ids      = ["subnet-012ce60243ca69a31", "subnet-09e1f6bb939d9d0f6"]
db_engine_mode         = "serverless"
is_production          = false

# SOAP API Gateway
truststore_bucket        = "kfbmic-mtls-truststore-sandbox"
truststore_key           = "truststore.pem"
soap_domain_name         = "soap-sandbox.example.com"
soap_acm_certificate_arn = ""
