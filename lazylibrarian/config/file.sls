# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as lazylibrarian with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

LazyLibrarian environment files are managed:
  file.managed:
    - names:
      - {{ lazylibrarian.lookup.paths.config_lazylibrarian }}:
        - source: {{ files_switch(
                        ["lazylibrarian.env", "lazylibrarian.env.j2"],
                        config=lazylibrarian,
                        lookup="lazylibrarian environment file is managed",
                        indent_width=10,
                     )
                  }}
    - mode: '0640'
    - user: root
    - group: __slot__:salt:user.primary_group({{ lazylibrarian.lookup.user.name }})
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ lazylibrarian.lookup.user.name }}
    - require_in:
      - LazyLibrarian is installed
    - context:
        lazylibrarian: {{ lazylibrarian | json }}

LazyLibrarian settings are managed:
  file.serialize:
    - name: {{ lazylibrarian.lookup.paths.data | path_join("config.ini") }}
    - serializer: configparser
    - merge_if_exists: true
    - dataset: {{ lazylibrarian.config | json }}
    - user: {{ lazylibrarian.lookup.user.name }}
    - group: __slot__:salt:user.primary_group({{ lazylibrarian.lookup.user.name }})
    # Creating this file and managing ownership is fine, the entrypoint script
    # ensures the correct permissions.
    # - create: false
