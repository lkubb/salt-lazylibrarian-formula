# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as lazylibrarian with context %}

include:
  - {{ sls_config_file }}

LazyLibrarian service is enabled:
  compose.enabled:
    - name: {{ lazylibrarian.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if lazylibrarian.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ lazylibrarian.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
    - require:
      - LazyLibrarian is installed
{%- if lazylibrarian.install.rootless %}
    - user: {{ lazylibrarian.lookup.user.name }}
{%- endif %}

LazyLibrarian service is running:
  compose.running:
    - name: {{ lazylibrarian.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if lazylibrarian.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ lazylibrarian.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if lazylibrarian.install.rootless %}
    - user: {{ lazylibrarian.lookup.user.name }}
{%- endif %}
    - watch:
      - LazyLibrarian is installed
