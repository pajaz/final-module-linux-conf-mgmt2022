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
