Description
===========

PF firewall configuration for OS X 10.7 and later. This is a complete package with custom launchd item and control scripts. There's also a Makefile for creating the installer package with [luggage](https://github.com/unixorn/luggage).


Files and locations:
====================

* /Library/LaunchDaemons/com.github.hjuutilainen.pf.plist
	* Launchd item which starts the firewall on boot. Basically calls */usr/local/bin/pf-control.sh* with *restart* argument.
* /etc/com.github.hjuutilainen.pf.conf
	* The main configuration file. We're not modifying the default /etc/pf.conf since Apple seems to modify it in their OS updates. Instead, in this file we call *include /etc/pf.conf* and add our own configuration.
* /etc/pf.anchors/com.github.hjuutilainen.pf.macros
	* The macro file where we define trusted IP addresses and groups. This file is included by the default and custom rule files so anything you define here can be used when writing rules.
* /etc/pf.anchors/com.github.hjuutilainen.pf.rules
	* The actual rule file.
* /etc/pf.anchors/com.github.hjuutilainen.pf.custom
	* The custom rule file. Intended for client specific rules and local editing. The installer creates this in postflight script if it doesn't exist.
* /etc/pf.anchors/com.github.hjuutilainen.pf.d
	* This is a directory which can contain custom rules as files. Intended for the situation where some third-party application requires some special firewall rules. Create a file (programmatically) in this folder and it will be included in the final ruleset.
* /usr/local/bin/pf-control.sh
	* Control script for the firewall. Usage: *pf-control.sh start|stop|restart*
* /usr/local/bin/pf-restart.sh
	* Helper script to quickly unload and load the launchd item.

Files used to create the installer:
===================================

* ./Makefile
	* The Makefile for [luggage](https://github.com/unixorn/luggage). To create the installer package, run *make pkg* in this directory.
* ./postflight
	* Installer postflight script. Loads the firewall if installed on startup disk.
* ./preflight
	* Installer preflight script. Unloads the launchd item (if loaded) and takes a backup of the files about to be overwritten (to /var/backups/).