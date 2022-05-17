chromium:
  pkg.installed
/etc/chromium/policies/managed/policies.json:
  file.managed:
    - source: salt://chromium/chromium-default-policies.json
    - makedirs: True
