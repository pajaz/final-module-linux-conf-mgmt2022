filezilla:
  pkg.installed

/etc/skel/.config/filezilla/filezilla.xml:
  file.managed:
    - source: salt://filezilla/default-filezilla.xml
    - makedirs: True

/etc/skel/.config/filezilla/sitemanager.xml:
  file.managed:
    - source: salt://filezilla/default-sitemanager.xml
    - makedirs: True
