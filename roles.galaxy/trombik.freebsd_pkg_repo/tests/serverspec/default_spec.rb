require "spec_helper"
require "serverspec"

describe file("/usr/local/etc/pkg/repos/FreeBSD.conf") do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
  its(:content) { should match(/^FreeBSD: {\n\s+enabled: false,\n}/) }
end

describe file "/usr/local/etc/pkg/repos/FreeBSD_latest.conf" do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
end

describe command "pkg -vv" do
  its(:stdout) { should match(/FreeBSD_latest:/) }
  its(:stdout) { should match(%r{url\s+:\s+"pkg\+https://pkg.FreeBSD.org/FreeBSD:\d+:amd64/latest"}) }
  its(:stdout) { should match(/enabled\s+:\s+yes/) }
  its(:stdout) { should match(/priority\s+:\s+100/) }
  its(:stdout) { should match(/mirror_type\s+:\s+"SRV"/) }
  its(:stdout) { should match(/signature_type\s+:\s+"FINGERPRINTS"/) }
  its(:stdout) { should match(%r{fingerprints\s+:\s+"/usr/share/keys/pkg"}) }

  its(:stdout) { should_not match(/^\s+FreeBSD:\s+\{$/) }
  its(:stderr) { should eq "" }
  its(:exit_status) { should eq 0 }
end
