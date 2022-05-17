{% for username, data in pillar.get('users', {}).items() %}
{{ username }}:

  group:
    - present
    - name: {{ username }}
    - gid: {{ data.get('gid', '') }}
    
  user:
    - present
    - allow_uid_change: True
    - allow_gid_change: True
    - fullname: {{ data.get('fullname', '') }}
    - shell: /bin/bash
    - name: {{ username }}
    - uid: {{ data.get('uid', '') }}
    - gid: {{ data.get('gid', '') }}
    {% if 'groups' in data %}
    - groups:
      {% for group in data.get('groups', []) %}
      - {{ group }}
      {% endfor %} 
    {% endif %}  
{% if grains['id'] | regex_match('S(.*)') %}
/home/{{ username }}:
  file.directory:
    - mode: 751
{% endif %}
    
{% endfor %}
