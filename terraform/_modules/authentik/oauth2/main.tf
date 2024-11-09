data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-explicit-consent"
}

data "authentik_certificate_key_pair" "generated" {
  name = "authentik Self-signed Certificate"
}

resource "authentik_provider_oauth2" "provider" {
  for_each             = var.oauth2
  name                 = lower(each.key)
  client_id            = var.client_credentials[each.key].client_id
  client_secret        = var.client_credentials[each.key].client_secret
  authorization_flow   = data.authentik_flow.default-authorization-flow.id
  access_code_validity = "minutes=10"
  redirect_uris        = each.value.auth_provider.redirect_uris
  signing_key          = data.authentik_certificate_key_pair.generated.id
  property_mappings    = each.value.auth_provider.property_mappings
}

resource "authentik_application" "application" {
  for_each           = var.oauth2
  name               = authentik_provider_oauth2.provider[each.key].name
  slug               = replace(authentik_provider_oauth2.provider[each.key].name, " ", "-")
  protocol_provider  = authentik_provider_oauth2.provider[each.key].id
  meta_icon          = each.value.auth_application.icon
  meta_launch_url    = each.value.auth_application.launch_url
  policy_engine_mode = each.value.auth_application.policy
}