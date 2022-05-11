base:
  '*':
    - sshd
    - ufw
  'U*':
    - user-packages
    - firefox
  'S*':
    - webserver-packages
