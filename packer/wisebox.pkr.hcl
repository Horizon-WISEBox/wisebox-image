source "arm" "raspios_lite_armhf-2020-08-24" {
  file_checksum         = "7a7c88df30c065c5c73ae3205ba18634045ca70c3e76878b537cbb770fbee9db"
  file_checksum_type    = "sha256"
  file_target_extension = "img"
  file_urls             = ["file://${path.cwd}/dist/2020-08-20-raspios-buster-armhf-lite-nexmon.img"]
  image_build_method    = "resize"
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
  image_path                   = "dist/2020-08-20-raspios-buster-armhf-lite-wisebox.img"
  image_size                   = "2G"
  image_type                   = "dos"
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
  provisioner "file" {
    source = "${path.root}/files/"
    destination = "/wisebox-files"
  }
  provisioner "shell" {
    script = "${path.root}/scripts/wisebox.sh"
  }
}
