# --------------------------------------------------
# Sandbox Environment Variables
# --------------------------------------------------

application_name       = "realtimeinsurance"
env_tier               = "sandbox"
destination_account_id = "332504859566"
vpc_id                 = ""
entra_audience         = "YOUR_ENTRA_AUDIENCE"
lambda_subnet_ids      = ["subnet-xxxx", "subnet-yyyy"]
aurora_subnet_ids      = ["subnet-xxxx", "subnet-yyyy"]
db_engine_mode         = "serverless"
is_production          = false

# SOAP API Gateway
truststore_bucket        = "kfbmic-mtls-truststore-sandbox"
truststore_key           = "truststore.pem"
soap_domain_name         = "soap-sandbox.example.com"
soap_acm_certificate_arn = "arn:aws:acm:us-east-1:YOUR_ACCOUNT_ID:certificate/YOUR_CERT_ID"
