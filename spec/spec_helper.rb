# frozen_string_literal: true

require 'bundler/setup'
require 'field_struct/avro_schema'

require 'rspec/core/shared_context'
require 'rspec/json_expectations'
require 'hashdiff'

ROOT_PATH = Pathname.new File.expand_path(File.dirname(File.dirname(__FILE__)))
STORE_PATH = ROOT_PATH.join('spec/schemas')

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.filter_run focus: true if ENV['FOCUS'].to_s == 'true'
  config.filter_run focus2: true if ENV['FOCUS2'].to_s == 'true'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  require_relative 'support/compare'
  require_relative 'support/models'
  require_relative 'support/model_helpers'
  require_relative 'support/values'

  # Builder Store setup
  FileUtils.mkdir_p STORE_PATH
  FieldStruct::AvroSchema::AvroBuilder.builder_store_path = STORE_PATH

  config.before(:each) do
    FieldStruct::AvroSchema::AvroBuilder.builder_store.clear
  end
end
