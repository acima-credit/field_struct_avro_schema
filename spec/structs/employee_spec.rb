# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Employee do
  subject { described_class.metadata }
  let(:exp_schema_id) { 7 }

  let(:exp_meta) do
    {
      name: 'Examples::Employee',
      schema_name: 'examples.employee',
      version: '115d6e02',
      attributes: {
        first_name: { type: :string, required: true, min_length: 3, max_length: 20 },
        last_name: { type: :string, required: true },
        title: { type: :string, default: '<proc>' }
      }
    }
  end
  let(:exp_template) do
    <<~CODE.chomp
      namespace 'examples'

      record :employee, :doc=>"| version 115d6e02" do
        required :first_name, :string, doc: "| type string"
        required :last_name, :string, doc: "| type string"
        optional :title, :string, doc: "| type string"
      end
    CODE
  end
  let(:exp_schema) do
    {
      type: 'record',
      name: 'employee',
      namespace: 'examples',
      doc: '| version 115d6e02',
      fields: [
        { name: 'first_name', type: 'string', doc: '| type string' },
        { name: 'last_name', type: 'string', doc: '| type string' },
        { name: 'title', type: %w[null string], default: nil, doc: '| type string' }
      ]
    }
  end
  let(:exp_json) do
    <<~JSON.chomp
      {
        "type": "record",
        "name": "employee",
        "namespace": "examples",
        "doc": "| version 115d6e02",
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
          },
          {
            "name": "title",
            "type": [
              "null",
              "string"
            ],
            "default": null,
            "doc": "| type string"
          }
        ]
      }
    JSON
  end
  let(:exp_version_meta) do
    [
      {
        name: 'Schemas::Examples::Employee::V115d6e02',
        schema_name: 'schemas.examples.employee.v115d6e02',
        version: '115d6e02',
        attributes: {
          first_name: { type: :string, required: true },
          last_name: { type: :string, required: true },
          title: { type: :string }
        }
      }
    ]
  end

  let(:act_meta) { subject.to_hash }
  let(:act_template) { subject.as_avro_template }
  let(:act_avro) { subject.as_avro_schema }
  let(:blt_meta) { FieldStruct::Metadata.from_avro_schema act_avro }
  let(:blt_klas) { FieldStruct.from_metadata blt_meta.last }

  it('matches') { compare act_meta, exp_meta }

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
    let(:original) { described_class.new employee_attrs }
    let(:clone) { blt_klas.new employee_attrs }
    it 'works' do
      expect { original }.to_not raise_error

      expect(original).to be_valid
      expect(original.first_name).to eq 'John'
      expect(original.last_name).to eq 'Max'
      expect(original.title).to eq 'VP of Engineering'

      expect { blt_klas }.to_not raise_error

      expect { clone }.to_not raise_error

      expect(clone).to be_valid
      expect(clone.first_name).to eq 'John'
      expect(clone.last_name).to eq 'Max'
      expect(clone.title).to eq 'VP of Engineering'
    end
  end

  context 'to Avro hash' do
    let(:instance) { described_class.new employee_attrs }
    let(:act_hash) { instance.to_avro_hash }
    let(:cloned_attrs) { described_class.convert_avro_attributes act_hash }
    let(:cloned) { described_class.from_avro_hash act_hash }
    let(:cloned_hsh) { cloned.to_hash.deep_symbolize_keys }
    let(:exp_avro_hsh) { exp_hsh }
    let(:exp_hsh) do
      {
        first_name: 'John',
        last_name: 'Max',
        title: 'VP of Engineering'
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
    let(:source) { OpenStruct.new attributes: employee_attrs }
    let(:instance) { described_class.from source }
    let(:topic_name) { 'examples.employee' }
    let(:topic_key) { :full_name }
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
      it('#topic_key') { compare instance.topic_key, 'John Max' }
      it('#schema_id') { expect(instance.schema_id).to be_nil }
      it('to_hash') { compare instance.to_hash, employee_attrs.deep_stringify_keys }
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
    let(:instance) { described_class.new employee_attrs }
    let(:decoded) { kafka.decode encoded, described_class.topic_name }
    context 'avro' do
      let(:encoded) { kafka.encode_avro instance, schema_id: exp_schema_id }
      let(:exp_encoded) do
        "\0\0\0\0\a\bJohn\x06Max\x02\"VP of Engineering"
      end
      let(:exp_decoded) { instance.to_hash.deep_symbolize_keys }
      it('encodes properly') { compare encoded, exp_encoded }
      it('decodes properly') { compare decoded, exp_decoded }
    end
    context 'json' do
      let(:encoded) { kafka.encode_json instance }
      let(:exp_encoded) do
        '{"first_name":"John","last_name":"Max","title":"VP of Engineering"}'
      end
      let(:exp_decoded) { JSON.parse instance.to_hash.to_json }
      it('encodes properly') { compare encoded, exp_encoded }
      it('decodes properly') { compare decoded, exp_decoded }
    end
  end
end
