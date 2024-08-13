---
layout: technote
title: Self-hosting WebDAV Storage for Zotero
summary: Configuring a self-hosted lighttpd webDAV server for Zotero file storage
category: [Academic, Fedora]
modified: August 12, 2024
---

When using Zotero as a bibliography management tool, it is very useful to attach copies of the articles to the entry for future reference.
While the Zotero-hosted storage can be used, it is only free for up to 300MB of storage (and with most PDF articles now around ~1MB, that is only about 300 articles).
An alternate option is to use webDAV storage, either from an external company or on a self-hosted server.

This page describes configuring a self-hosted webDAV storage server for Zotero on Fedora 39 using the lighttpd web server suite.

* Do not remove this line (it will not be displayed)
{:toc}


# Package Installation

First, install all the lighttpd packages (the packaged versions in the Fedora repositories will work).
Note, the `httpd-tools` package is needed to generate the .htpasswd file for authentication.

<div id="code-packageinstall" class="codeblock">
<pre>
dnf install lighttpd httpd-tools
</pre>
</div>


# Initial setup

## Creating the directory layout

I will place the Zotero files onto a separate hard disk mounted in `/mnt/Data1`, so in that folder create a new folder to hold the web server contents called `Zotero-WebDav`, and inside of that another folder called `files`, with another folder called `zotero` inside of it.
This can all be done in a single command:

<div id="code-directorycreation" class="codeblock">
<pre>
mkdir -p /mnt/Data1/Zotero-WebDav/files/zotero
</pre>
</div>

Afterwards, the directory structure should look like the following:

<div id="code-directorystructure" class="codeblock">
<pre>
└── Zotero-WebDav
    └── files
        └── zotero
</pre>
</div>

After creating the directories, they all must be given to the `lighttpd` user/group so the web server is able to read/write to them.

<div id="code-directorypermissions" class="codeblock">
<pre>
chown -R lighttpd:lighttpd /mnt/Data1/Zotero-WebDav
</pre>
</div>

Zotero will place all its files inside the `zotero` directory, and after experimentation it appears that it needs to be created before Zotero tries to connect (otherwise it gives weird errors during the Zotero configuration process).

## HTTP Authentication

Since webDAV is an HTTP-based protocol for file storage, the server should have an SSl certificate configured (to do TLS security for the web traffic), and access controls to the webDAV folder (to prevent unauthorized access).

To control access to the webDAV folder, this server will be configured to use the `.htaccess` method to secure the directory.
To do this, create a `.htpasswd` formatted file in the newly created directory, giving the username in the command and typing the password when prompted.

<div id="code-directorypermissions" class="codeblock">
<pre>
htpasswd -c /mnt/Data1/Zotero-WebDav/passwd.dav &lt;username&gt;
chown -R lighttpd:lighttpd /mnt/Data1/Zotero-WebDav/passwd.dav
</pre>
</div>

To allow HTTPS connections, a server SSL key must be created using the following commands:
<div id="code-directorypermissions" class="codeblock">
<pre>
mkdir -p /etc/lighttpd/certs
openssl req -new -x509 -keyout /etc/lighttpd/certs/lighttpd.pem -out /etc/lighttpd/certs/lighttpd.pem -days 365 -nodes
</pre>
</div>

## Configuing SELinux

On systems where SELinux is enabled, the webDAV directories need to be tagged appropiately so that the lighttpd web server is able to access and write to the directories.
Specifically, the main web page folder of `/mnt/Data1/Zotero-WebDav` and its subdirectories must be tagged with `httpd_sys_content_t`, and the actual webDAV folder must be tagged with `httpd_sys_rw_content_t`.

<div id="code-selinuxpermissions" class="codeblock">
<pre>
semanage fcontext -a -t httpd_sys_content_t '/mnt/Data1/Zotero-WebDav'
restorecon -v '/mnt/Data1/Zotero-WebDav'

semanage fcontext -a -t httpd_sys_rw_content_t '/mnt/Data1/Zotero-WebDav/files'
restorecon -v '/mnt/Data1/Zotero-WebDav/files'

semanage fcontext -a -t httpd_sys_rw_content_t '/mnt/Data1/Zotero-WebDav/files/zotero'
restorecon -v '/mnt/Data1/Zotero-WebDav/files/zotero'
</pre>
</div>

The tags can be examined by running `ls -laZ` in the directories, and should be similar to

<div id="code-selinuxresults" class="codeblock">
<pre>
# Inside /mnt/Data1
drwxr-xr-x. 3 lighttpd lighttpd unconfined_u:object_r:httpd_sys_content_t:s0  4096 Jul 19 17:24 Zotero-WebDav

# Inside /mnt/Data1/Zotero-WebDav
drwxr-xr-x. 3 lighttpd lighttpd unconfined_u:object_r:httpd_sys_rw_content_t:s0 4096 Jul 22 19:07 files
-rw-r-----. 1 root     lighttpd unconfined_u:object_r:httpd_sys_content_t:s0      49 Jul 19 17:08 passwd.dav
</pre>
</div>


# Web server configuration

First, enable the required modules by editing the config file `/etc/lighttpd/modules.conf` to add the modules for authentication, webDAV and SSL encryption.
The ordering of the module loading is important, and the following ordering works:

<div id="code-modulelist" class="codeblock">
<pre>
server.modules = (
  "mod_access",
  "mod_alias",
  "mod_auth",
  "mod_authn_file",
  "mod_webdav",
  "mod_openssl",
)
</pre>
</div>

Next, edit the main config file `/etc/lighttpd/lighttpd.conf` and uncomment the line containing `include conf_dir + "/vhosts.d/*.conf"` to enable adding the webDAV site in its own configuration file.
Additionally, enable a main HTTPS site by uncommenting the SSL support lines and updating the path to the SSl certificate, giving the following configuration:
<div id="code-modulelist" class="codeblock">
<pre>
$SERVER["socket"] == "*:443" {
    ssl.engine  = "enable"
    ssl.pemfile = "/etc/lighttpd/certs/lighttpd.pem"
}
</pre>
</div>

Create a new virtual host in the file `/etc/lighttpd/vhosts.d/webdav.conf` to contain the definition of the webDAV system with the following contents (updating the server's hostname as needed):
<div id="code-modulelist" class="codeblock">
<pre>
$HTTP["host"] == "server.fqdn" {
   var.server_name = "server.fqdn"
   server.name = server_name
   $HTTP["url"]              =~ "^/webdav($|/)" {
     alias.url                 = ( "/webdav" => "/mnt/Data1/Zotero-WebDav/files" )
     dir-listing.activate    = "enable"
     dir-listing.encoding    = "utf-8"
     webdav.activate         = "enable"
     webdav.is-readonly      = "disable"
     webdav.sqlite-db-name   = "/var/run/lighttpd/lighttpd.webdav_lock.db"
     webdav.log-xml          = "enable"
     auth.backend            = "htpasswd"
     auth.backend.htpasswd.userfile = "/mnt/Data1/Zotero-WebDav/passwd.dav"
     auth.require            = ( "" =>
                                 (
                                     "method" => "basic",
                                     "realm" => "webdav",
                                     "require" => "valid-user"
                                 )
                               )
     }
 }
</pre>
</div>

# Starting the web server

Enable and start the systemd service for lighttpd to actually run the server.
<div id="code-systemd" class="codeblock">
<pre>
systemctl enable lighttpd
systemctl start lighttpd
</pre>
</div>

Finally, examine the logs to ensure the server started successfully

<div id="code-systemd" class="codeblock">
<pre>
$ systemctl status lighttpd
● lighttpd.service - Lightning Fast Webserver With Light System Requirements
     Loaded: loaded (/usr/lib/systemd/system/lighttpd.service; enabled; preset: disabled)
    Drop-In: /usr/lib/systemd/system/service.d
             └─10-timeout-abort.conf
     Active: active (running) since Tue 2024-08-13 15:55:24 BST; 20min ago
    Process: 2765821 ExecStartPre=/usr/sbin/lighttpd -tt -f /etc/lighttpd/lighttpd.conf (code=exited, status=0/SUCCESS)
   Main PID: 2765825 (lighttpd)
      Tasks: 1 (limit: 154088)
     Memory: 2.4M
        CPU: 135ms
     CGroup: /system.slice/lighttpd.service
             └─2765825 /usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf
</pre>
</div>

# Configuring Zotero


## Allowing self-signed SSL certificates

Since the SSL certificate is self-signed, it requires special handling in Zotero to allow connections (by default, self-signed certificates are rejected unless they are overriden).
To do this, follow the instructions on the [Zotero knowledge base](https://www.zotero.org/support/kb/cert_override).
To generate the override file, either the older version of Firefox can be used, or a Python tool called [firefox-cert-override](https://github.com/Osmose/firefox-cert-override) can be used.

To use the Python tool, create a new virtual environment to install it into, copy the certificate from the server, and then use the command
<div id="code-systemd" class="codeblock">
<pre>
firefox-cert-override &lt;hostname&gt;:443=lighttpd.pem[MUT]
</pre>
</div>
Then place the generated file into the Zotero profile directory and restart Zotero.

## Settings

After setting up the server, Zotero can be configured to use the webDAV server in `Preferences` dialog on the `Sync/Settings` tab, and changing the `Sync attachment files in My Library` to be `WebDAV` instead of `Zotero`.
Then, enter the server details and username/password.


