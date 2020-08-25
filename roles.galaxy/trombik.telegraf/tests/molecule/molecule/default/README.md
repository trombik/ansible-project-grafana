## scenario `default`

### Description

This scenario creates two `virtualbox` instances, `client1` and `server1`.
`telegraf` is running on both hosts. Host metrics are forwarded to `influxdb`
on `server1`. `grafana` on `server1` shows the metrics.

`grafana` URL is [http://192.168.21.200:3000](http://192.168.21.200:3000).
Login credential is `admin` and `PassWord`.
