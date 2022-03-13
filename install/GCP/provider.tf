terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = "rolex-projects"
  region  = "europe-west3"
  zone    = "europe-west3-c"
  
}
