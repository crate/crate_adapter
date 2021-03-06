======================================
CHANGES for CrateDB Prometheus Adapter
======================================

Unreleased
==========

2021-05-04 0.4.0
================

BREAKING CHANGES
----------------

- This release changes the toplevel configuration section name to ``cratedb_endpoints``.
  It is an aftermath of the "naming things" refactorings happening in 0.3.0.

CHANGES
-------

- Improve network behaviour: Adjust TCP timeout and keepalive settings to
  mitigate problems that can occur when the adapter in connecting to CrateDB
  via a load balancer that may drop idle connections in-transparently, such as
  in AKS. The default values are:

    - KeepAlive: 30 seconds
    - ConnectTimeout: 10 seconds

  The TCP connect timeout can be adjusted by using the ``-tcp.connect.timeout``
  option.

2021-04-29 0.3.0
================

BREAKING CHANGES
----------------

- This release changes the program name to ``cratedb-prometheus-adapter``
  and the default prefix for exported metrics to ``cratedb_prometheus_adapter_``.
  The latter can be reconfigured using the new ``-metrics.export.prefix`` option.

CHANGES
-------

- Provide a default ``config.yml`` in the Docker image, which can be replaced
  by mounting a file on ``/etc/cratedb-prometheus-adapter/config.yml``.

- Made Go 1.16 a minimum requirement.

- Updated project to make use of `Go modules <https://golang.org/ref/mod>`_
  instead of Govendor.

- Renamed the program to ``cratedb-prometheus-adapter``.

- Renamed the exported metric prefix to ``cratedb_prometheus_adapter_``. It is
  now, for example, ``cratedb_prometheus_adapter_write_latency_seconds``.
  Attention: This is a breaking change with respect to your exported metric
  names. In order to keep the former name, use
  ``./cratedb-prometheus-adapter -metrics.export.prefix=crate_adapter_``.

2019-03-06 0.2.1
================

- Fixed the translation of prometheus queries using regular expressions
  (``metric_name{job=~"something"}``) , so that the generated SQL queries match
  the proper records in CrateDB.

- Fixed an issue that caused reads to increment the write metrics instead of
  the read metrics.

2018-07-10 0.2.0
================

- Use Postgres wire protocol (pgx client library) to connect to CrateDB:

  - This change requires CrateDB 3.1.0 or newer!

  - Connections can be configured via ``crate.yml`` configuration file using
    the ``-config.file`` flag.

  - Added support for multiple endpoints.

2017-06-11 0.1
==============

- Unofficial experimental release
