# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::User do
  subject { described_class.metadata }
  let(:exp_schema_id) { 5 }

  let(:exp_hash) do
    {
      name: 'Examples::User',
      schema_name: 'examples.user',
      version: '53d47729',
      attributes: {
        username: { type: :string, required: true, format: /\A[a-z]/i, description: 'login' },
        password: { type: :string },
        age: { type: :integer, required: true },
        owed: { type: :currency, required: true, description: 'amount owed to the company' },
        source: { type: :string, required: true, enum: %w[A B C] },
        level: { type: :integer, required: true, default: '<proc>' },
        at: { type: :time },
        active: { type: :boolean, required: true, default: false }
      }
    }
  end
  let(:exp_template) do
    <<~CODE.chomp
      namespace 'examples'

      record :user, :doc=>"| version 53d47729" do
        required :username, :string, doc: "login | type string"
        optional :password, :string, doc: "| type string"
        required :age, :int, doc: "| type integer"
        required :owed, :int, doc: "amount owed to the company | type currency"
        required :source, :string, doc: "| type string"
        required :level, :int, doc: "| type integer"
        optional :at, :long, logical_type: "timestamp-millis", doc: "| type time"
        required :active, :boolean, default: false, doc: "| type boolean"
      end
    CODE
  end
  let(:exp_schema) do
    {
      type: 'record',
      name: 'user',
      namespace: 'examples',
      doc: '| version 53d47729',
      fields: [
        { name: 'username', type: 'string', doc: 'login | type string' },
        { name: 'password', type: %w[null string], default: nil, doc: '| type string' },
        { name: 'age', type: 'int', doc: '| type integer' },
        { name: 'owed', type: 'int', doc: 'amount owed to the company | type currency' },
        { name: 'source', type: 'string', doc: '| type string' },
        { name: 'level', type: 'int', doc: '| type integer' },
        {
          name: 'at',
          type: ['null', { type: 'long', logicalType: 'timestamp-millis' }],
          default: nil,
          doc: '| type time'
        },
        { name: 'active', type: 'boolean', default: false, doc: '| type boolean' }
      ]
    }
  end
  let(:exp_json) do
    <<~JSON.chomp
      {
        "type": "record",
        "name": "user",
        "namespace": "examples",
        "doc": "| version 53d47729",
        "fields": [
          {
            "name": "username",
            "type": "string",
            "doc": "login | type string"
          },
          {
            "name": "password",
            "type": [
              "null",
              "string"
            ],
            "default": null,
            "doc": "| type string"
          },
          {
            "name": "age",
            "type": "int",
            "doc": "| type integer"
          },
          {
            "name": "owed",
            "type": "int",
            "doc": "amount owed to the company | type currency"
          },
          {
            "name": "source",
            "type": "string",
            "doc": "| type string"
          },
          {
            "name": "level",
            "type": "int",
            "doc": "| type integer"
          },
          {
            "name": "at",
            "type": [
              "null",
              {
                "type": "long",
                "logicalType": "timestamp-millis"
              }
            ],
            "default": null,
            "doc": "| type time"
          },
          {
            "name": "active",
            "type": "boolean",
            "default": false,
            "doc": "| type boolean"
          }
        ]
      }
    JSON
  end
  let(:exp_version_meta) do
    [
      {
        name: 'Schemas::Examples::User::V53d47729',
        schema_name: 'schemas.examples.user.v53d47729',
        version: '53d47729',
        attributes: {
          username: { type: :string, required: true, description: 'login' },
          password: { type: :string },
          age: { type: :integer, required: true },
          owed: { type: :currency, required: true, description: 'amount owed to the company' },
          source: { type: :string, required: true },
          level: { type: :integer, required: true },
          at: { type: :time },
          active: { type: :boolean, required: true, default: false }
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
    it 'builds a valid metadata array' do
      expect { blt_meta }.to_not raise_error
      expect(blt_meta).to be_a Array
      expect(blt_meta.size).to eq 1
      expect(blt_meta.first).to be_a FieldStruct::Metadata
      compare blt_meta.map(&:to_hash), exp_version_meta
    end
  end

  context 'to and from Avro' do
    let(:original) { described_class.new user_attrs }
    let(:clone) { blt_klas.new user_attrs }
    it 'works' do
      expect { original }.to_not raise_error

      expect(original).to be_valid
      expect(original.username).to eq 'some_user'
      expect(original.password).to eq 'some_password'
      expect(original.age).to eq 45
      expect(original.owed).to eq 1537.25
      expect(original.source).to eq 'B'
      expect(original.level).to eq 2
      expect(original.at).to eq past_time
      expect(original.active).to eq true

      expect { blt_klas }.to_not raise_error

      expect { clone }.to_not raise_error

      expect(clone).to be_valid
      expect(clone.username).to eq 'some_user'
      expect(clone.password).to eq 'some_password'
      expect(clone.age).to eq 45
      expect(clone.owed).to eq 1537.25
      expect(clone.source).to eq 'B'
      expect(clone.level).to eq 2
      expect(clone.at).to eq past_time
      expect(clone.active).to eq true
    end
  end

  context 'to Avro hash' do
    let(:instance) { described_class.new user_attrs }
    let(:act_hash) { instance.to_avro_hash }
    let(:cloned_attrs) { described_class.convert_avro_attributes act_hash }
    let(:cloned) { described_class.from_avro_hash act_hash }
    let(:cloned_hsh) { cloned.to_hash.deep_symbolize_keys }
    let(:exp_avro_hsh) do
      {
        username: 'some_user',
        password: 'some_password',
        age: 45,
        owed: 153_725,
        source: 'B',
        level: 2,
        at: 1_551_701_167_891,
        active: true
      }
    end
    let(:exp_hsh) do
      {
        username: 'some_user',
        password: 'some_password',
        age: 45,
        owed: 1537.25,
        source: 'B',
        level: 2,
        at: past_time.utc,
        active: true
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
    let(:source) { OpenStruct.new attributes: user_attrs }
    let(:instance) { described_class.from source }
    let(:topic_name) { 'examples.user' }
    let(:topic_key) { :username }
    let(:new_schema_id) { 99 }
    let(:new_topic_name) { 'some.topic' }
    let(:new_topic_key) { :other }
    let(:exp_avro_encoded) do
      "\u0000\u0000\u0000\u0000\u0005\u0012some_user\u0002\u001Asome_passwordZ\xFA\xE1\u0012\u0002B\u0004\u0002\xA6" \
        "\xBCƉ\xA9Z\u0001"
    end
    let(:exp_json_encoded) do
      '{"username":"some_user","password":"some_password","age":45,"owed":1537.25,"source":"B","level":2,"at":' \
            '"2019-03-04T05:06:07.891-07:00","active":true}'
    end

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
      it('#topic_key') { compare instance.topic_key, 'some_user' }
      it('#schema_id') { expect(instance.schema_id).to be_nil }
      it('attributes') { compare instance.attributes, user_attrs.stringify_keys }
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
      let(:instance) { described_class.new user_attrs }
      let(:decoded) { kafka.decode encoded, described_class.topic_name }
      context 'avro' do
        let(:encoded) { kafka.encode_avro instance, schema_id: exp_schema_id }
        let(:exp_decoded) { instance.to_hash.deep_symbolize_keys }
        it('encodes properly') { compare encoded, exp_avro_encoded }
        it('decodes properly') { compare decoded, exp_decoded }
      end
      context 'avro_event' do
        before { described_class.schema_id exp_schema_id }
        let(:encoded) { instance.topic_encoded(:avro_messaging) }
        let(:exp_decoded) { instance.to_hash.deep_symbolize_keys }
        it('encodes properly') { compare encoded, exp_avro_encoded }
        it('decodes properly') { compare decoded, exp_decoded }
      end
      context 'json' do
        let(:encoded) { kafka.encode_json instance }
        let(:exp_decoded) { JSON.parse instance.to_hash.to_json }
        it('encodes properly') { compare encoded, exp_json_encoded }
        it('decodes properly') { compare decoded, exp_decoded }
      end
      context 'json_event' do
        let(:encoded) { instance.topic_encoded(:json) }
        let(:exp_encoded) do
          '{"username":"some_user","password":"some_password","age":45,"owed":1537.25,"source":"B","level":2,"at":' \
            '"2019-03-04T05:06:07.891-07:00","active":true}'
        end
        let(:exp_decoded) { JSON.parse instance.to_hash.to_json }
        it('encodes properly') { compare encoded, exp_encoded }
        it('decodes properly') { compare decoded, exp_decoded }
      end
    end
    context 'karafka', :vcr do
      before { described_class.schema_id exp_schema_id }
      let(:result) { coder.new.call instance }
      context 'serialization' do
        let(:coder) { FieldStruct::AvroSchema::Karafka.serializer }
        context 'avro field struct' do
          let(:instance) { described_class.new user_attrs }
          it('encodes') { compare result, exp_avro_encoded }
        end
        context 'string' do
          let(:instance) { exp_avro_encoded }
          it('keeps same') { compare result, exp_avro_encoded }
        end
        context 'other' do
          let(:instance) { ExampleApp::Examples::Stranger.new name: 'unknown', age: 25 }
          it('raises error') { expect { result }.to raise_error ::Karafka::Errors::SerializationError, instance }
        end
      end
      context 'deserialization' do
        let(:coder) { FieldStruct::AvroSchema::Karafka.deserializer }
        let(:instance) { OpenStruct.new raw_payload: raw_payload, topic: topic_name }
        context 'avro field struct' do
          let(:raw_payload) { exp_avro_encoded }
          let(:exp_hsh) do
            {
              username: 'some_user',
              password: 'some_password',
              age: 45,
              owed: 1537.25,
              source: 'B',
              level: 2,
              at: past_time.utc,
              active: true
            }
          end
          it('decodes') { compare result, exp_hsh }
        end
        context 'null payload' do
          let(:raw_payload) { nil }
          it('returns nil') { compare result, nil }
        end
        context 'other' do
          let(:raw_payload) { { a: 1 }.to_json }
          it('raises error') { expect { result }.to raise_error ::Karafka::Errors::DeserializationError }
        end
      end
    end
  end
end
