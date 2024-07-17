os = "l26"
cores = "4"
sockets = "1"
memory = "4096" 
bridge = "vmbr0"
disk_type = "scsi"
disk_size = "10G"
disk_format = "raw" 
disk_cache_mode = "writeback"
datastore = "scd6"
datastore_type = "nfs"
cloud_init_storage_pool = "gfs" 
scsi_controller = "virtio-scsi-pci"

ssh_username = "packer"
ssh_password = "packer"
ssh_timeout = "20m"

http_directory = "http"


template_name = "testing-ubuntu"

vm_id = "1610"

iso = "iso:iso/ubuntu-22.04.3-live-server-amd64.iso"
