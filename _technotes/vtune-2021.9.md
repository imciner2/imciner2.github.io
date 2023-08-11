---
layout: technote
title: Installing & configuring VTune 2021.9.0
summary: Installing the Intel oneAPI VTune 2021.9.0 software
category: [oneAPI]
---

The Intel VTune software has started to remove support for some older microarchitectures from newer versions, with the 2023.2.0 version only supporting Xeon v3 and Core 4th generation (and newer) processors.
This means that older Sandy Bridge-based processors (like Xeon E5) are not supported anymore, and older versions must be used.
The last version to support Sandy Bridge is Intel VTune 2021.9.0.

The installation of 2021.9.0 can be done as normal, but afterwards there are several final configuration steps needed.

# Compiling the kernel driver

To compile the Intel Sampling Kernel Driver, run

<div id="code-sepdkcompile" class="codeblock">
<pre>
cd /opt/intel/oneapi/vtune/2021.9.0/sepdk/src
sudo ./build_driver
</pre>
</div>

This command will error though:
<div id="code-sepdkerror" class="codeblock">
<pre>
make[2]: Leaving directory `/usr/src/kernels/3.10.0-1160.92.1.0.1.el7.x86_64'
make[1]: Leaving directory `/opt/intel/oneapi/vtune/2021.9.0/sepdk/src/socwatch/socwatch_driver'
************ Built drivers are copied to /opt/intel/oneapi/vtune/2021.9.0/sepdk/src/socwatch/drivers directory ************
Done
mv: target ‘socwatch2_15-x32_64-3-x32_64-3.10.0-1160.92.1.0.1.el7.x86_64smp.ko’ is not a directory
make: *** [default] Error 1
</pre>
</div>

The good news is, Intel knows about the error, as mentioned in a [community forum post](https://community.intel.com/t5/Analyzers/Sampling-Driver-build-fails/m-p/1338782/highlight/true#M21587), the bad news is that the thread was closed because the reporter worked offline to fix it and they never reported what they did to fix the error.

<center><a href="https://xkcd.com/979/"><img src="https://imgs.xkcd.com/comics/wisdom_of_the_ancients.png"></a></center>


## Fixing the error

This error is inside the `sepdk` module Makefile and can be patched by changing one line though:

<div id="code-sepdmakefix" class="codeblock">
<pre>
--- Makefile.bak  2023-08-11 14:12:33.292790260 +0100
+++ Makefile  2023-08-10 16:52:17.361282977 +0100
@@ -266,7 +266,7 @@
  fi;
 endif
  @if [ -d socwatch ]; then          \
-   $(eval SOCWATCH_DRIVER_FILENAME=`ls socwatch/drivers | grep socwatch | grep .ko | cut -d '.' -f 1`) \
+   $(eval SOCWATCH_DRIVER_FILENAME:=$(shell ls socwatch/drivers | grep socwatch | grep .ko | head -1 | cut -d '.' -f 1)) \
    $(eval NEW_SOCWATCH_DRIVER_FILENAME=$(SOCWATCH_DRIVER_FILENAME)-$(PLATFORM)-$(KERNEL_VERSION)$(ARITY).ko) \
    mv socwatch/drivers/$(SOCWATCH_DRIVER_FILENAME).ko socwatch/drivers/$(NEW_SOCWATCH_DRIVER_FILENAME) ; \
  fi;
</pre>
</div>

Note that even with this fix, there still may be spurious errors when trying to move the files.
Those can be fixed by just deleting the compiled kernel modules (`.ko` files) in `socwatch/drivers`.


# Kernel configuration

To properly use the sampling drivers and VTune, the kernel needs to be configured to allow CPU events access through the
`perf_event_paranoid` setting, where the settings are:
 * `-1` - Not paranoid (no security)
 * `0` - Disallow raw trace access for unprivileged users
 * `1` - Disallow CPU event access for unprivileged users
 * `2` - Disallow all kernel-level profiling for unprivileged users.


By default, many kernels use level 2, while for VTune level 0 is preferred.
The current level can be seen by running:
<div id="code-event" class="codeblock">
<pre>
sysctl kernel.perf_event_paranoid
</pre>
</div>

This can be changed for a single boot by running:

<div id="code-event" class="codeblock">
<pre>
sudo sysctl -w kernel.perf_event_paranoid=0
</pre>
</div>

And the setting can be made permanent by adding a new file to sysctl to change the setting on boot:
<div id="code-event" class="codeblock">
<pre>
echo "kernel.perf_event_paranoid=0" | sudo tee -a /etc/sysctl.d/10-vtune.conf
</pre>
</div>


# User setup

In order for a user to use VTune with the sampling driver, they must be in the `vtune` group.

<div id="code-vtunegroup" class="codeblock">
<pre>
sudo usermod -a -G vtune user
</pre>
</div>


# Testing the install

VTune can be tested using the included `vtune-self-checker.sh` script, located at `vtune/latest/bin64/vtune-self-checker.sh`.
This script will automatically test various parts of the by attempting data collection, and report what collections are possible
and any warnings or errors that it finds.
