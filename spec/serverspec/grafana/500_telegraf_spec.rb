# frozen_string_literal: true

require_relative "../spec_helper"

describe service "telegraf" do
  it { should be_enabled }
  it { should be_running }
end
