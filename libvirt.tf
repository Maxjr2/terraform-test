resource "libvirt_pool" "max_vms" {
  name = "Max-VMs"
  type = "dir"
  path = "/mnt/max-vms"
}

resource "libvirt_volume" "ubuntu1804" {
  name      = "ubuntu1804.qcow2"
  pool      = "${libvirt_pool.max_vms.name}"
  source    = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
  format    = "qcow2"
}

resource "libvirt_domain" "k8s-master" {
  name      = "k8s-master"
  memory    = "4096"
  vcpu      = 2
  
  network_interface {
    network_name = "default"
  }
  
  disk {
    volume_id = "${libvirt_volume.ubuntu1804.id}"
  }
  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

resource "libvirt_domain" "k8s-worker-1" {
  name      = "k8s-worker-1"
  memory    = "2048"
  vcpu      = 2
  network_interface {
    network_name = "default"
  }
  disk {
    volume_id = "${libvirt_volume.ubuntu1804.id}"
  }
}

resource "libvirt_domain" "k8s-worker-2" {
  name      = "k8s-worker-2"
  memory    = "2048"
  vcpu      = 2
  network_interface {
    network_name = "default"
  }
  disk {
    volume_id = "${libvirt_volume.ubuntu1804.id}"
  }
}