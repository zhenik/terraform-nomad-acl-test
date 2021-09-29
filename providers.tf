terraform {
//  required_version = "~> 0.14.0"
  required_providers {
    nomad = {
      version = "1.4.15"
    }
    vault = {
      version = "2.12.2"
    }
    time = {
      version = "0.7.2"
    }
  }
}