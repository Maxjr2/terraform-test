terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}
provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "max_vms" {
  name = "Max-VMs"
  type = "dir"
  path = "/mnt/max-vms"
}

resource "libvirt_volume" "ubuntu1804" {
  name      = "ubuntu1804.qcow2"
  pool      = "${libvirt_pool.max_vms.name}"
  capacity  = "80192"
  format    = "qcow2"
  source    = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
}

resource "libvirt_domain" "k8s-master" {
  name      = "k8s-master"
  memory    = "4096"
  vcpu      = 2
  network_interface {
    network_name = "default"
    model_type   = "virtio"
  }
  disk {
    volume_id = "${libvirt_volume.ubuntu1804.id}"
    pool      = "${libvirt_pool.max_vms.name}"
  }
}

resource "libvirt_domain" "k8s-worker-1" {
  name      = "k8s-worker-1"
  memory    = "2048"
  vcpu      = 2
  network_interface {
    network_name = "default"
    model_type   = "virtio"
  }
  disk {
    volume_id = "${libvirt_volume.ubuntu1804.id}"
    pool      = "${libvirt_pool.max_vms.name}"
  }
}

resource "libvirt_domain" "k8s-worker-2" {
  name      = "k8s-worker-2"
  memory    = "2048"
  vcpu      = 2
  network_interface {
    network_name = "default"
    model_type   = "virtio"
  }
  disk {
    volume_id = "${libvirt_volume.ubuntu1804.id}"
    pool      = "${libvirt_pool.max_vms.name}"
  }
}

resource "kubernetes_deployment" "cluster_autoscaler" {
  metadata {
    name = "cluster-autoscaler"
    namespace = "kube-system"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "cluster-autoscaler"
      }
    }

    template {
      metadata {
        labels = {
          app = "cluster-autoscaler"
        }
      }

      spec {
        container {
          name = "cluster-autoscaler"
          image = "k8s.gcr.io/autoscaling/cluster-autoscaler:v1.22.2"
          command = [
            "/bin/bash",
            "-c",
            "/cluster-autoscaler --v=4 --stderrthreshold=info --cloud-provider=kubernetes --skip-nodes-with-local-storage=false --expander=least-waste --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled --balance-similar-node-groups --skip-nodes-with-system-pods=false"
          ]
          env {
            name = "AUTO_DISCOVERY_TAG_FILTER"
            value = "k8s.io/cluster-autoscaler/enabled=true"
          }
        }
      }
    }
  }
}
