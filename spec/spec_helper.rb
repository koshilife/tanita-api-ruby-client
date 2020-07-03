# frozen_string_literal: true

require 'simplecov'
SimpleCov.start
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'bundler/setup'
require 'tanita/api/client'
require 'webmock/rspec'

SPEC_DIR = __dir__
FIXTURES_DIR = File.expand_path(File.join(SPEC_DIR, 'fixtures'))

def read_fixture(sub_dirname, file_name)
  file_path = File.expand_path(File.join(FIXTURES_DIR, sub_dirname, file_name))
  File.open(file_path)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
