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
* Suspend (not S3)
* Hibernate
* Sensors
* Battery readings

#### Working with tweaks (see bellow)

* Volume buttons (Updating BIOS)
* S3 sleep (Patching DSDT)
* Trackpoint and trackpad buttons (Patching and compling kernel)

#### Not working

* Back camera
* Fingerprint reader
* FnLock key

### Volume buttons

Upgrade your BIOS. Doing so fixes the volume buttons and it is possibly necesary to make S3 sleep work.

### S3 sleep

* Thanks to mr-sour's for his gist: https://gist.github.com/mr-sour/e6e4f462dff2334aad84b6edd5181c09

#### Patch the DSDT:

0. Reboot, and enter your BIOS. Go to Config, then Thunderbolt (TM) 3, and set Thunerbolt BIOS Assist Mode to "Enabled".
1. Install iasl, patch and git:
  * Fedora/REHL:
  ```
  sudo dnf install acpica-tools patch git
  ```
  * Ubuntu:
  ```
  sudo dnf install iasl patch git
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
  sudo cat /sys/firmware/acpi/tables/DSDT > dsdt.aml
  ```
5. Decompile the dump, which will generate a .dsl source based on the .aml ACPI machine language dump:
  ```
  iasl -d dsdt.aml
  ```
6. Apply the patch to dsdt.dsl:
  ```
  patch --verbose < x1_dsdt.patch
  ```
7. If (Once?) the patch is rejected, look at x1_dsdt.patch and notice the lines that begin with "-". These lines of code should be removed from your dsdt.dsl (and replaced with another one in the case of the DefinitionBlock line). Open your dsdt.dsl and a) make sure that the hex number at the end of the first non-commented line (DefinitionBlock...) is "0x00000001"; and b) delete the "One" lines if necessary. Save the changes.
8. Recompile your patched version of the .dsl source:
  ```
  iasl -ve -tc dsdt.dsl
  ```
9. If there are no errors in the previous step, move the compiled patch to your boot folder:
  ```
  sudo cp dsdt.aml /boot
  ```
10. Copy the custom acpi loader to /etc/grub.d:
  ```
  sudo cp 01_acpi /etc/grub.d
  ```
11. Make it executable:
  ```
  sudo chmod 0755 /etc/grub.d/01_acpi
  ```
12. Open /etc/default/grub and add "mem_sleep_default=deep" to the GRUB_CMDLINE_LINUX so that it looks like this:
  ```
  GRUB_CMDLINE_LINUX_DEFAULT="quiet mem_sleep_default=deep"
  ```
13. Update grub:
  * Fedora/REHL: 
  ```
  sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  ```  
  * Ubuntu:
  ```
  sudo update-grub
  ```
  * If the line "Found custom ACPI table: /boot/dsdt.aml" line does not show up, update grub again.

14. Reboot the machine and confirm that the patch is working by entering "cat /sys/power/mem_sleep" in the command line and getting back "s2idle [deep]" (with the brackets around "deep").

### Trackpoint and trackpad buttons

* Thanks to jakeday for the patch

#### Patch and compile the kernel from source:

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
  cd ~/linux-stable
  ```
3. Checkout the version of the kernel you wish to target (replacing with your target version):
  ```
  git checkout v4.18.x
  ```
4. Apply the kernel patch:
  ```
  patch -p1 < ../ipts.patch
  ```
5. Obtain the current kernel configuration of your distribution:
  ```
  cp -v /boot/config-$(uname -r) .config
  ```
6. Compile the kernel and headers (this might take around one hour depending on your hardware):
  ```
  make -j `getconf _NPROCESSORS_ONLN` bzImage; make -j `getconf _NPROCESSORS_ONLN` modules
  ```
  * Type "m" when prompted "Intel Precise Touch & Stylus (INTEL_IPTS) [N/m/y/?] (NEW)"
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

* The custom acpi loader does not currently support dual boot with Windows, so if you install it and want to boot on Windows you will have to disable it first, and update the grub before restarting.
* Powertop and thermald greatly improve battery life, I recommend installing and setting up these tools as well.