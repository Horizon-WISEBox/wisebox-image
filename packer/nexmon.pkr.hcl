source "arm" "raspios_lite_armhf-2020-08-24" {
  file_checksum         = "4522df4a29f9aac4b0166fbfee9f599dab55a997c855702bfe35329c13334668"
  file_checksum_type    = "sha256"
  file_target_extension = "zip"
  file_urls             = ["https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2020-08-24/2020-08-20-raspios-buster-armhf-lite.zip"]
  image_build_method    = "reuse"
  image_chroot_env      = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]
  image_partitions {
    filesystem   = "vfat"
    mountpoint   = "/boot"
    name         = "boot"
    size         = "256M"
    start_sector = "8192"
    type         = "c"
  }
  image_partitions {
    filesystem   = "ext4"
    mountpoint   = "/"
    name         = "root"
    size         = "0"
    start_sector = "532480"
    type         = "83"
  }
  image_path            = "dist/2020-08-20-raspios-buster-armhf-lite-nexmon.img"
  image_size            = "2G"
  image_type            = "dos"
  additional_chroot_mounts {
    mount_type       = "bind"
    source_path      = "build/usr/src"
	  destination_path = "/usr/src"
  }
  additional_chroot_mounts {
    mount_type       = "bind"
    source_path      = "build/tmp"
	  destination_path = "/tmp"
  }
  qemu_binary_destination_path = "/usr/bin/qemu-arm-static"
  qemu_binary_source_path      = "/usr/bin/qemu-arm-static"
}

build {
  sources = ["source.arm.raspios_lite_armhf-2020-08-24"]
  provisioner "shell" {
    script = "${path.root}/scripts/nexmon.sh"
  }
}
