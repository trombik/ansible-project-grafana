# frozen_string_literal: true

require "shellwords"

# prod environment
class TestEnvironment
  def initialize; end

  def up; end

  def clean; end

  def prepare; end

  def provision
    Rake.sh "ansible-playbook -i #{Shellwords.escape(inventory_path)} " \
      "--ask-become-pass " \
      "--user #{Shellwords.escape(user)} playbooks/site.yml"
  end

  def user
    ENV["PROJECT_USER"] || ENV["USER"]
  end
end
