# WISEBox Image Generator

[Packer](https://www.packer.io/) builder to generate SD card images for
Raspberry Pi containing the
[WISEBox Logger](https://github.com/Horizon-WISEBox/wisebox-logger). This image
is known to work on the Pi Zero W and 3B+, other Pi versions may work with some
minor modifications.

## Getting Started

### Dependencies

* [Packer](https://www.packer.io/)
* [Packer Builder ARM](https://github.com/mkaczanowski/packer-builder-arm)

Alternatively, if you have [Vagrant](https://www.vagrantup.com/) installed
you can skip these dependencies and use the included
[Vagrant file](Vagrantfile).

### Building

* Run '[packer/scripts/init.sh](packer/scripts/init.sh) \<dir>' where \<dir> is
  the directory images will be built in. **Skip this step if using Vagrant**.
* Change directory to the base directory you chose above (on Vagrant this is
  /home/vagrant/wisebox).
* Run `packer build packer/nexmon.pkr.hcl`. This will build an intermediate
  image with [Nexmon](https://github.com/seemoo-lab/nexmon/) firmware patches
  applied. This build can take upward of an hour.
* Run `packer build packer/wisebox.pkr.hcl`. This will build the final WISEBox
  image in the `dist` folder. Various aspects of this build can be configured
  by setting Packer variables, see
  [packer/files/wisebox.pkr.hcl]([packer/files/wisebox.pkr.hcl]) for further
  details. A custom
  [WISEBox configuration file](packer/files/etc/wisebox/wisebox.yml) can also be
  used by creating it at
  [packer/files/etc/wisebox/wisebox.override.yml](
    packer/files/etc/wisebox/wisebox.override.yml).

## License

This project is licensed under the GNU Affero General Public License, Version 3
\- see the [LICENSE](LICENSE) file for details
