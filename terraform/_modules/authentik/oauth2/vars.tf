variable "oauth2" {
  type = map(object({
    auth_application = object({
      icon       = string
      launch_url = string
      policy     = string
    })
    auth_provider = object({
      redirect_uris     = optional(list(string))
      property_mappings = optional(list(string))
    })
  }))
}

variable "client_credentials" {
  type = map(object({
    client_id     = string
    client_secret = string
  }))
  sensitive = true
}