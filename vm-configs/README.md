# VM Configurations

This directory contains libvirt/QEMU virtual machine configurations.

## win11-optimized.xml

Optimized Windows 11 VM configuration for QEMU/KVM.

### Specifications
- **CPU**: 8 vCPUs (4 cores, 2 threads) with host-passthrough and CPU pinning
- **Memory**: 8GB static allocation
- **Disk**: VirtIO-SCSI with writeback cache
- **Network**: VirtIO-Net with 8 queues
- **Graphics**: VirtIO-GPU with 3D acceleration
- **Firmware**: UEFI with Secure Boot
- **TPM**: Emulated TPM 2.0

### Features
- Hyper-V enlightenments for better Windows performance
- CPU topology optimized for AMD Ryzen AI 7 PRO 350
- High-performance VirtIO drivers for all devices
- KVM hidden state for better compatibility

### Usage

Apply this configuration to your VM:
```bash
sudo virsh define vm-configs/win11-optimized.xml
```

Start the VM:
```bash
sudo virsh start win11
```

### Requirements
- VirtIO drivers must be installed in Windows 11
- QEMU with KVM support
- libvirt

### Notes
- This configuration assumes VirtIO drivers are already installed in the Windows guest
- The disk image path is `/var/lib/libvirt/images/win11.qcow2`
- CDROM points to `/home/matx/Downloads/Nano11 24H2.iso` (adjust as needed)
