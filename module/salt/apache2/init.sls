apache2:
  pkg.installed
   
/etc/apache2/mods-enabled/userdir.conf:
  file.symlink:
    - target: ../mods-available/userdir.conf
   
/etc/apache2/mods-enabled/userdir.load:
  file.symlink:
    - target: ../mods-available/userdir.load

/etc/apache2/sites-enabled/000-default.conf:
  file.managed:
    - source: salt://apache2/000-default.conf

/home/webctrl/www/html/index.html:
  file.managed:
    - source: salt://apache2/default-index.html
    - makedirs: True
    - mode: '754'

apache2service:
  service.running:
    - name: apache2
    - watch:
      - file: /etc/apache2/mods-enabled/userdir.conf
      - file: /etc/apache2/mods-enabled/userdir.load
      - file: /etc/apache2/sites-enabled/000-default.conf

/etc/skel/public_html/index.html:
  file.managed:
    - source: salt://apache2/user-default-index.html
    - mode: '754'
    - makedirs: True
