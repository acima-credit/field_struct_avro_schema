# frozen_string_literal: true

require 'bundler/setup'
require 'field_struct/avro_schema'
require 'avro_acima/encryption/dummy_encryption_provider'
require 'fileutils'

FieldStruct::AvroSchema.logger.level = ENV.fetch('LOG_LEVEL', Logger::INFO).to_i

require 'rspec/core/shared_context'
require 'rspec/json_expectations'
require 'hashdiff'
require 'vcr'

TIME_ZONE = 'Mountain Time (US & Canada)'
Time.zone = TIME_ZONE
ActiveSupport.parse_json_times = true

require 'json'
require 'active_support/json'
require 'active_support/time'

FieldStruct::AvroSchema.logger = Logger.new($stdout) if ENV['DEBUG'] == 'true'

ROOT_PATH = Pathname.new File.expand_path(File.dirname(File.dirname(__FILE__)))
STORE_PATH = ROOT_PATH.join('spec/schemas')

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.filter_run focus: true if ENV['FOCUS'].to_s == 'true'
  config.filter_run focus2: true if ENV['FOCUS2'].to_s == 'true'
  config.filter_run registers: true if ENV['REGISTERS'].to_s == 'true'
  config.filter_run serde: true if ENV['SERDE'].to_s == 'true'
  config.filter_run vcr: true if ENV['VCR'].to_s == 'true'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  require_relative 'support/compare'
  require_relative 'support/kafka'
  require_relative 'support/models'
  require_relative 'support/model_helpers'
  require_relative 'support/values'
  require_relative 'support/karafka'

  # Builder Store setup
  FileUtils.mkdir_p STORE_PATH
  FieldStruct::AvroSchema::Kafka.builder_store_path = STORE_PATH

  config.before(:each) do
    FieldStruct::AvroSchema::Kafka.builder_store.clear
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :excon
  c.configure_rspec_metadata!
  # c.allow_http_connections_when_no_cassette = true
end

AvroAcima.configure do |c|
  c.encryption_provider = AvroAcima::Encryption::DummyEncryptionProvider.new
end
