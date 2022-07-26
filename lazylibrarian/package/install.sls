# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as lazylibrarian with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

LazyLibrarian user account is present:
  user.present:
{%- for param, val in lazylibrarian.lookup.user.items() %}
{%-   if val is not none and param not in ["groups", "gid"] %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ lazylibrarian.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false
{%- if not lazylibrarian.lookup.media_group.gid %}]
    - gid: {{ lazylibrarian.lookup.user.gid or "null" }}
{%- else %}
    - gid: {{ lazylibrarian.lookup.media_group.gid }}
    - require:
      - group: {{ lazylibrarian.lookup.media_group.name }}
  group.present:
    - name: {{ lazylibrarian.lookup.media_group.name }}
    - gid: {{ lazylibrarian.lookup.media_group.gid }}
{%- endif %}

LazyLibrarian user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ lazylibrarian.lookup.user.name }}
    - enable: {{ lazylibrarian.install.rootless }}
    - require:
      - user: {{ lazylibrarian.lookup.user.name }}

LazyLibrarian paths are present:
  file.directory:
    - names:
      - {{ lazylibrarian.lookup.paths.base }}
    - user: {{ lazylibrarian.lookup.user.name }}
    - group: __slot__:salt:user.primary_group({{ lazylibrarian.lookup.user.name }})
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
{%-   if val is not none and param not in ["service"] %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- if lazylibrarian.container.userns_keep_id and lazylibrarian.install.rootless %}
    - podman_create_args:
{%-   if lazylibrarian.lookup.compose.create_pod is false %}
{#-     post-map.jinja ensures this is in pod_args if pods are in use #}
        # this maps the host uid/gid to the same ones inside the container
        # important for network share access
        # https://github.com/containers/podman/issues/5239#issuecomment-587175806
      - userns: keep-id
{%-   endif %}
        # linuxserver images generally assume to be started as root,
        # then drop privileges as defined in PUID/PGID.
      - user: 0
{%- endif %}
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
