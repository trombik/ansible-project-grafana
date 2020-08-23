# frozen_string_literal: true

require_relative "../spec_helper"
require "capybara/rspec"
require "selenium-webdriver"

admin_user = credentials_yaml["grafana_admin_user"]
admin_pass = credentials_yaml["grafana_admin_password"]

Capybara.configure do |config|
  config.run_server = false
  case test_environment
  when "virtualbox"
    config.app_host = "http://172.16.100.200"
  when "prod"
    config.app_host = "http://grafana.i.trombik.org"
  end
end

# see https://docs.travis-ci.com/user/chrome#capybara
Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox headless disable-gpu])
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    acceptInsecureCerts: true
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, desired_capabilities: capabilities)
end

Capybara.default_driver = :chrome
Capybara.javascript_driver = :chrome

feature "Login to sensu-backend" do
  scenario "with vaild credential of admin user", js: true do
    sign_up_with admin_user, admin_pass

    expect(page).to have_content("Welcome to Grafana")
  end

  scenario "with invalid credential", js: true do
    sign_up_with "foo", "bar"

    expect(page).to have_content("Forgot your password?")
  end

  def sign_up_with(account, password)
    visit "login"
    puts current_url
    require "pry"
    # XXX when debugging, uncomment below
    # binding.pry
    fill_in "user", with: account
    fill_in "password", with: password
    click_button "Log In"
  end
end
