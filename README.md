# firmware-snd-hda-intel

This repository provides a framework for managing and applying custom quirks for the `snd-hda-intel` kernel module on Linux systems. It enables dynamic configuration of audio codecs based on `Vendor Id` and `Subsystem Id` detected in the system.

## Features

- Maintains a collection of firmware configuration files (`.fw`) for various audio codecs and hardware models.
- Automatically detects the audio codec in use by analyzing `/proc/asound/card*/codec#*`.
- Matches the detected `Vendor Id` and `Subsystem Id` with the appropriate firmware configuration file.
- Updates the `firmware-snd-hda-intel.fw` file used by the `snd-hda-intel` kernel module.
- Ensures the system remains functional by leaving the firmware file empty if no match is found.

## Example Firmware File (.fw)

Each firmware file follows this structure:
```sh
[codec]
<VENDOR_ID> <SUBSYSTEM_ID> <ADDRESS>

[pincfg]
<PIN_CONFIGURATION>

[verb]
<ADDITIONAL_INIT_VERBS>

[hints]
<ADDITIONAL_HINTS>
```

Example for *ASUS ZEN AIO 27 Z272SD_A272SD*:
```sh
[codec]
0x10ec0274 0x104331d0 0

[pincfg]
0x19 0x03a1103c

[verb]
0x20 0x500 0x10
0x20 0x400 0xc420
...
```

## Installation

1. Clone the repository:
```sh
git clone https://github.com/kovalev0/firmware-snd-hda-intel.git
cd firmware-snd-hda-intel
```
2. Create  the required files to their locations:
```sh
echo "options snd-hda-intel patch=firmware-snd-hda-intel.fw" | sudo tee /etc/modprobe.d/firmware-snd-hda-intel.conf
sudo touch /lib/firmware/firmware-snd-hda-intel.fw
```
3. Ensure the script is executable:
```sh
chmod +x setup-quirk.sh
```
4. Run the script to apply the appropriate firmware:
```sh
sudo setup-quirk.sh
```
5. Reboot.

## Troubleshooting
- If the snd-hda-intel-quirk.fw file remains empty:
    - Ensure the .fw files in quirks dir have the correct Vendor Id, Subsystem Id and Address.
    - Verify the output of /proc/asound/card*/codec#* matches the .fw file.
- To debug, run the script with:
```sh
sudo bash -x setup-quirk.sh
```

## License
This project is licensed under the GNU General Public License v3.0. See the LICENSE file for details.
