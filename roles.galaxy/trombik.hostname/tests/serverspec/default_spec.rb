require "spec_helper"
require "serverspec"
require "multi_json"

fqdn = "fqdn.example.org"
short_name = fqdn.split(".").first
default_user = "root"
default_group = "root"

case os[:family]
when "freebsd", "openbsd"
  default_group = "wheel"
end

case os[:family]
when "redhat"
  describe file("/etc/sysconfig/network") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^HOSTNAME="#{Regexp.escape(short_name)}"$/) }
  end
when "freebsd"
  describe file("/etc/rc.conf") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^hostname="#{Regexp.escape(short_name)}"$/) }
  end
when "openbsd"
  describe file("/etc/myname") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^#{Regexp.escape(short_name)}$/) }
  end
when "ubuntu"
  describe file("/etc/hostname") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^#{Regexp.escape(short_name)}$/) }
  end
end

case os[:family]
when "freebsd", "openbsd"
  # XXX BSDs allows users to set FQDN. but `hostname(1)` does not lookup
  # `/etc/hosts` when `hostname` is short. in this case, even if FQDN is in
  # `hosts(5)`, hostname does not return FQDN.
  describe command("hostname -s") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    its(:stdout) { should match(/^#{Regexp.escape(short_name)}$/) }
  end
when "redhat", "ubuntu"
  # XXX Linux distributions does not allow users (officially) to set FQDN by
  # `hostname(1)`. `hostname(1)` looks up `hosts(5)`. it the FQDN is in
  # `hosts(5)`, `hostname(1)` returns FQDN.
  describe command("hostname --fqdn") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    its(:stdout) { should match(/^#{Regexp.escape(fqdn)}$/) }
  end

  describe command("hostname --short") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    its(:stdout) { should match(/^#{Regexp.escape(short_name)}$/) }
  end
end

describe command("ping -c 1 -q #{fqdn}") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/#{Regexp.escape("127.0.0.1")}/) }
end

describe command("ansible -m setup localhost") do
  # XXX work around #16615 https://github.com/ansible/ansible/issues/16615
  let(:command_output_as_json) { MultiJson.load(subject.stdout.gsub("localhost | SUCCESS =>", "")) }

  its(:exit_status) { should eq 0 }
  it "outputs a valid JSON" do
    expect { command_output_as_json }.not_to raise_error
  end
  it "contains correct ansible_fqdn" do
    expect(command_output_as_json).to include("ansible_facts" => include("ansible_fqdn" => fqdn))
  end
  it "contains correct ansible_hostname" do
    expect(command_output_as_json).to include("ansible_facts" => include("ansible_hostname" => short_name))
  end
end
