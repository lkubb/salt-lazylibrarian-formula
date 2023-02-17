# vim: ft=sls

{#-
    Removes the configuration of the lazylibrarian containers
    and has a dependency on `lazylibrarian.service.clean`_.

    This does not lead to the containers/services being rebuilt
    and thus differs from the usual behavior.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as lazylibrarian with context %}

include:
  - {{ sls_service_clean }}

LazyLibrarian environment files are absent:
  file.absent:
    - names:
      - {{ lazylibrarian.lookup.paths.config_lazylibrarian }}
      - {{ lazylibrarian.lookup.paths.data | path_join("config.ini") }}
    - require:
      - sls: {{ sls_service_clean }}
