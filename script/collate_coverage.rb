# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

# The test matrix requires each leg to upload its artifact before this job runs.
files = Dir.glob('tmp/coverage-inputs/simplecov-*/resultset.json').sort
abort 'No SimpleCov coverage inputs found' if files.empty?

SimpleCov.collate(files, ignore_timeout: true) do
  formatter SimpleCov::Formatter::JSONFormatter
end
