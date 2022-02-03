# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FieldStruct::AvroSchema::Kafka do
  let(:known_events) do
    {
      'CustomNamespace::CustomRecordName' => CustomNamespace::CustomRecordName,
      'ExampleApp::Examples::Friend' => ExampleApp::Examples::Friend,
      'Examples::Base' => Examples::Base,
      'Examples::Company' => Examples::Company,
      'Examples::Developer' => Examples::Developer,
      'Examples::Employee' => Examples::Employee,
      'Examples::Person' => Examples::Person,
      'Examples::Team' => Examples::Team,
      'Examples::User' => Examples::User,
      'PublishableApp::Examples::Address' => PublishableApp::Examples::Address,
      'PublishableApp::Examples::Runner' => PublishableApp::Examples::Runner
    }
  end
  let(:publishable_events) { known_events.select { |_k, v| v.publishable? } }
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
      expect(subject.keys.sort).to eq known_events.keys
      known_events.each do |name, event|
        expect(subject[name]).to eq event
      end
    end
  end
  describe '.schema_registry' do
    subject { described_class.schema_registry }
    it { expect(subject).to be_a FieldStruct::AvroSchema::Kafka::CachedSchemaRegistry }
    it do
      expect(subject.inspect).to eq '#<FieldStruct::AvroSchema::Kafka::CachedSchemaRegistry ' \
                                    'upstream=#<FieldStruct::AvroSchema::Kafka::SchemaRegistry ' \
                                    'url=nil> cache=#<FieldStruct::AvroSchema::Kafka::InMemoryCache ' \
                                    'schemas_by_id=0 ids_by_schema=0 schema_by_subject_version=0>>'
    end
  end
  describe '.base_schema_registry' do
    subject { described_class.base_schema_registry }
    it { expect(subject).to be_a FieldStruct::AvroSchema::Kafka::SchemaRegistry }
    it { expect(subject.inspect).to eq '#<FieldStruct::AvroSchema::Kafka::SchemaRegistry url=nil>' }
  end
  describe '.registry_url' do
    subject { described_class.registry_url }
    it { expect(subject).to eq 'http://localhost:8081' }
    it { expect(subject.inspect).to eq '"http://localhost:8081"' }
  end
  describe '.schema_registry_cache' do
    subject { described_class.schema_registry_cache }
    it { expect(subject).to be_a FieldStruct::AvroSchema::Kafka::InMemoryCache }
    it do
      expect(subject.inspect).to eq '#<FieldStruct::AvroSchema::Kafka::InMemoryCache ' \
                                    'schemas_by_id=0 ids_by_schema=0 schema_by_subject_version=0>'
    end
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
  describe '.register_event_schemas', :vcr, :registers do
    subject { described_class.register_event_schemas }
    it 'register all events' do
      expect(described_class).to receive(:register_event_schema).exactly(publishable_events.size).times
      expect { subject }.to_not raise_error
    end
  end
end
