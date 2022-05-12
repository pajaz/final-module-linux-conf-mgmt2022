firefox-esr:
  pkg.installed
/etc/firefox/policies/policies.json:
  file.managed:
    - source: salt://firefox/firefox-default-policies.json
    - makedirs: True
