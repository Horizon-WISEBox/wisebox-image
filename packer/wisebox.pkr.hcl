variable "username" {
  type = string
  default = "wisebox"
  description = "Username to be used to log on to the image"
}
variable "password" {
  type = string
  default = "wisebox"
  description = "Password to be used to log on to the image"
}
variable "hostname" {
  type = string
  default = "wisebox"
  description = "Operating system hostname"
}
variable "pretty_hostname" {
  type = string
  default = "WISEBox"
  description = "Human readable system hostname (used as Bluetooth device name)"
}
variable "locale" {
  type = string
  default = "en_GB.UTF-8"
  description = "Operating system locale"
}
variable "timezone" {
  type = string
  default = "Europe/London"
  description = "Operating system timezone"
}
variable "wifi_country" {
  type = string
  default = "GB"
  description = "Country code used to initialise wifi"
}
variable "logger_version_tag" {
  type = string
  default = "v1.3.0"
  description = "Logger version to install"
}
variable "logserver_version_tag" {
  type = string
  default = "v1.1.2"
  description = "Log server version to install"
}
variable "enable_ssh_server" {
  type = bool
  default = true
  description = "Enable SSH server if true"
}
variable "enable_hw_clock" {
  type = bool
  default = true
  description = "Enable DS3231 hardware clock if true"
}
variable "enable_bluetooth_networking" {
  type = bool
  default = true
  description = "Enable Bluetooth networking if true"
}

source "arm" "raspios_lite_armhf-2020-08-24" {
  file_checksum         = "1b4bfe5b401df505c7b66e35090b657796c8fe305fc4bc0a8db5dddf82fafcc4"
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
    environment_vars = [
      "WB_USERNAME=${var.username}",
      "WB_PASSWORD=${var.password}",
      "WB_HOSTNAME=${var.hostname}",
      "WB_PRETTY_HOSTNAME=${var.pretty_hostname}",
      "WB_LOCALE=${var.locale}",
      "WB_TIMEZONE=${var.timezone}",
      "WB_WIFI_COUNTRY=${var.wifi_country}",
      "WB_LOGGER_VERSION_TAG=${var.logger_version_tag}",
      "WB_LOGSERVER_VERSION_TAG=${var.logserver_version_tag}",
      "WB_ENABLE_SSH_SERVER=${var.enable_ssh_server == true ? 1 : 0}",
      "WB_ENABLE_HW_CLOCK=${var.enable_hw_clock == true ? 1 : 0}",
      "WB_ENABLE_BLUETOOTH_NETWORKING=${var.enable_bluetooth_networking == true ? 1 : 0}"
    ]
  }
}
