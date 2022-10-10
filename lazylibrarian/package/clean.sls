# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as lazylibrarian with context %}

include:
  - {{ sls_config_clean }}

{%- if lazylibrarian.install.autoupdate_service %}

Podman autoupdate service is disabled for LazyLibrarian:
{%-   if lazylibrarian.install.rootless %}
  compose.systemd_service_disabled:
    - user: {{ lazylibrarian.lookup.user.name }}
{%-   else %}
  service.disabled:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}

LazyLibrarian is absent:
  compose.removed:
    - name: {{ lazylibrarian.lookup.paths.compose }}
    - volumes: {{ lazylibrarian.install.remove_all_data_for_sure }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if lazylibrarian.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ lazylibrarian.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if lazylibrarian.install.rootless %}
    - user: {{ lazylibrarian.lookup.user.name }}
{%- endif %}
    - require:
      - sls: {{ sls_config_clean }}

LazyLibrarian compose file is absent:
  file.absent:
    - name: {{ lazylibrarian.lookup.paths.compose }}
    - require:
      - LazyLibrarian is absent

LazyLibrarian user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ lazylibrarian.lookup.user.name }}
    - enable: false
    - onlyif:
      - fun: user.info
        name: {{ lazylibrarian.lookup.user.name }}

LazyLibrarian user account is absent:
  user.absent:
    - name: {{ lazylibrarian.lookup.user.name }}
    - purge: {{ lazylibrarian.install.remove_all_data_for_sure }}
    - require:
      - LazyLibrarian is absent
    - retry:
        attempts: 5
        interval: 2

{%- if lazylibrarian.install.remove_all_data_for_sure %}

LazyLibrarian paths are absent:
  file.absent:
    - names:
      - {{ lazylibrarian.lookup.paths.base }}
    - require:
      - LazyLibrarian is absent
{%- endif %}
