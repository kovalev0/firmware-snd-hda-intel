%define _unpackaged_files_terminate_build 1
%global _firmwarepath  /lib/firmware

Name: firmware-snd-hda-intel
Version: 0.1
Release: alt1

Summary: Quirk configuration for snd_hda_intel module

License: GPLv3+
Group: System/Configuration/Hardware
BuildArch: noarch

Url: https://github.com/kovalev0/firmware-snd-hda-intel
VCS: https://github.com/kovalev0/firmware-snd-hda-intel.git

Source0: %name-%version.tar

%description
This package provides configuration quirks for the
snd_hda_intel kernel module.  It automatically sets up
the correct configuration file based on the system codec.

%prep
%setup

%install
mkdir -p %buildroot%_datadir/%name/quirks
mkdir -p %buildroot%_sysconfdir/modprobe.d
mkdir -p %buildroot%_firmwarepath

install -D -m 644 quirks/*	%buildroot%_datadir/%name/quirks/
echo "options snd-hda-intel patch=%name.fw" > %buildroot%_sysconfdir/modprobe.d/%name.conf
touch				%buildroot%_firmwarepath/%name.fw
install -D -m 755 *.sh		%buildroot%_datadir/%name/

%post
pushd %_datadir/%name/
	bash setup-quirk.sh
popd

%files
%doc README.md LICENSE
%_datadir/%name/*
%_sysconfdir/modprobe.d/%name.conf
%_firmwarepath/%name.fw

%changelog
* Fri Dec 06 2024 Vasiliy Kovalev <kovalev@altlinux.org> 0.1-alt1
- Init.
