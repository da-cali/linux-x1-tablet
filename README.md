# Linux X1 Tablet

Linux running on the X1 Tablet 3rd generation.

### Working out of the box

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

### Working with tweaks (see bellow)

* Volume buttons
* S3 sleep
* Trackpoint and trackpad buttons

### Not working

* Back camera
* Fingerprint reader
* FnLock key

### Volume buttons

Upgrade your BIOS. Doing so fixes the Volume buttons and it is possibly necesary to make S3 suspend work.

### S3 sleep

Reboot, enter your BIOS/UEFI. Go to Config - Thunderbolt (TM) 3 - set Thunerbolt BIOS Assist Mode to Enabled.

Patch the bios (Thanks to mr. sour for the gist):

0. Install iasl (and git):
  ```
  sudo dnf install acpica-tools git
  ```
0. Clone repository:
  ```
  git clone https://github.com/da-cali/linux-x1-tablet
  ```
1. Open folder:
  ```
  cd linux-x1-tablet
  ```
2. Get a dump of your ACPI DSDT table:
  ```
  cat /sys/firmware/acpi/tables/DSDT > dsdt.aml
  ```
4. Decompile the dump, which will generate a .dsl source based on the .aml ACPI machine language dump:
  ```
  iasl -d dsdt.aml
  ```
5. Apply the patch to dsdt.dsl:
  ```
  patch --verbose < x1_dsdt.patch
  ```



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
