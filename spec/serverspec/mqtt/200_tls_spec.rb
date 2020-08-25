# frozen_string_literal: true

require_relative "../spec_helper"

topic = "$SYS/broker/clients/connected"
ports = [1883, 8883]
ca_cert_file = "/etc/mosquitto/certs/ca.pem"
flags = "--insecure"

ports.each do |p|
  describe port p do
    it { should be_listening }
  end
end

describe file ca_cert_file do
  it { should exist }
  it { should be_file }
end

describe "mosquitto_sub" do
  it "returns #{topic}", retry: 3, retry_wait: 10 do
    command = command("mosquitto_sub -C 1 -t #{Shellwords.escape(topic)} --cafile #{Shellwords.escape(ca_cert_file)} #{Shellwords.escape(flags) unless flags.empty?}")

    expect(command.exit_status).to eq 0
    expect(command.stderr).to eq ""
    expect(command.stdout).to match(/^\d+$/)
  end
end
