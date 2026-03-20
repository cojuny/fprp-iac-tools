Terraform + KVM (libvirt) Quick Setup Guide
Host OS: Ubuntu Server 24.04.4
Guest OS: Ubuntu 24.04 cloud image

--------------------------------------------------

1. Install Required Packages
```sh
sudo apt update
sudo apt install -y \
  qemu-kvm \
  libvirt-daemon-system \
  libvirt-clients \
  bridge-utils \
  cloud-image-utils \
  genisoimage
```
Enable libvirt:
```sh
sudo systemctl enable --now libvirtd
```
--------------------------------------------------

2. User Permissions
```sh
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
```
Log out and back in

Verify:
```sh
virsh list --all
ls /dev/kvm
```
--------------------------------------------------

3. Install Terraform
```sh
terraform version
```
(Install from HashiCorp if missing)

--------------------------------------------------

4. Base Image (Required)
```sh
sudo mkdir -p /var/lib/libvirt/images
cd /var/lib/libvirt/images
```
sudo wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

--------------------------------------------------

5. Network Configuration (br0)

Netplan config:
```sh
network:
  version: 2
  renderer: networkd

  ethernets:
    enp4s0:
      dhcp4: false
      dhcp6: false

  bridges:
    br0:
      interfaces:
        - enp4s0
      addresses:
        - 192.168.100.250/24
      routes:
        - to: default
          via: 192.168.100.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```
Apply:
```sh
sudo netplan apply
```
Verify:
```sh
ip a show br0
```
--------------------------------------------------

6. Storage Pool

Check:
```sh
virsh pool-list --all
```
If missing:
```sh
virsh pool-define-as default dir - - - - "/var/lib/libvirt/images"
virsh pool-start default
virsh pool-autostart default
```
--------------------------------------------------

7. Terraform Files Required

Directory must contain:
```sh
main.tf
cloud-init.tpl
meta-data.tpl
network-config.tpl
```
--------------------------------------------------

8. Run Terraform
```sh
terraform init
terraform plan
terraform apply
```
--------------------------------------------------

9. Access VM
```sh
ssh daniel@192.168.100.200
```
(Use correct private key)

--------------------------------------------------

10. Common Issues

Permission denied (libvirt)
- Add user to libvirt group
- Re-login

Bridge "br0" not found
- Ensure netplan applied
- Check interface name (enp4s0)

VM no network
- Check interface name inside VM (ens3)

Cloud-init not applied
- Run: cloud-init status

Image not found
- Ensure file exists:
  /var/lib/libvirt/images/noble-server-cloudimg-amd64.img

