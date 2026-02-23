{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b298b420-e186-461a-b050-a88aa508345e";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6C40-06E3";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/c5f71c2c-7612-4b66-ad8a-76905f6eceb0"; }
    ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Storage configuration - hardware specific
  fileSystems."/mnt/disk1" = {
    device = "/dev/disk/by-uuid/62f175a2-a944-45f2-9722-3c4b22a3a381";
    fsType = "ext4";
    options = [ "defaults" ];
  };

  fileSystems."/mnt/disk2" = {
    device = "/dev/disk/by-uuid/586c6c9a-6b90-4065-8a2a-bb7981d85ad1";
    fsType = "ext4";
    options = [ "defaults" ];
  };

  fileSystems."/mnt/disk3" = {
    device = "/dev/disk/by-uuid/108f0b0c-4390-460c-84de-e48077cbe2d3";
    fsType = "ext4";
    options = [ "defaults" ];
  };

}
