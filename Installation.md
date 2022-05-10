# Linux Configuration Management Final (Installation guide)

Part of Linux Configuration Management ICT4TN022-3015 course of Haaga-Helia University of Applied Sciences held by Tero Karvinen. Course is in Finnish.  

Course page: https://terokarvinen.com/2021/configuration-management-systems-2022-spring/  

Created by: Mikko Pajunen (pajaz)
Current stage: Alpha

This project is published under GPL-2.0-only (GNU General Public License v2.0).  
https://opensource.org/licenses/gpl-2.0.php   

This document will go through the step by step guide for installation of the module.  

## TLDR (I just want to try it out)

1. Install two virtual computers running Debian based Linux on the same network  
    - Tested on Debian 11 Bullseye  
2. Install salt-master on one and open firewall ports if necessary  
    - https://docs.saltproject.io/en/latest/topics/tutorials/firewall.html  
3. Install salt-minion on the other, define master and id in /etc/salt/minion -file and restart salt-minion.service  
4. Accept the minions key on the master: `sudo salt-key -A`   
5. Clone this repository and copy the files in directory 'module' to your salt file root.  
    - `sudo cp -r PATH_TO_PROJECT/final-module-linux-conf-mgmt2022/module/* /srv/salt/`  
6. Run the only state currently implemented: `sudo salt '*' state.apply user-packages`  

## Devices and user accounts for demonstration 

Devices:  
1 Administrative unit    
1 Web server  
1 User workstation  

Users:  
root, All systems will have root access enabled but admin users will have sudo -rights.  
xzadminal, Ally Administrator, admin (sudo on all devices)  
workewi, Willy Worker, user (regular user on personal workstation and web server)  
webctrl, user (regular user on the web-server in charge of the company website)  

Systems will run as a Virtual Box instances for the purposes of the demonstration.  

## Administration Unit

Naming: C0001
  
- Operating system: Debian 11 Bullseye Linux
- Desktop Environment: Gnome  
- Memory: 2gb (Enough for the purpose of this test)  
- Disk Space: 15gb (Dynamic)  
- Network adapter: Bridged Adapter 

## Workstation (User)

Naming: U0001 

- Operating system: Debian 11 Bullseye Linux
- Desktop Environment: Gnome  
- Memory: 2gb (Enough for the purpose of this test)  
- Disk Space: 15gb (Dynamic)  
- Network adapter: Bridged Adapter  

## Webserver 

Naming: W0001

- Operating system: Ubuntu Server 22.04  
- Desktop Environment: No  
- Memory: 2gb (Enough for the purpose of this test)  
- Disk Space: 15gb  
- Network adapter: Bridged Adapter  

## Administration Unit setup

I started by booting up the Administration Unit for the first time and running the basic apt-get update and upgrade.  
Installed the packages defined in the [Description](Description.md), enabled the firewall (ufw) and allowed connections to the computer through port 22 for ssh. 
```
$ sudo apt-get update
$ sudo apt-get upgrade -y
$ sudo apt-get install ufw openssh-server openssh-client salt-master bash-completion python3 micro git
$ sudo ufw enable
$ sudo ufw allow 22/tcp 
Rules updated
Rules updated (v6)
Firewall is active and enabled on system startup
```

Salt-Master installation and enabling firewall rules (Firewall rules need to be enabled only on Master (https://docs.saltproject.io/en/latest/topics/tutorials/firewall.html)):
```
$ sudo apt-get install salt-master
$ sudo mkdir /srv/salt
$ sudo micro /etc/ufw/applications.d/salt.ufw
xzadminal@C0001:/srv/salt$ cat /etc/ufw/applications.d/salt.ufw 

# File from https://github.com/saltstack/salt/blob/master/pkg/salt.ufw
# On some operating systems this file is created automatically
# Install into /etc/ufw/applications.d/ and run 'ufw app update salt' to add salt
# firewall rules to systems with UFW.  Activate with 'ufw allow salt'
[Salt]
title=salt
description=fast and powerful configuration management and remote execution
ports=4505,4506/tcp

$ sudo ufw app update salt
$ sudo ufw allow salt
Rule added
Rule added (v6)
```

## User Workstation setup

During installation phase, only the user account was created and the initial configuration was done as root. For now I will manually add the only admin user I have to the system but will later on try to automate the process.

```
$ apt-get update
$ apt-get upgrade -y
$ apt-get install salt-minion
$ sudoedit /etc/salt/minion

# Following lines changed
master: 192.168.1.5
id: U0001

$ systemctl restart salt-minion.service
$ adduser xzadminal
$ adduser xzadminal sudo
$ logout
```

Accepted the key on the Master computer and tested connection:
```
$ sudo salt-key -A
The following keys are going to be accepted:
Unaccepted Keys:
U0001
Proceed? [n/Y] Y
Key for minion U0001 accepted.
$ sudo salt 'U0001' test.ping
U0001:
    True
```

## First state

Created a state called user-packages containing the packages that need to be installed on every user workstation and ran it succesfully:
```
$ pwd
/srv/salt
$ sudo mkdir user-packages
$ cd user-packages/
$ sudo micro init.sls
$ cat init.sls 
user-packages:
  pkg.installed:
    - pkgs:
      - firefox-esr
      - chromium
      - ufw
      - openssh-server
      - openssh-client
      - bash-completion
      - flameshot
      - gedit
      - micro
      - filezilla
      - keepassxc
      - git
$ sudo salt 'U0001' state.apply user-packages
# The output is long as so many changes happened, so here's the important parts
Comment: 8 targeted packages were installed/updated.
              The following packages were already installed: firefox-esr, openssh-client, bash-completion, gedit
Summary for U0001
------------
Succeeded: 1 (changed=1)
Failed:    0
------------
Total states run:     1
Total run time:  48.110 s
```

So everything works fine for now.  
Applications needing their own states:  
ufw for setting up the ports for ssh connections  
sshd to only allow ssh connections from admin users and/or C0001 (master)  
filezilla to set up sftp  
firefox-esr and chromium to disallow users from installing their own browser plugins and forcing a uBlock installation.  


