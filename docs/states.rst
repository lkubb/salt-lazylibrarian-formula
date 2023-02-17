Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``lazylibrarian``
^^^^^^^^^^^^^^^^^
*Meta-state*.

This installs the lazylibrarian containers,
manages their configuration and starts their services.


``lazylibrarian.package``
^^^^^^^^^^^^^^^^^^^^^^^^^
Installs the lazylibrarian containers only.
This includes creating systemd service units.


``lazylibrarian.config``
^^^^^^^^^^^^^^^^^^^^^^^^
Manages the configuration of the lazylibrarian containers.
Has a dependency on `lazylibrarian.package`_.


``lazylibrarian.service``
^^^^^^^^^^^^^^^^^^^^^^^^^
Starts the lazylibrarian container services
and enables them at boot time.
Has a dependency on `lazylibrarian.config`_.


``lazylibrarian.clean``
^^^^^^^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``lazylibrarian`` meta-state
in reverse order, i.e. stops the lazylibrarian services,
removes their configuration and then removes their containers.


``lazylibrarian.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the lazylibrarian containers
and the corresponding user account and service units.
Has a depency on `lazylibrarian.config.clean`_.
If ``remove_all_data_for_sure`` was set, also removes all data.


``lazylibrarian.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the lazylibrarian containers
and has a dependency on `lazylibrarian.service.clean`_.

This does not lead to the containers/services being rebuilt
and thus differs from the usual behavior.


``lazylibrarian.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the lazylibrarian container services
and disables them at boot time.


