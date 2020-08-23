# frozen_string_literal: true

require_relative "../spec_helper"
require "net/http"

services = %w[
  influxdb
]

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
host = group_var("grafana.yml", "influxdb_bind_address").split(":").first
port = group_var("grafana.yml", "influxdb_bind_address").split(":").last

describe command "influx -host #{Shellwords.escape(host)} -port " \
  "#{Shellwords.escape(port)} -username #{Shellwords.escape(user)} -password" \
  "#{Shellwords.escape(password)} -database sensors -execute 'show measurements'" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
end
