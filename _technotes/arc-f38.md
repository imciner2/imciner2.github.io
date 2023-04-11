---
layout: technote
title: Arc A750 on Fedora 38
summary: Using the Intel Arc A750 on Fedora
category: [Fedora]
modified: April 11, 2023
---

# Linux Support

Support for the Intel Arc A750 was added to the mainline Linux kernel starting in kernel version 6.2, and added to mesa in version 23.
Fedora includes these two versions starting in Fedora 38, allowing the use of the Intel Arc on Fedora 38 without patches.

# Enabling Graphics Output

## Kernel changes

With linux kernel 6.2, there are no kernel command line parameters needed to enable the Arc A750 using the i915 driver.
To verify the kernel has loaded the i915 driver for the A750, run the `lspci` command and view the kernel modules used.
All A750 cards have the PCI ID `8086:56a1`, so the lspci output can be filtered to only show PCI devices with that ID.
A properly configured install will have an output similar to below (showing the i915 driver in use for the A750).

<div id="code-arclspci" class="codeblock">
<pre>
$ lspci -vd 8086:56a1
03:00.0 VGA compatible controller: Intel Corporation DG2 [Arc A750] (rev 08) (prog-if 00 [VGA controller])
    Subsystem: Intel Corporation Device 1021
    Flags: bus master, fast devsel, latency 0, IRQ 137, IOMMU group 16
    Memory at fa000000 (64-bit, non-prefetchable) [size=16M]
    Memory at fa00000000 (64-bit, prefetchable) [size=8G]
    Expansion ROM at fb000000 [disabled] [size=2M]
    Capabilities: &lt;access denied&gt;
    Kernel driver in use: i915
    Kernel modules: i915
</pre>
</div>

## X Server Configuration

In order to get graphics output from the A750 on an X server-based display, the modesetting driver must be used instead of the default intel driver.
This can be done by putting the following configuration into the file `/etc/X11/xorg.conf.d/20-intel-arc.conf`

<div id="code-arcx11" class="codeblock">
<pre>
Section "Device"
    Identifier "Intel Graphics"
#   Driver "intel"
    Driver "modesetting"
#   Driver "fbdev"
EndSection
</pre>
</div>

# oneAPI Computation Offloading

The Arc A750 is able to be used as a computational accelerator with oneAPI, but doing so requires several additional packages.

First, install the `intel-basekit` package from the main Intel oneAPI repository to get the core sycl programs, including `sycl-ls`.
Examining the output of `sycl-ls` on the base install does not show the A750 available:

<div id="code-arcsycllsnoarc" class="codeblock">
<pre>
$ sycl-ls
[opencl:acc:0] Intel(R) FPGA Emulation Platform for OpenCL(TM), Intel(R) FPGA Emulation Device 1.2 [2023.15.3.0.20_160000]
[opencl:cpu:1] Intel(R) OpenCL, AMD Ryzen 9 7900 12-Core Processor              3.0 [2023.15.3.0.20_160000]
</pre>
</div>

To enable the computational offload to the A750, install the `intel-compute-engine` package from the main Fedora repo.
After installing it, `sycl-ls` should show the A750 as a possible accelerator for the `opencl:gpu` class of devices, at a minimum.

<div id="code-arcsycllsarcopencl" class="codeblock">
<pre>
$ sycl-ls
[opencl:acc:0] Intel(R) FPGA Emulation Platform for OpenCL(TM), Intel(R) FPGA Emulation Device 1.2 [2023.15.3.0.20_160000]
[opencl:cpu:1] Intel(R) OpenCL, AMD Ryzen 9 7900 12-Core Processor              3.0 [2023.15.3.0.20_160000]
[opencl:gpu:2] Intel(R) OpenCL HD Graphics, Intel(R) Arc(TM) A750 Graphics 3.0 [23.05.25593.18]
</pre>
</div>

If the output does not show a line for `[ext_oneapi_level_zero:gpu]` containing the A750, then install the `oneapi-level-zero` package from the main Fedora repo.
After installing that package, the `sycl-ls` command should show both an opencl and level zero entry for the A750, similar to:

<div id="code-arcsycllscomplete" class="codeblock">
<pre>
$ sycl-ls
[opencl:acc:0] Intel(R) FPGA Emulation Platform for OpenCL(TM), Intel(R) FPGA Emulation Device 1.2 [2023.15.3.0.20_160000]
[opencl:cpu:1] Intel(R) OpenCL, AMD Ryzen 9 7900 12-Core Processor              3.0 [2023.15.3.0.20_160000]
[opencl:gpu:2] Intel(R) OpenCL HD Graphics, Intel(R) Arc(TM) A750 Graphics 3.0 [23.05.25593.18]
[ext_oneapi_level_zero:gpu:0] Intel(R) Level-Zero, Intel(R) Arc(TM) A750 Graphics 1.3 [1.3.25593]
</pre>
</div>
