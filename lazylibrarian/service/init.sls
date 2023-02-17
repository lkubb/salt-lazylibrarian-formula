# vim: ft=sls

{#-
    Starts the lazylibrarian container services
    and enables them at boot time.
    Has a dependency on `lazylibrarian.config`_.
#}

include:
  - .running
