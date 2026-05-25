data "aws_route53_zone" "kyfb" {
  provider = aws.networkaccount
  name = local.soap_api_base_domain

  private_zone = false
}
