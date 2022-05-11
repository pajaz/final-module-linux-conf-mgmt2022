# Linux Configuration Management Final (Installation guide)

Part of Linux Configuration Management ICT4TN022-3015 course of Haaga-Helia University of Applied Sciences held by Tero Karvinen. Course is in Finnish.  

Course page: https://terokarvinen.com/2021/configuration-management-systems-2022-spring/  

Created by: Mikko Pajunen (pajaz)  
Current stage: Alpha

This project is published under GPL-2.0-only (GNU General Public License v2.0).  
https://opensource.org/licenses/gpl-2.0.php   

This document will go through the step by step guide for installation of the module.  

## TLDR (I just want to try it out)

1. Install three virtual computers running Debian based Linux on the same network  
    - Tested on 2xDebian 11 Bullseye, 1xUbuntu Server 22.04   
2. Install salt-master on one Debian and open firewall ports if necessary  
    - https://docs.saltproject.io/en/latest/topics/tutorials/firewall.html  
3. Install salt-minion on the others, define master and id in /etc/salt/minion -file and restart salt-minion.service  
4. Accept the minions' keys on the master: `sudo salt-key -A`   
5. Clone this repository and copy the files in directory 'module' to your salt file root.  
    - `sudo cp -r PATH_TO_PROJECT/final-module-linux-conf-mgmt2022/module/* /srv/salt/`  
6. Run the highstate currently implemented: `sudo salt '*' state.apply`

Module files [Here](module/)

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
- Network adapters: NAT, Host-only Adapter

## Workstation (User)

Naming: U0001 

- Operating system: Debian 11 Bullseye Linux
- Desktop Environment: Gnome  
- Memory: 2gb (Enough for the purpose of this test)  
- Disk Space: 15gb (Dynamic)  
- Network adapter: NAT, Host-only Adapter  

## Webserver 

Naming: S0001

- Operating system: Ubuntu Server 22.04   
- Desktop Environment: No  
- Memory: 2gb (Enough for the purpose of this test)  
- Disk Space: 15gb  
- Network adapter: NAT, Host-only Adapter 

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

## Web Server setup

During installation the admin user performing the installation was created.  

Initial setup follows the same path as User Workstation with the exception that one Administrator account has already been created during installation and nano (or your favorite editor) has to be manually installed before editing the files.

## Package states

This section will go through installing the default packages for Web Server and User Workstations

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

```
$ pwd
/srv/salt
$ sudo mkdir webserver-packages
$ cd webserver-packages/
$ sudo micro init.sls
$ cat init.sls 
webserver-packages:
  pkg.installed:
    - pkgs:
      - apache2  
      - ufw  
      - openssh-server  
      - salt-minion  
      - bash-completion  
      - git
```

## SSHD Configuration

Created a state for handling ssh -connections on the Web Server and User Workstations.

### Files and Directories

Explanation | Link
---|---
Module directory: | [sshd](module/sshd/)  
State file: | [init.sls](module/sshd/init.sls)  
User configuration: | [user_sshd_config](module/sshd/user_sshd_config)  
Web Server configuration: | [webserver_sshd_config](module/sshd/webserver_sshd_config)  
Default configuration for reference: | [sshd_config_default.backup](module/sshd/sshd_config_default.backup)  

### Step-by-step

I created the state directory and an .sls file that checks if openssh-server is installed and installs it if necessary:  
```
$ pwd
/srv/salt
$ sudo mkdir sshd
$ cd sshd/
$ sudo micro init.sls
$ cat init.sls
openssh-server:
    pkg.installed
$ sudo salt 'U*' state.apply sshd
```
State was run succesfully
    
I copied the default configuration file /etc/ssh/sshd_config to /srv/salt/sshd, renamed it and added it to managed files: 
```
$ sudo cp /etc/ssh/sshd_config /srv/salt/sshd
$ pwd
/srv/salt
$ sudo mv user_sshd_config
$ sudo micro user_sshd_config
$ sudo micro init.sls 
$ cat init.sls 
openssh-server:
    pkg.installed
/etc/ssh/sshd_config:
    file.managed:
    - source: salt://user_sshd_config
$ sudo salt 'U*' state.apply sshd
```
State was run succesfully.  

Then I added a check to make sure sshd.service is running and set it to restart if the config file changes to apply changes: 
```
$ sudo micro init.sls 
$ cat init.sls 
openssh-server:
    pkg.installed
/etc/ssh/sshd_config:
    file.managed:
    - source: salt://user_sshd_config
sshd:
    service.running:
    - watch:
        - file: /etc/ssh/sshd_config
$ sudo salt 'U*' state.apply sshd
```
State was run succesfully.  

I made a similar configuration file for the web-server called webserver_sshd_config and edited the init.sls file to identify the minion and use the correct configuration file accordingly:
```
$ sudo micro init.sls 
$ cat init.sls 
openssh-server:
  pkg.installed
/etc/ssh/sshd_config:
  file.managed:
    {% if grains['id'] | regex_match('U(.*)') %}
    - source: salt://sshd/user_sshd_config
    {% elif grains['id'] | regex_match('S(.*)') %}
    - source: salt://sshd/webserver_sshd_config
    {% endif %}
sshd:
  service.running:
    - watch:
      - file: /etc/ssh/sshd_config
$ sudo salt '*' state.apply sshd
```
State was run succesfully.  

The Jinja code uses regex_match function to see if the minions ID extracted by grains\[id] starts with a specific letter and applies the correct configuration.  

Finally I added the sshd to the [top.sls](module/top.sls) file under base '*' because it can be run for all current minions safely.  

top.sls file at this point:  
```
base:
  '*':
    - sshd
  'U*':
    - user-packages
  'S*':
    - webserver-packages
```

## Progress

So everything works fine for now.  
Applications needing their own states:  
1. ufw for setting up the ports for ssh connections  
2. sshd to only allow ssh connections from admin users and/or C0001 (master)  
    - ssh access for U* set to only allow connections from Admin console C0001, tested
    - ssh access for S* set to allow connections from anywhere and root access from C0001, tested
3. filezilla to set up sftp  
4. firefox-esr and chromium to disallow users from installing their own browser plugins and forcing a uBlock installation.  


