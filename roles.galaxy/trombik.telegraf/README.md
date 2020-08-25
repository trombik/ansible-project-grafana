# ansible-role-telegraf

`ansible` for `telegraf`.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `telegraf_user` | User name of `telegraf` | `{{ __telegraf_user }}` |
| `telegraf_group` | Group name of `telegraf` | `{{ __telegraf_group }}` |
| `telegraf_package` | Package name of `telegraf` | `{{ __telegraf_package }}` |
| `telegraf_extra_packages` | List of extra packages to install | `[]` |
| `telegraf_log_dir` | Path to log directory | `{{ __telegraf_log_dir }}` |
| `telegraf_db_dir` | Path to database directory | `{{ __telegraf_db_dir }}` |
| `telegraf_service` | Service name of `telegraf` | `{{ __telegraf_service }}` |
| `telegraf_conf_dir` | Path to configuration directory | `{{ __telegraf_conf_dir }}` |
| `telegraf_conf_file` | Path to `telegraf.conf` | `{{ __telegraf_conf_dir }}/telegraf.conf` |
| `telegraf_config` | Content of `telegraf.conf` | `""` |
| `telegraf_flags` | Flags for `telegraf` service | `""` |

## Debian

| Variable | Default |
|----------|---------|
| `__telegraf_user` | `telegraf` |
| `__telegraf_group` | `telegraf` |
| `__telegraf_package` | `telegraf` |
| `__telegraf_db_dir` | `/var/lib/telegraf` |
| `__telegraf_service` | `telegraf` |
| `__telegraf_conf_dir` | `/etc/telegraf` |
| `__telegraf_log_dir` | `/var/log/telegraf` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__telegraf_user` | `telegraf` |
| `__telegraf_group` | `telegraf` |
| `__telegraf_package` | `net-mgmt/telegraf` |
| `__telegraf_db_dir` | `/var/db/telegraf` |
| `__telegraf_service` | `telegraf` |
| `__telegraf_conf_dir` | `/usr/local/etc` |
| `__telegraf_log_dir` | `/var/log/telegraf` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__telegraf_user` | `_telegraf` |
| `__telegraf_group` | `_telegraf` |
| `__telegraf_package` | `telegraf` |
| `__telegraf_db_dir` | `/var/telegraf` |
| `__telegraf_service` | `telegraf` |
| `__telegraf_conf_dir` | `/etc/telegraf` |
| `__telegraf_log_dir` | `/var/log/telegraf` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - role: trombik.freebsd_pkg_repo
      when:
        - ansible_os_family == 'FreeBSD'
    - role: trombik.apt_repo
      when:
        - ansible_os_family == 'Debian'
    - role: trombik.influxdb
    - role: ansible-role-telegraf
  vars:
    freebsd_pkg_repo:
      FreeBSD_latest:
        enabled: "true"
        state: present
        # use a mirror in Asia
        url: pkg+http://pkg0.twn.freebsd.org/${ABI}/latest
        mirror_type: srv
        signature_type: fingerprints
        fingerprints: /usr/share/keys/pkg
        priority: 100
    apt_repo_keys_to_add:
      - https://repos.influxdata.com/influxdb.key
    apt_repo_to_add: "deb https://repos.influxdata.com/{{ ansible_distribution | lower }} {{ ansible_distribution_release }} stable"
    apt_repo_enable_apt_transport_https: yes

    os_telegraf_flags:
      FreeBSD: |
        telegraf_flags="-debug"
      Debian: |
        TELEGRAF_OPTS="-debug"
      OpenBSD: -debug
    telegraf_flags: "{{ os_telegraf_flags[ansible_os_family] }}"
    os_telegraf_packages:
      FreeBSD:
        - net-mgmt/net-snmp
      OpenBSD:
        - net-snmp
      Debian:
        - snmp
    telegraf_extra_packages: "{{ os_telegraf_packages[ansible_os_family] }}"
    telegraf_config: |
      [global_tags]
      [agent]
        interval = "10s"
        round_interval = true
        metric_batch_size = 1000
        metric_buffer_limit = 10000
        collection_jitter = "0s"
        flush_interval = "10s"
        flush_jitter = "0s"
        precision = ""
        debug = false
        quiet = false
        logfile = "{{ telegraf_log_dir }}/telegraf.log"
        hostname = "{{ ansible_hostname }}"
        omit_hostname = false
      [[inputs.cpu]]
        percpu = true
        totalcpu = true
        collect_cpu_time = false
        report_active = false
      [[inputs.disk]]
        ignore_fs = ["tmpfs", "devtmpfs", "devfs", "overlay", "aufs", "squashfs"]
      [[inputs.diskio]]
      [[inputs.kernel]]
      [[inputs.mem]]
      [[inputs.processes]]
      [[inputs.socket_listener]]
        service_address = "tcp://127.0.0.1:8094"
        data_format = "influx"

      # broken at the moment. https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=240570
      # [[inputs.swap]]
      #
      # does not work on OpenBSD
      # [[inputs.system]]
      [[outputs.influxdb]]
        urls = ["http://127.0.0.1:8086"]
        database = "mydatabase"
        username = "write_only"
        password = "write_only"
        skip_database_creation = true
    influxdb_admin_username: admin
    influxdb_admin_password: PassWord
    influxdb_tls: no
    influxdb_bind_address: 127.0.0.1:8086
    influxdb_users:
      - user_name: foo
        user_password: PassWord
        grants:
          - database: mydatabase
            privilege: ALL
      - user_name: write_only
        user_password: write_only
        grants:
          - database: mydatabase
            privilege: WRITE
      - user_name: read_only
        user_password: read_only
        grants:
          - database: mydatabase
            privilege: READ
      - user_name: none
        user_password: none
      - user_name: bar
        state: absent
    influxdb_databases:
      - database_name: mydatabase
        state: present

    influxdb_config: |
      reporting-disabled = true
      # this one is bind address for backup process
      bind-address = "127.0.0.1:8088"
      [meta]
        dir = "{{ influxdb_db_dir }}/meta"
      [data]
        dir = "{{ influxdb_db_dir }}/data"
        wal-dir = "{{ influxdb_db_dir }}/wal"
      [coordinator]
      [retention]
      [shard-precreation]
      [monitor]
      [http]
        auth-enabled = true
        bind-address = "{{ influxdb_bind_address }}"
        access-log-path = "{{ influxdb_log_dir }}/access.log"
      [ifql]
      [logging]
      [subscriber]
      [[graphite]]
      [[collectd]]
      [[opentsdb]]
      [[udp]]
      [tls]
```

# License

```
Copyright (c) 2019 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
