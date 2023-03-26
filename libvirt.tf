
resource "libvirt_volume" "ubuntu18040" {
  name      = "ubuntu18040.qcow2"
  pool      = "Max-VMs"
  source    = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
  format    = "qcow2"
}

resource "libvirt_volume" "ubuntu18041" {
  name      = "ubuntu18041.qcow2"
  pool      = "Max-VMs"
  source    = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
  format    = "qcow2"
}

resource "libvirt_volume" "ubuntu18042" {
  name      = "ubuntu18042.qcow2"
  pool      = "Max-VMs"
  source    = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
  format    = "qcow2"
}

resource "libvirt_volume" "ubuntu18043" {
  name      = "ubuntu18043.qcow2"
  pool      = "Max-VMs"
  source    = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
  format    = "qcow2"
}

resource "libvirt_network" "kube-net" {
  name = "kube-net"
  mode = "bridge"
  domain = "k8s.local"
}

resource "libvirt_domain" "k8s-master" {
  name      = "k8s-master"
  memory    = "4096"
  vcpu      = 2
  
  network_interface {
    network_name = "kube-net"
  }
  
  disk {
    volume_id = "${libvirt_volume.ubuntu18040.id}"
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
  vcpu      = 1
  network_interface {
    network_name = "kube-net"
  }
  disk {
    volume_id = "${libvirt_volume.ubuntu18041.id}"
  }
}

resource "libvirt_domain" "k8s-worker-2" {
  name      = "k8s-worker-2"
  memory    = "2048"
  vcpu      = 1
  network_interface {
    network_name = "kube-net"
  }
  disk {
    volume_id = "${libvirt_volume.ubuntu18042.id}"
  }
}

resource "libvirt_domain" "k8s-worker-3" {
  name      = "k8s-worker-3"
  memory    = "2048"
  vcpu      = 1
  network_interface {
    network_name = "kube-net"
  }
  disk {
    volume_id = "${libvirt_volume.ubuntu18043.id}"
  }
}