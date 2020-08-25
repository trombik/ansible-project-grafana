require "spec_helper"
require "serverspec"

package = "telegraf"
service = "telegraf"
config  = "/etc/telegraf/telegraf.conf"
user    = "telegraf"
group   = "telegraf"
ports   = [8094]
log_dir = "/var/log/telegraf"
log_file = "#{log_dir}/telegraf.log"
db_dir = "/var/lib/telegraf"
default_user = "root"
default_group = "root"
extra_packages = []

case os[:family]
when "freebsd"
  config = "/usr/local/etc/telegraf.conf"
  db_dir = "/var/db/telegraf"
  default_group = "wheel"
  extra_packages = ["net-mgmt/net-snmp"]
when "openbsd"
  user = "_telegraf"
  group = "_telegraf"
  db_dir = "/var/telegraf"
  default_group = "wheel"
  extra_packages = ["net-snmp"]
when "ubuntu"
  extra_packages = ["snmp"]
end

extra_packages.each do |p|
  describe package p do
    it { should be_installed }
  end
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content) { should match(/# Managed by ansible/) }
  its(:content) { should match(/\[\[outputs\.influxdb\]\]/) }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 750 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file log_file do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/Successfully connected to (output: influxdb|outputs.influxdb)/) }
  its(:content) { should_not match(/\s+E!\s+/) }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/telegraf") do
    it { should be_file }
    its(:content) { should match(/# Managed by ansible/) }
    its(:content) { should match(/telegraf_flags="-debug"/) }
  end
when "ubuntu"
  describe file("/etc/default/telegraf") do
    it { should be_file }
    its(:content) { should match(/# Managed by ansible/) }
    its(:content) { should match(/TELEGRAF_OPTS="-debug"/) }
  end

when "openbsd"
  describe file("/etc/rc.conf.local") do
    its(:content) { should match(/telegraf_flags=-debug/) }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
