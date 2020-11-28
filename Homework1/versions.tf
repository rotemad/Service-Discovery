terraform {
  required_version = "v0.13.5"

  required_providers {
    aws   = { version = "~> 3.11.0" }
    http  = { version = "~> 2.0.0" }
    local = { version = "~> 2.0.0" }
    tls   = { version = "~> 3.0.0" }
  }
}