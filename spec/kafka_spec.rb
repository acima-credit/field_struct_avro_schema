# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FieldStruct::AvroSchema::Kafka do
  describe '.logger' do
    subject { described_class.logger }
    it('is a logger') { expect(subject).to be_a Logger }
    it 'can be changed' do
      old_logger = described_class.logger
      new_logger = Logger.new $stdout
      described_class.logger = new_logger
      expect(described_class.logger).to eq new_logger
      described_class.logger = old_logger
    end
  end
  describe '.events' do
    subject { described_class.events }
    it('is a hash') do
      expect(subject).to be_a Hash
      expect(subject.keys.sort).to eq %w[
        ExampleApp::Examples::Friend
        Examples::Base
        Examples::Company
        Examples::Developer
        Examples::Employee
        Examples::Person
        Examples::Team
        Examples::User
      ]
      expect(subject['Examples::Base']).to eq Examples::Base
      expect(subject['Examples::User']).to eq Examples::User
      expect(subject['Examples::Person']).to eq Examples::Person
      expect(subject['Examples::Employee']).to eq Examples::Employee
      expect(subject['Examples::Developer']).to eq Examples::Developer
      expect(subject['Examples::Team']).to eq Examples::Team
      expect(subject['Examples::Company']).to eq Examples::Company
      expect(subject['ExampleApp::Examples::Friend']).to eq ExampleApp::Examples::Friend
    end
  end
  describe '.schema_registry' do
    subject { described_class.schema_registry }
    it { expect(subject).to be_a FieldStruct::AvroSchema::Kafka::CachedSchemaRegistry }
  end
  describe '.base_schema_registry' do
    subject { described_class.base_schema_registry }
    it { expect(subject).to be_a FieldStruct::AvroSchema::Kafka::SchemaRegistry }
  end
  describe '.registry_url' do
    subject { described_class.registry_url }
    it { expect(subject).to eq 'http://localhost:8081' }
  end
  describe '.schema_registry_cache' do
    subject { described_class.schema_registry_cache }
    it { expect(subject).to be_a FieldStruct::AvroSchema::Kafka::InMemoryCache }
  end
  describe '.builder_store_path' do
    subject { described_class.builder_store_path }
    it('is set') { expect(subject).to eq STORE_PATH }
    it 'can be changed' do
      old_path = described_class.builder_store_path
      new_path = ROOT_PATH.join('spec/schemas')
      described_class.builder_store_path = new_path
      expect(described_class.builder_store_path).to eq new_path
      described_class.builder_store_path = old_path
    end
  end
  describe '.builder_store' do
    subject { described_class.builder_store }
    it { expect(subject).to be_a FieldStruct::AvroSchema::Kafka::SchemaStore }
  end
  describe '.register_event_schemas', :vcr do
    subject { described_class.register_event_schemas }
    it 'register all events' do
      expect(described_class).to receive(:register_event_schema).exactly(8).times
      expect { subject }.to_not raise_error
    end
  end
end
