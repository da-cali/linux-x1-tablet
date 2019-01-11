#!/bin/sh

echo "Getting dump of your ACPI DSDT table...\n"
cat /sys/firmware/acpi/tables/DSDT > dsdt.aml

echo "Decompiling dump...\n"
iasl -d dsdt.aml

echo "Applying patch...\n"
patch --verbose < x1_dsdt.patch

echo "Recompiling dsdt...\n"
iasl -ve -tc dsdt.dsl

echo "Copying dsdt to boot...\n"
cp dsdt.aml /boot

echo "Copying custom acpi loader to grub folder...\n"
cp 01_acpi /etc/grub.d

echo "Making loader executable...\n"
chmod 0755 /etc/grub.d/01_acpi

echo "\nAll done. Please open /etc/default/grub and add 'mem_sleep_default=deep' to the GRUB_CMDLINE_LINUX"
