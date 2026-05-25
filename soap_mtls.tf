# ---------------------------------------------------------------------------
# soap_domain.tf  →  real-time-insurance-infra
#
# Route 53 resources use provider = aws.networkacc because devkyfb.com is
# registered in the network account, not the destination account.
#
# The S3 truststore bucket uses the default provider (destination account)
# because it is an application resource, not a DNS resource.
# ---------------------------------------------------------------------------

# ── Route 53 hosted zone lookup (network account) ───────────────────────────

#data "aws_route53_zone" "devkyfb" {
#  provider = aws.networkaccount
#  name         = var.soap_api_hosted_zone
#  private_zone = false
#}

# ── S3 bucket for mTLS truststore (destination account) ─────────────────────
# Upload your CA certificate here when you are ready to enable mTLS:
#   aws s3 cp ca.crt s3://<bucket-name>/truststore.pem

resource "aws_s3_bucket" "soap_api_truststore" {
  bucket = "${var.application_name}-${var.env_tier}-soap-api-truststore"

  tags = {
    Name = "${var.application_name}-${var.env_tier}-soap-api-truststore"
  }
}

resource "aws_s3_bucket_versioning" "soap_api_truststore" {
  bucket = aws_s3_bucket.soap_api_truststore.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "soap_api_truststore" {
  bucket                  = aws_s3_bucket.soap_api_truststore.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#ACM Certificate section

resource "aws_acm_certificate" "soap_api" {
  domain_name               = var.soap_api_domain_name
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  provider = aws.networkaccount
  for_each = {
    for dvo in aws_acm_certificate.soap_api.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.kyfb.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.soap_api.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
