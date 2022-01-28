# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CustomNamespace::CustomRecordName do
  subject { described_class.metadata }
  let(:exp_schema_id) { 12 }

  let(:exp_hash) do
    {
      name: 'CustomNamespace::CustomRecordName',
      schema_name: 'custom_namespace.custom_record_name',
      version: '8e0963f3',
      attributes: {
        first_name: { type: :string, required: true },
        last_name: { type: :string, required: true }
      }
    }
  end
  let(:exp_template) do
    <<~CODE.chomp
      namespace 'custom'

      record :record, :doc=>"| version 8e0963f3" do
        required :first_name, :string, doc: "| type string"
        required :last_name, :string, doc: "| type string"
      end
    CODE
  end
  let(:exp_schema) do
    {
      type: 'record',
      name: 'record',
      namespace: 'custom',
      doc: '| version 8e0963f3',
      fields: [
        { name: 'first_name', type: 'string', doc: '| type string' },
        { name: 'last_name', type: 'string', doc: '| type string' }
      ]
    }
  end
  let(:exp_json) do
    <<~JSON.chomp
      {
        "type": "record",
        "name": "record",
        "namespace": "custom",
        "doc": "| version 8e0963f3",
        "fields": [
          {
            "name": "first_name",
            "type": "string",
            "doc": "| type string"
          },
          {
            "name": "last_name",
            "type": "string",
            "doc": "| type string"
          }
        ]
      }
    JSON
  end
  let(:exp_version_meta) do
    [
      {
        name: 'Schemas::Custom::Record::V8e0963f3',
        schema_name: 'schemas.custom.record.v8e0963f3',
        version: '8e0963f3',
        attributes: {
          first_name: { type: :string, required: true },
          last_name: { type: :string, required: true }
        }
      }
    ]
  end

  let(:act_hash) { subject.to_hash }
  let(:act_template) { subject.as_avro_template }
  let(:act_avro) { subject.as_avro_schema }
  let(:blt_meta) { FieldStruct::Metadata.from_avro_schema act_avro }
  let(:blt_klas) { FieldStruct.from_metadata blt_meta.last }

  it('matches') { compare act_hash, exp_hash }

  context 'to Avro' do
    it('#as_avro_template') { compare act_template, exp_template }
    it('#as_avro_schema') { compare act_avro, exp_schema }
    it('#to_avro_json') { compare subject.to_avro_json, exp_schema.to_json }
  end

  context 'from Avro' do
    it 'builds a valid metadata' do
      expect { blt_meta }.to_not raise_error
      expect(blt_meta).to be_a Array
      expect(blt_meta.size).to eq 1
      expect(blt_meta.first).to be_a FieldStruct::Metadata
      compare blt_meta.map(&:to_hash), exp_version_meta
    end
  end

  context 'to and from Avro' do
    let(:original) { described_class.new person_attrs }
    let(:clone) { blt_klas.new person_attrs }
    it 'works' do
      expect { original }.to_not raise_error

      expect(original).to be_valid
      expect(original.first_name).to eq 'John'
      expect(original.last_name).to eq 'Max'

      expect { blt_klas }.to_not raise_error

      expect { clone }.to_not raise_error

      expect(clone).to be_valid
      expect(clone.first_name).to eq 'John'
      expect(clone.last_name).to eq 'Max'
    end
  end

  context 'to Avro hash' do
    let(:instance) { described_class.new person_attrs }
    let(:act_hash) { instance.to_avro_hash }
    let(:cloned_attrs) { described_class.convert_avro_attributes act_hash }
    let(:cloned) { described_class.from_avro_hash act_hash }
    let(:cloned_hsh) { cloned.to_hash.deep_symbolize_keys }
    let(:exp_avro_hsh) { exp_hsh }
    let(:exp_hsh) do
      {
        first_name: 'John',
        last_name: 'Max'
      }
    end
    it('#to_avro_hash') { compare instance.to_avro_hash, exp_avro_hsh }
    it('.convert_avro_attributes') do
      expect { cloned_attrs }.to_not raise_error
      expect(cloned_attrs).to be_a Hash
      compare cloned_attrs, exp_hsh
    end
    it('.from_avro_hash') do
      expect { cloned }.to_not raise_error
      expect(cloned).to be_a described_class
      expect(cloned).to be_valid
      compare cloned_hsh, exp_hsh
    end
  end

  context 'event' do
    let(:source) { OpenStruct.new attributes: person_attrs }
    let(:instance) { described_class.from source }
    let(:topic_name) { 'custom_namespace.custom_record_name' }
    let(:topic_key) { :last_name }
    let(:new_schema_id) { 99 }
    let(:new_topic_name) { 'some.topic' }
    let(:new_topic_key) { :other }

    context 'class' do
      it('.schema_id') do
        old_schema_id = described_class.schema_id
        described_class.schema_id new_schema_id
        expect(described_class.schema_id).to eq new_schema_id
        described_class.schema_id nil
        expect(described_class.schema_id).to be_nil
        described_class.schema_id old_schema_id
      end
      it('.topic_name') do
        expect(described_class.topic_name).to eq topic_name
        described_class.topic_name new_topic_name
        expect(described_class.topic_name).to eq new_topic_name
        described_class.topic_name nil
        expect(described_class.topic_name).to eq topic_name
      end
      it('.topic_key') do
        expect(described_class.topic_key).to eq topic_key
        described_class.topic_key new_topic_key
        expect(described_class.topic_key).to eq new_topic_key
        described_class.topic_key topic_key
        expect(described_class.topic_key).to eq topic_key
      end
      it('.avro_template') { compare described_class.avro_template, exp_template }
      it('.schema') { compare described_class.schema, exp_json }
    end
    context 'instance' do
      it('event') { expect(instance).to be_a described_class }
      it('#topic_name') { expect(instance.topic_name).to eq topic_name }
      it('#topic_key') { compare instance.topic_key, 'Max' }
      it('#schema_id') { expect(instance.schema_id).to be_nil }
      it('to_hash') { compare instance.to_hash, person_attrs.deep_stringify_keys }
    end
  end
  context 'registration' do
    let(:registration) { kafka.register_event_schema described_class }
    it('Kafka has event registered') { expect(kafka.events[described_class.name]).to eq described_class }
    it 'registers with schema_registry', :vcr, :registers do
      expect { registration }.to_not raise_error
      expect(described_class.schema_id).to eq exp_schema_id
    end
  end
  context 'encoding and decoding', :vcr do
    let(:instance) { described_class.new person_attrs }
    let(:decoded) { kafka.decode encoded, described_class.topic_name }
    context 'avro' do
      let(:encoded) { kafka.encode_avro instance, schema_id: exp_schema_id }
      let(:exp_encoded) do
        "\u0000\u0000\u0000\u0000\f\bJohn\u0006Max"
      end
      let(:exp_decoded) { instance.to_hash.deep_symbolize_keys }
      it('encodes properly') { compare encoded, exp_encoded }
      it('decodes properly') { compare decoded, exp_decoded }
    end
    context 'json' do
      let(:encoded) { kafka.encode_json instance }
      let(:exp_encoded) do
        '{"first_name":"John","last_name":"Max"}'
      end
      let(:exp_decoded) { JSON.parse instance.to_hash.to_json }
      it('encodes properly') { compare encoded, exp_encoded }
      it('decodes properly') { compare decoded, exp_decoded }
    end
  end
end
