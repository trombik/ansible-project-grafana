require "spec_helper"
require "serverspec"

default_group = case os[:family]
                when /bsd/
                  "wheel"
                else
                  "users"
                end
default_groups = case os[:family]
                 when "freebsd"
                   %w[dialer video]
                 when "openbsd"
                   %w[dialer games]
                 else
                   %w[dialout video]
                 end
users = [
  {
    name: "trombik",
    group: default_group,
    groups: default_groups
  }
]

users.each do |u|
  describe user u[:name] do
    it { should exist }
    it { should belong_to_primary_group u[:group] }
    it { should belong_to_group u[:groups] }
    it { should have_login_shell "/bin/sh" }
  end

  describe file "/home/#{u[:name]}/.ssh/authorized_keys" do
    it { should be_file }
    its(:content) { should match(/^ssh-rsa/) }
  end

  describe file "/home/#{u[:name]}/.ssh/rc" do
    it { should exist }
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by u[:name] }
    it { should be_grouped_into u[:group] }
    its(:content) { should match(/Managed by ansible/) }
    its(:content) { should match(/see sshd\(8\)/) }
  end
end

describe user "foo" do
  it { should_not exist }
end

describe file "/home/foo" do
  it { should_not exist }
end

# user_without_ssh_key
describe user "user_without_ssh_key" do
  it { should exist }
  it { should belong_to_primary_group default_group }
end

describe file "/home/user_without_ssh_key" do
  it { should exist }
  it { should be_directory }
end

describe file "/home/user_without_ssh_key/.ssh" do
  it { should exist }
  it { should be_directory }
  it { should be_mode 700 }
  it { should be_owned_by "user_without_ssh_key" }
  it { should be_grouped_into default_group }
end

describe file "/home/user_without_ssh_key/.ssh/rc" do
  it { should_not exist }
end

# user_without_home
describe user "user_without_home" do
  it { should exist }
  it { should belong_to_primary_group default_group }
end

describe file "/home/user_without_home" do
  it { should_not exist }
end

describe file "/home/user_without_home/.ssh" do
  it { should_not exist }
end

describe file "/home/user_without_home/.ssh/rc" do
  it { should_not exist }
end
