# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

files = %w[3.3 3.4 4.0].map { |version| "tmp/coverage-inputs/simplecov-#{version}/resultset.json" }
missing = files.reject { |file| File.file?(file) }
abort "Missing coverage inputs: #{missing.join(', ')}" unless missing.empty?

SimpleCov.collate(files, ignore_timeout: true) do
  formatter SimpleCov::Formatter::JSONFormatter
end
