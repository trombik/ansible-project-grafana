# frozen_string_literal: true

require_relative "../spec_helper"

ports = [80]

services = %w[
  nginx
]

services.each do |s|
  describe service s do
    it { should be_enabled }
    it { should be_running }
  end
end

ports.each do |p|
  describe port p do
    it { should be_listening }
  end
end
