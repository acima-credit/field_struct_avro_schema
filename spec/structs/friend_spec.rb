# frozen_string_literal: true

RSpec.describe ExampleApp::Examples::Friend do
  subject { described_class.metadata }
  let(:exp_schema_id) { 8 }

  let(:exp_hash) do
    {
      name: 'ExampleApp::Examples::Friend',
      schema_name: 'example_app.examples.friend',
      attributes: {
        name: { type: :string, required: true },
        age: { type: :integer },
        balance_owed: { type: :currency, default: 0.0 },
        balance_owed_d: { type: :binary, avro: { logical_type: 'decimal', precision: 8, scale: 2 }, default: 0.0 },
        gamer_level: { type: :integer, enum: [1, 2, 3], default: '<proc>' },
        zip_code: { type: :string, format: /\A[0-9]{5}?\z/ }
      },
      version: 'ddcef2cf'
    }
  end
  let(:exp_template) do
    <<~CODE.chomp
      namespace 'example_app.examples'

      record :friend, :doc=>"| version ddcef2cf" do
        required :name, :string, doc: "| type string"
        optional :age, :int, doc: "| type integer"
        optional :balance_owed, :int, default: 0.0, doc: "| type currency"
        optional :balance_owed_d, :bytes, logical_type: "decimal", :precision => 8, :scale => 2, default: 0.0, doc: "| type binary"
        optional :gamer_level, :int, doc: "| type integer"
        optional :zip_code, :string, doc: "| type string"
      end
    CODE
  end
  let(:exp_schema) do
    {
      type: 'record',
      name: 'friend',
      namespace: 'example_app.examples',
      doc: '| version ddcef2cf',
      fields: [
        { name: 'name', type: 'string', doc: '| type string' },
        { name: 'age', type: %w[null int], default: nil, doc: '| type integer' },
        { name: 'balance_owed', type: %w[null int], default: nil, doc: '| type currency' },
        {
          name: 'balance_owed_d',
          type: ['null', { type: 'bytes', logicalType: 'decimal', precision: 8, scale: 2 }],
          default: nil,
          doc: '| type binary'
        },
        { name: 'gamer_level', type: %w[null int], default: nil, doc: '| type integer' },
        { name: 'zip_code', type: %w[null string], default: nil, doc: '| type string' }
      ]
    }
  end
  let(:exp_json) do
    <<~JSON.chomp
      {
        "type": "record",
        "name": "friend",
        "namespace": "example_app.examples",
        "doc": "| version ddcef2cf",
        "fields": [
          {
            "name": "name",
            "type": "string",
            "doc": "| type string"
          },
          {
            "name": "age",
            "type": [
              "null",
              "int"
            ],
            "default": null,
            "doc": "| type integer"
          },
          {
            "name": "balance_owed",
            "type": [
              "null",
              "int"
            ],
            "default": null,
            "doc": "| type currency"
          },
          {
            "name": "balance_owed_d",
            "type": [
              "null",
              {
                "type": "bytes",
                "logicalType": "decimal",
                "precision": 8,
                "scale": 2
              }
            ],
            "default": null,
            "doc": "| type binary"
          },
          {
            "name": "gamer_level",
            "type": [
              "null",
              "int"
            ],
            "default": null,
            "doc": "| type integer"
          },
          {
            "name": "zip_code",
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
        name: 'Schemas::ExampleApp::Examples::Friend::Vddcef2cf',
        schema_name: 'schemas.example_app.examples.friend.vddcef2cf',
        attributes: {
          name: { type: :string, required: true },
          age: { type: :integer },
          balance_owed: { type: :currency },
          balance_owed_d: { type: :binary },
          gamer_level: { type: :integer },
          zip_code: { type: :string }
        },
        version: 'ddcef2cf'
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
    let(:original) { described_class.new friend_attrs }
    let(:clone) { blt_klas.new friend_attrs }
    it 'works' do
      expect { original }.to_not raise_error

      expect(original).to be_valid
      expect(original.name).to eq 'Carl Rovers'
      expect(original.age).to eq 45
      expect(original.balance_owed).to eq 25.75
      expect(original.gamer_level).to eq 2
      expect(original.zip_code).to eq '84120'

      expect { blt_klas }.to_not raise_error

      expect { clone }.to_not raise_error

      expect(clone).to be_valid
      expect(clone.name).to eq 'Carl Rovers'
      expect(clone.age).to eq 45
      expect(clone.balance_owed).to eq 25.75
      expect(clone.gamer_level).to eq 2
      expect(clone.zip_code).to eq '84120'
    end
  end

  context 'to Avro hash' do
    let(:instance) { described_class.new friend_attrs }
    let(:act_hash) { instance.to_avro_hash }
    let(:cloned_attrs) { described_class.convert_avro_attributes act_hash }
    let(:cloned) { described_class.from_avro_hash act_hash }
    let(:cloned_hsh) { cloned.to_hash.deep_symbolize_keys }
    let(:exp_avro_hsh) do
      {
        name: 'Carl Rovers',
        age: 45,
        balance_owed: 2575,
        balance_owed_d: BigDecimal("25.75"),
        gamer_level: 2,
        zip_code: '84120'
      }
    end
    let(:exp_hsh) do
      {
        name: 'Carl Rovers',
        age: 45,
        balance_owed: 25.75,
        balance_owed_d: 25.75,
        gamer_level: 2,
        zip_code: '84120'
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
    let(:source) { OpenStruct.new attributes: friend_attrs }
    let(:instance) { described_class.from source }
    let(:topic_name) { 'example_app.examples.friend' }
    let(:topic_key) { :name }
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
      it('#topic_key') { compare instance.topic_key, 'Carl Rovers' }
      it('#schema_id') { expect(instance.schema_id).to be_nil }
      it('to_hash') { compare instance.to_hash, friend_attrs.deep_stringify_keys }
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
  context 'encoding and decoding', :vcr, :serde do
    let(:instance) { described_class.new friend_attrs }
    let(:decoded) { kafka.decode encoded, described_class.topic_name }
    context 'avro' do
      let(:encoded) { kafka.encode_avro instance, schema_id: exp_schema_id }
      let(:exp_encoded) do
        "\u0000\u0000\u0000\u0000\b\u0016Carl Rovers\u0002Z\u0002\x9E(\u0002\u0004\n\u000F\u0002\u0004\u0002\n84120"
      end
      let(:exp_decoded) { instance.to_hash.deep_symbolize_keys }
      it('encodes properly') { compare encoded, exp_encoded }
      it('decodes properly') { compare decoded, exp_decoded }
    end
    context 'json' do
      let(:encoded) { kafka.encode_json instance }
      let(:exp_encoded) do
        '{"name":"Carl Rovers","age":45,"balance_owed":25.75,"balance_owed_d":"25.75","gamer_level":2,"zip_code":"84120"}'
      end
      let(:exp_decoded) { JSON.parse instance.to_hash.to_json }
      it('encodes properly') { compare encoded, exp_encoded }
      it('decodes properly') { compare decoded, exp_decoded }
    end
  end
end
