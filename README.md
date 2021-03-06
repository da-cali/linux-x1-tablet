# Linux X1 Tablet

Linux running on the Thinkpad X1 Tablet 3rd generation.

#### Working out of the box

* Keyboard (and backlight)
* Docking/undocking tablet and keyboard
* 2D/3D acceleration
* Trackpad
* Touchscreen
* Pen
* WiFi
* Bluetooth
* Speakers
* Power button
* SD card reader
* Front camera
* Hibernate
* Sensors
* Battery readings

#### Working with tweaks (see instructions bellow)

* S3 sleep and volume buttons (Patching DSDT)
* Suspend on lid close
* Trackpoint and trackpad buttons (Patching kernel)

#### Not working

* Microphone
* Back camera
* Fingerprint reader
* FnLock key

PLEASE READ THE NOTES AFTER USING THIS GUIDE

### Enable S3 sleep and fix the volume buttons:

* Thanks to mr-sour for their [gist.](https://gist.github.com/mr-sour/e6e4f462dff2334aad84b6edd5181c09)
* Thanks to Lunm0us for their [work on the patch.](https://github.com/Lunm0us/linux-tp1gen3)

0. Upgrade your BIOS, reboot, and enter it. Go to Config, then Thunderbolt (TM) 3, and set Thunerbolt BIOS Assist Mode to "Enabled".
1. Install iasl, patch and git:
  * Fedora/REHL:
  ```
  sudo dnf install acpica-tools patch git
  ```
  * Ubuntu:
  ```
  sudo apt install iasl patch git
  ```
2. Clone this repository:
  ```
  git clone --depth 1 https://github.com/da-cali/linux-x1-tablet
  ```
3. Open folder:
  ```
  cd linux-x1-tablet
  ```
4. Run the [S3 setup script](https://github.com/da-cali/linux-x1-tablet/blob/master/s3-setup.sh):
  ```
  sudo sh s3-setup.sh
  ```
5. Open /etc/default/grub and add "mem_sleep_default=deep" to the GRUB_CMDLINE_LINUX line so that it looks (may differ) like this: GRUB_CMDLINE_LINUX="quiet mem_sleep_default=deep".

6. Update grub:
  * Fedora/REHL: 
  ```
  sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  ```  
  * Ubuntu:
  ```
  sudo update-grub
  ```
  * NOTE: If the "Found custom ACPI table: /boot/dsdt.aml" line does not show up, update grub again.

7. Reboot the machine and confirm that the patch is working by entering "cat /sys/power/mem_sleep" in the command line and getting back "s2idle [deep]" (with the brackets around "deep").

### Enable suspend on lid close:

1. Open logind.conf:
  ```
  sudo nano /etc/systemd/logind.conf
  ```
2. Uncomment the following lines:
  ```
  HandleSuspendKey=suspend
  HandleLidSwitch=suspend
  HandleLidSwitchDocked=suspend
  ```
3. Save changes and restart.


### Fix the trackpoint and trackpad buttons:

#### * Either install [jakeday's linux-surface kernel](https://github.com/jakeday/linux-surface). (NOTE: Do not run the setup script. Only install the kernel packages.)

#### * Or compile your own kernel from source:

0. Install the required packages for compiling the kernel:
  * Fedora/REHL
  ```
  sudo dnf install git curl sed elfutils-devel openssl-devel perl-devel perl-generators pesign ncurses-devel
  ```
  ```
  sudo dnf groupinstall "Development Tools" "C Development Tools and Libraries"
  ```
  * Ubuntu:
  ```
  sudo apt install git curl sed build-essential binutils-dev libncurses5-dev libssl-dev ccache bison flex libelf-dev
  ```
1. (From the linux-x1-tablet folder) Clone the mainline stable kernel repo:
  ```
  git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
  ```
2. Go into the linux-stable directory:
  ```
  cd linux-stable
  ```
3. Checkout the version of the kernel you wish to target (replacing "x.y.z" with your target version, for example: "git checkout v5.0.10"):
  ```
  git checkout vx.y.z
  ```
4. Apply the kernel patch:
  ```
  patch -p1 < ../trackpoint.patch
  ```
5. Obtain the current kernel configuration of your distribution:
  ```
  cp -v /boot/config-$(uname -r) .config
  ```
6. Compile the kernel and headers (this might take around one hour depending on your hardware):
  ```
  make -j `getconf _NPROCESSORS_ONLN` bzImage; make -j `getconf _NPROCESSORS_ONLN` modules
  ```
7. Install the kernel and headers:
  ```
  sudo make -j `getconf _NPROCESSORS_ONLN` modules_install
  ```
  ```
  sudo make -j `getconf _NPROCESSORS_ONLN` install
  ```
8. Update grub:
  * Fedora/REHL: 
  ```
  sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  ```  
  * Ubuntu:
  ```
  sudo update-grub
  ```
9. Reboot from the new kernel.

### Notes

* The custom acpi loader does not currently support dual boot with Windows, so if you installed a kernel using this guide and want to boot on Windows you will have to disable the custom acpi loader first, and update the grub before rebooting. To uninstall the custom acpi loader delete both /etc/grub.d/01_acpi and /boot/dsdt.aml, update grub and restart.
* Wifi power saving mode can make the wifi unstable. You can check the power management status of your wifi with the "iwconfig" command, and desactivate wifi power save with TLP.
* Tested in Ubuntu 20.04 with BIOS v1.36.

