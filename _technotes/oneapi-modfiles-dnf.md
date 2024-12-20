---
layout: technote
title: Updating oneAPI Module Files using DNF
summary: Updating the oneAPI module files after adding/removing versions using DNF
category: [oneAPI, Fedora]
---

The Intel oneAPI tools do not automatically create module files when they are installed using DNF (or remove old module files when they are removed).
Instead, a DNF action plugin can be used to run the modulefiles setup script after and DNF transaction modifying an Intel package.
The plugin architecture changed between DNF 4 and DNF 5, so slightly different steps are needed for each one.

# DNF 5

For DNF 5, the libDNF [actions plugin](https://dnf5.readthedocs.io/en/latest/libdnf5_plugins/actions.8.html) can be used, but this is not installed by default, so it must be installed manually using the DNF command:
<div id="code-dnf5plugininstall" class="codeblock">
<pre>
dnf install libdnf5-plugin-actions
</pre>
</div>

Once installed, it should be automatically activated, but this can be confirmed by checking the `enabled` key in the `/etc/dnf/libdnf5-plugins/actions.conf` file.

Next, create the action to update the modulefiles by creating a file `oneapi_modulefiles.actions` inside the directory `etc/dnf/libdnf5-plugins/actions.d` directory with the contents
<div id="code-dnf5pluginconfig" class="codeblock">
<pre>
# Update the module files for oneAPI if any changes are made in the installation directory
post_transaction:intel-oneapi-*:::/usr/bin/sh -c /opt/intel/oneapi/modulefiles-setup.sh\ --force\ --output-dir=/opt/intel/oneapi/modulefiles\ >>/tmp/intel_modfile.log
</pre>
</div>

Now, anytime a package starting with `intel-oneapi` is installed or removed, the modulefiles will be regenerated into the `/opt/intel/oneapi/modulefiles` directory.
Note that the output of the modulefile generation script will be sent to the temporary file `/tmp/intel_modfile.log` instead of being printed to the terminal.

# DNF 4

For DNF 4, the DNF [post-transactions-actions](https://dnf-plugins-core.readthedocs.io/en/latest/post-transaction-actions.html) plugin can be used, but this is not installed by default, so it must be installed manually using the DNF command:
<div id="code-dnf4plugininstall" class="codeblock">
<pre>
dnf install python3-dnf-plugin-post-transaction-actions
</pre>
</div>

Once installed, it should be automatically activated, but this can be confirmed by checking the `enabled` key in the `/etc/dnf/plugins/post-transaction-actions.conf` file.

Next, create the action to update the modulefiles by creating a file `oneapi_modulefiles.action` inside the directory `/etc/dnf/plugins/post-transaction-actions.d` directory with the contents
<div id="code-dnf4pluginconfig" class="codeblock">
<pre>
# Update the module files for oneAPI if any changes are made in the installation directory
intel-oneapi-*:any:/opt/intel/oneapi/modulefiles-setup.sh --force --output-dir=/opt/intel/oneapi/modulefiles
</pre>
</div>

Now, anytime a package starting with `intel-oneapi` is installed or removed, the modulefiles will be regenerated into the `/opt/intel/oneapi/modulefiles` directory.
Note that the output of the modulefile generation script will be printed to the terminal during the DNF transaction.