# install the necessary tools to manage disk images
apt update && apt install libguestfs-tools -y
# download Ubuntu 22.04 cloud image
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
# modify the cloud disk image to install QEMU guest agent
virt-customize -a jammy-server-cloudimg-amd64.img --install qemu-guest-agent --run-command 'systemctl enable qemu-guest-agent'
# create a new VM with VirtIO SCSI controller
qm create 9000 --name ubuntu-22.04-template --cores 2 --memory 1024 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
# import the disk image to local-lvm storage
qm disk import 9000 jammy-server-cloudimg-amd64.img local-lvm
# attach the imported disk as a SCSI drive
qm set 9000 --scsi0 local-lvm:vm-9000-disk-0
# increase the size of the SCSI disk to 5GB
qm disk resize 9000 scsi0 5G
# configure a CD-ROM drive with cloud-init data
qm set 9000 --ide2 local-lvm:cloudinit
# configure the boot order to boot from the SCSI disk
qm set 9000 --boot order=scsi0
# configure a serial console and use it as a display
qm set 9000 --serial0 socket --vga serial0
# configure network settings
qm set 9000 --ipconfig0 ip=dhcp
# set a password for the default user account (ubuntu)
qm set 9000 --cipassword ubuntu
# enable QEMU guest agent
qm set 9000 --agent enabled=1
# convert the VM into a template
qm template 9000
