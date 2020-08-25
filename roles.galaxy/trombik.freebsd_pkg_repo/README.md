# ansible-role-freebsd_pkg_repo

Enable or disable FreeBSD package repositories.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `freebsd_pkg_repo_dir` | path to the repository configuration directory | `/usr/local/etc/pkg/repos` |
| `freebsd_pkg_repo` | | `{}` |


## FreeBSD

| Variable | Default |
|----------|---------|
| `__freebsd_pkg_repo_conf_dir` | `/usr/local/etc/freebsd_pkg_repo` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - ansible-role-freebsd_pkg_repo
  vars:
    freebsd_pkg_repo:
      # disable the default package repository
      FreeBSD:
        enabled: "false"
        state: present
      # enable newer package repository
      FreeBSD_latest:
        enabled: "true"
        state: present
        url: pkg+https://pkg.FreeBSD.org/${ABI}/latest
        mirror_type: srv
        signature_type: fingerprints
        fingerprints: /usr/share/keys/pkg
        priority: 100
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
