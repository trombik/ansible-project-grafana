# frozen_string_literal: true

require_relative "../spec_helper"

passwd_file = case os[:family]
              when "freebsd"
                "/usr/local/etc/mosquitto/passwd"
              else
                "/etc/mosquitto/passwd"
              end
mosquitto_group = case os[:family]
                  when "freebsd"
                    "nobody"
                  when "ubuntu", "redhat"
                    "mosquitto"
                  when "openbsd"
                    "_mosquitto"
                  end
accounts = credentials_yaml["project_mosquitto_accounts"]

describe file passwd_file do
  it { should exist }
  it { should be_file }
  it { should be_mode 640 }
  it { should be_owned_by "root" }
  it { should be_grouped_into mosquitto_group }
  accounts.each do |account|
    its(:content) { should match(/^#{account["name"]}:\$\d+\$.*/) }
  end
end
