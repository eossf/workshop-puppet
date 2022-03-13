# docker run --rm --entrypoint "sh" -it -v "/C/DevOps/puppet/workshop-puppet/install/GCP:/data" hashicorp/terraform

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      # PROJECT/#FAMILY
      image = "ubuntu-os-cloud/ubuntu-minimal-2004-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}