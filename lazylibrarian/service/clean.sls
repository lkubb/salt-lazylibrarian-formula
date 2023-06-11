# vim: ft=sls

{#-
    Stops the lazylibrarian container services
    and disables them at boot time.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as lazylibrarian with context %}

lazylibrarian service is dead:
  compose.dead:
    - name: {{ lazylibrarian.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if lazylibrarian.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ lazylibrarian.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if lazylibrarian.install.rootless %}
    - user: {{ lazylibrarian.lookup.user.name }}
{%- endif %}

lazylibrarian service is disabled:
  compose.disabled:
    - name: {{ lazylibrarian.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if lazylibrarian.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ lazylibrarian.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if lazylibrarian.install.rootless %}
    - user: {{ lazylibrarian.lookup.user.name }}
{%- endif %}
