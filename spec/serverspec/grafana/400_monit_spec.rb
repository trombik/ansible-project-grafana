# frozen_string_literal: true

require_relative "../spec_helper"

services = %w[nginx sshd grafana influxdb]

describe command "monit status", retry: 5 do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  services.each do |s|
    its(:stdout) { should match(/#{s}/) }
  end
end

services.each do |s|
  describe command "monit -B status #{Shellwords.escape(s)}", retry: 5 do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    its(:stdout) { should match(/status\s+OK/) }
    its(:stdout) { should match(/monitoring mode\s+active/) }
  end
end
