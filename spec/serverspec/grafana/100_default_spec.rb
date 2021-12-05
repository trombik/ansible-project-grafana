# frozen_string_literal: true

require_relative "../spec_helper"
require "net/http"

influxdb_service_name = case os[:family]
                        when "openbsd"
                          "influxdb"
                        else
                          "influxd"
                        end
services = [
  influxdb_service_name
]

default_group = case os[:family]
                when /bsd/
                  "wheel"
                else
                  "users"
                end
default_groups = case os[:family]
                 when /bsd/
                   %w[dialer operator]
                 else
                   %w[dialout sudo]
                 end

context "after provision finishes" do
  it_behaves_like "a host with a valid hostname"
  it_behaves_like "a host with all basic tools installed"
end

services.each do |s|
  describe service s do
    it { should be_enabled }
    it { should be_running }
  end
end

user = credentials_yaml["project_grafana_influxdb_user"]
password = credentials_yaml["project_grafana_influxdb_password"]
host = case test_environment
       when "prod"
         "grafana2.i.trombik.org"
       when "virtualbox"
         "172.16.100.200"
       end
port = 8086

describe command "influx -host #{Shellwords.escape(host)} -port " \
  "#{Shellwords.escape(port)} -username #{Shellwords.escape(user)} -password " \
  "#{Shellwords.escape(password)} -database sensors -execute 'show measurements'" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
end

describe user "trombik" do
  it { should exist }
  it { should belong_to_primary_group default_group }
  default_groups.each do |g|
    it { should belong_to_group g }
  end
end
