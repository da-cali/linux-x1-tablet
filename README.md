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

#### Working with tweaks (see bellow)

* Volume buttons
* S3 sleep
* Trackpoint and trackpad buttons

#### Not working

* Back camera
* Fingerprint reader
* FnLock key

### Volume buttons

Upgrade your BIOS. Doing so fixes the volume buttons and it is possibly necesary to make S3 sleep work.

### S3 sleep

Patch the bios (Instructions and patch file taken from mr. sour's gist):

0. Reboot, and enter your BIOS. Go to Config - Thunderbolt (TM) 3 and set Thunerbolt BIOS Assist Mode to Enabled.
1. Install iasl (and git):
  ```
  sudo dnf install acpica-tools git
  ```
2. Clone repository:
  ```
  git clone https://github.com/da-cali/linux-x1-tablet
  ```
3. Open folder:
  ```
  cd linux-x1-tablet
  ```
4. Get a dump of your ACPI DSDT table:
  ```
  cat /sys/firmware/acpi/tables/DSDT > dsdt.aml
  ```
5. Decompile the dump, which will generate a .dsl source based on the .aml ACPI machine language dump:
  ```
  iasl -d dsdt.aml
  ```
6. Apply the patch to dsdt.dsl:
  ```
  patch --verbose < x1_dsdt.patch
  ```
7. If (Once?) the patch is rejected, look at x1_dsdt.patch and notice the lines that begin with "-". These lines of code should be removed from your dsdt.dsl (and replaced with another one in the case of the DefinitionBlock line). Open your dsdt.dsl and A) make sure that the hex number at the end of the first non-commented line (DefinitionBlock...) is "0x00000001"; and B) delete the "One" lines if necessary. Save the changes.
8. Recompile your patched version of the .dsl source:
  ```
  iasl -ve -tc dsdt.dsl
  ```
9. Move the compiled patch to your boot folder:
  ```
  cp dsdt.aml /boot
  ```
10. Create a custom acpi loader for grub:
  ```
  cat <<+ > /etc/grub.d/01_acpi
  #! /bin/sh -e

  # Uncomment to load custom ACPI table
  GRUB_CUSTOM_ACPI="/boot/dsdt.aml"

  # DON'T MODIFY ANYTHING BELOW THIS LINE!

  prefix=/usr
  exec_prefix=\${prefix}
  datadir=\${exec_prefix}/share

  . \${datadir}/grub/grub-mkconfig_lib

  # Load custom ACPI table
  if [ x\${GRUB_CUSTOM_ACPI} != x ] && [ -f \${GRUB_CUSTOM_ACPI} ] \\
          && is_path_readable_by_grub \${GRUB_CUSTOM_ACPI}; then
      echo "Found custom ACPI table: \${GRUB_CUSTOM_ACPI}" >&2
      prepare_grub_to_access_device \`\${grub_probe} --target=device \$ {GRUB_CUSTOM_ACPI}\` | sed -e "s/^/ /"
      cat << EOF
  acpi (\\\$root)\`make_system_path_relative_to_its_root \$ {GRUB_CUSTOM_ACPI}\`
  EOF
  fi
  +
  ```
11. Make it executable:
  ```
  sudo chmod 0755 /etc/grub.d/01_acpi
  ```
12. Open /etc/default/grub and add "mem_sleep_default=deep" to the GRUB_CMDLINE_LINUX so that it looks like this:
  ```
  GRUB_CMDLINE_LINUX_DEFAULT="quiet mem_sleep_default=deep"
  ```
13. Regenerate your grub file:
  ##### Fedora/REHL 
  ```
  sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  ```  
  ##### Ubuntu
  ```
  sudo update-grub
  ```

Reboot the machine and check that the patch is working by entering "cat /sys/power/mem_sleep" in the command line and confirming the ouput is "s2idle [deep]" (with the brackets around "deep").

### Trackpoint and trackpad buttons

Patch and compile the kernel from source:

0. (Prep) Install the required packages for compiling the kernel:
  ```
  sudo apt install git curl wget sed
  sudo dnf groupinstall "Development Tools" "C Development Tools and Libraries"
  sudo dnf install elfutils-devel openssl-devel perl-devel   perl-generators pesign ncurses-devel
  ```
1. Clone the mainline stable kernel repo:
  ```
  git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git ~/linux-stable
  ```
2. Go into the linux-stable directory:
  ```
  cd ~/linux-stable
  ```
3. Checkout the version of the kernel you wish to target (replacing with your target version):
  ```
  git checkout v4.y.z
  ```
4. Apply the kernel patches from the linux-surface repo (this one, and assuming you cloned it to ~/linux-surface):
  ```
  for i in ~/linux-surface/patches/[VERSION]/*.patch; do patch -p1 < $i; done
  ```
5. Use config for kernel series (may need to manually change for your distro):
  ```
  cp ~/linux-surface/configs/[VERSION]/config .config
  ```
6. Compile the kernel and headers (for ubuntu, refer to the build guide for your distro):
  ```
  make -j `getconf _NPROCESSORS_ONLN` deb-pkg LOCALVERSION=-linux-surface
  ```
7. Install the headers, kernel and libc-dev:
  ```
  sudo dpkg -i linux-headers-[VERSION].deb linux-image-[VERSION].deb linux-libc-dev-[VERSION].deb
  ```


### NOTES

* Do not install TLP! It can cause slowdowns, laggy performance, and occasional hangs! You have been warned.
