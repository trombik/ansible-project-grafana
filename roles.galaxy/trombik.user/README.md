# `trombik.user`

Manage local users.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `user_users` | List of users (see below) | `[]` |

## `user_users`

This is a list of dict. Keys of the dict are described below.

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `name` | Name of the user | Yes |
| `arg`  | A dict of arguments supported by `ansible` [`user`](https://docs.ansible.com/ansible/latest/modules/user_module.html) module | yes |
| `github` | if this key exists, add SSH public key found in GitHub to `authorized_keys`. | no |
| `sshrc` | if this key exists, create `$HOME/.ssh/rc`. The value of this key is the file content | no |

Note that `name` in `arg`, if omitted, defaults to `name` in the dict.

When a user has '$HOME' directory, the role creates '$HOME/.ssh'.

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-user
  vars:
    default_group:
      FreeBSD: wheel
      OpenBSD: wheel
      Debian: users
      RedHat: users
    default_groups:
      FreeBSD:
        - dialer
        - video
      OpenBSD:
        - dialer
        - games
      Debian:
        - dialout
        - video
      RedHat:
        - dialout
        - video
    user_users:
      - name: user_without_home
        arg:
          group: "{{ default_group[ansible_os_family] }}"
          create_home: "no"
      - name: user_without_ssh_key
        arg:
          group: "{{ default_group[ansible_os_family] }}"
      - name: trombik
        arg:
          comment: Tomoyuki Sakurai
          group: "{{ default_group[ansible_os_family] }}"
          groups: "{{ default_groups[ansible_os_family] }}"
          shell: /bin/sh
        github:
          user: trombik
        sshrc: |
          # see sshd(8)
          if read proto cookie && [ -n "$DISPLAY" ]; then
            if [ `echo $DISPLAY | cut -c1-10` = 'localhost:' ]; then
              # X11UseLocalhost=yes
              echo add unix:`echo $DISPLAY | cut -c11-` $proto $cookie
            else
              # X11UseLocalhost=no
              echo add $DISPLAY $proto $cookie
            fi | xauth -q -
          fi
      - name: foo
        arg:
          state: absent
```

# License

```
Copyright (c) 2020 Tomoyuki Sakurai <y@trombik.org>

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
