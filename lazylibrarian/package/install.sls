# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as lazylibrarian with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

LazyLibrarian user account is present:
  user.present:
{%- for param, val in lazylibrarian.lookup.user.items() %}
{%-   if val is not none and param != "groups" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ lazylibrarian.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false

LazyLibrarian user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ lazylibrarian.lookup.user.name }}
    - enable: {{ lazylibrarian.install.rootless }}

LazyLibrarian paths are present:
  file.directory:
    - names:
      - {{ lazylibrarian.lookup.paths.base }}
    - user: {{ lazylibrarian.lookup.user.name }}
    - group: {{ lazylibrarian.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ lazylibrarian.lookup.user.name }}

LazyLibrarian compose file is managed:
  file.managed:
    - name: {{ lazylibrarian.lookup.paths.compose }}
    - source: {{ files_switch(['docker-compose.yml', 'docker-compose.yml.j2'],
                              lookup='LazyLibrarian compose file is present'
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ lazylibrarian.lookup.rootgroup }}
    - makedirs: True
    - template: jinja
    - makedirs: true
    - context:
        lazylibrarian: {{ lazylibrarian | json }}

LazyLibrarian is installed:
  compose.installed:
    - name: {{ lazylibrarian.lookup.paths.compose }}
{%- for param, val in lazylibrarian.lookup.compose.items() %}
{%-   if val is not none and param != "service" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- for param, val in lazylibrarian.lookup.compose.service.items() %}
{%-   if val is not none %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - watch:
      - file: {{ lazylibrarian.lookup.paths.compose }}
{%- if lazylibrarian.install.rootless %}
    - user: {{ lazylibrarian.lookup.user.name }}
    - require:
      - user: {{ lazylibrarian.lookup.user.name }}
{%- endif %}
