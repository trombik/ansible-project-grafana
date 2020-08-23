# ansible-role-hostname

Configure `hostname(1)`

## Notes for all users

`hostname` is NOT a FQDN. Some OSes allows to set domain name of the
`hostname`, but the domain name does not belong to system configuration. It
belongs to DNS. A system cannot _belong_ to a domain (exceptions: Active
Directory). You cannot set FQDN with this role. Use DNS or `trombik.hosts` to
make FQDN work on the host. However, BSDs allow users to set FQDN in
`rc.conf(5)`. BSDs' behaviours are different from others when `hostname` is
short one, and DNS record for the name is available. In that case, use
`hostname_fqdn`.

Previous versions of the role allow users to set FQDN in some OSes. The role
reverts to old behaviour if `hostname_fqdn` is defined.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `hostname_short` | string of `hostname` | `""` |
| `hostname_fqdn` | string of `FQDN` | `""` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - trombik.hosts
    - ansible-role-hostname
  vars:
    fqdn: fqdn.example.org
    hostname_short: "{{ fqdn.split('.') | first }}"
    hosts_extra_localhosts:
      - "{{ fqdn }}"
      - "{{ hostname_short }}"
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <y@trombik.org>

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
