locals {
  soap_api_fqdn = var.soap_api_domain_name
  soap_api_domain_parts = split(".", local.soap_api_fqdn)
  soap_api_base_domain = join(".", slice(local.soap_api_domain_parts, length(local.soap_api_domain_parts) - 2, length(local.soap_api_domain_parts)))
}
