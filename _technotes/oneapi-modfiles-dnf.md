---
layout: technote
title: Updating oneAPI Module Files using DNF
summary: Updating the oneAPI module files after adding/removing versions using DNF
category: [oneAPI, Fedora]
---

The Intel oneAPI tools do not automatically create module files when they are installed using DNF (or remove old module files when they are removed).
Instead, the DNF [post-transactions-actions](https://dnf-plugins-core.readthedocs.io/en/latest/post-transaction-actions.html) plugin can be used to run the modulefiles setup script after any DNF transaction modifying an Intel package.

This plugin is not installed by default, so it must be installed manually using this DNF command:
<div id="code-plugininstall" class="codeblock">
<pre>
dnf install python3-dnf-plugin-post-transaction-actions
</pre>
</div>

Once installed, it should be automatically activated, but this can be confirmed by checking the `enabled` key in the `/etc/dnf/plugins/post-transaction-actions.conf` file.

Next, create the action to update the modulefiles.
Create a file `oneapi_modulefiles.action` inside the directory `/etc/dnf/plugins/post-transaction-actions.d` directory with the contents
<div id="code-plugininstall" class="codeblock">
<pre>
# Update the module files for oneAPI if any changes are made in the installation directory
intel-oneapi-*:any:/opt/intel/oneapi/modulefiles-setup.sh --force --output-dir=/opt/intel/oneapi/modulefiles
</pre>
</div>

Now, anytime a package starting with `intel-oneapi` is installed or removed, the modulefiles will be regenerated into the `/opt/intel/oneapi/modulefiles` directory.