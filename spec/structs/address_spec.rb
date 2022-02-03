# frozen_string_literal: true

RSpec.describe PublishableApp::Examples::Address do
  subject { described_class.metadata }

  let(:exp_hash) do
    {
      name: 'PublishableApp::Examples::Address',
      schema_name: 'publishable_app.examples.address',
      attributes: {
        street: { type: :string, required: true },
        city: { type: :string, required: true }
      },
      version: 'c1580c68'
    }
  end
  let(:exp_template) do
    <<~CODE.chomp
      namespace 'publishable_app.examples'

      record :address, :doc=>"| version c1580c68" do
        required :street, :string, doc: "| type string"
        required :city, :string, doc: "| type string"
      end
    CODE
  end
  let(:exp_schema) do
    {
      type: 'record',
      name: 'address',
      namespace: 'publishable_app.examples',
      doc: '| version c1580c68',
      fields: [
        { name: 'street', type: 'string', doc: '| type string' },
        { name: 'city', type: 'string', doc: '| type string' }
      ]
    }
  end
  let(:exp_json) do
    <<~JSON.chomp
      {
        "type": "record",
        "name": "address",
        "namespace": "publishable_app.examples",
        "doc": "| version c1580c68",
        "fields": [
          {
            "name": "street",
            "type": "string",
            "doc": "| type string"
          },
          {
            "name": "city",
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
        name: 'Schemas::PublishableApp::Examples::Address::Vc1580c68',
        schema_name: 'schemas.publishable_app.examples.address.vc1580c68',
        attributes: {
          street: { type: :string, required: true },
          city: { type: :string, required: true }
        },
        version: 'c1580c68'
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
      expect(blt_meta.last).to be_a FieldStruct::Metadata
      compare blt_meta.map(&:to_hash), exp_version_meta
    end
  end

  context 'to and from Avro' do
    let(:original) { described_class.new address_attrs }
    let(:clone) { blt_klas.new address_attrs }
    let(:exp_comp_hsh) { address_attrs.deep_stringify_keys }

    it 'works' do
      expect { original }.to_not raise_error

      expect(original).to be_valid
      expect(original.to_hash).to eq exp_comp_hsh

      expect(original.street).to eq '123 Fast'
      expect(original.city).to eq 'Speedy'

      expect { blt_klas }.to_not raise_error

      expect { clone }.to_not raise_error

      expect(clone.street).to eq '123 Fast'
      expect(clone.city).to eq 'Speedy'
    end
  end

  context 'to Avro hash' do
    let(:instance) { described_class.new address_attrs }
    let(:act_hash) { instance.to_avro_hash }
    let(:cloned_attrs) { described_class.convert_avro_attributes act_hash }
    let(:cloned) { described_class.from_avro_hash act_hash }
    let(:cloned_hsh) { cloned.to_hash.deep_symbolize_keys }
    let(:exp_hsh) do
      {
        street: '123 Fast',
        city: 'Speedy'
      }
    end
    it('#to_avro_hash') { compare instance.to_avro_hash, exp_hsh }
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
    let(:source) { OpenStruct.new attributes: address_attrs }
    let(:instance) { described_class.from source }
    let(:topic_name) { 'publishable_app.examples.address' }
    let(:topic_key) { :city }
    let(:new_schema_id) { 99 }
    let(:new_topic_name) { 'some.topic' }
    let(:new_topic_key) { :other }

    context 'class' do
      it('.schema_id is always nil') do
        expect(described_class.schema_id).to be_nil
        described_class.schema_id new_schema_id
        expect(described_class.schema_id).to be_nil
      end
      it('.topic_name is always nil') do
        expect(described_class.topic_name).to be_nil
        described_class.topic_name new_topic_name
        expect(described_class.topic_name).to be_nil
      end
      it('.topic_key is always nil') do
        expect(described_class.topic_key).to be_nil
        described_class.topic_key new_topic_key
        expect(described_class.topic_key).to be_nil
      end
      it('.avro_template') { compare described_class.avro_template, exp_template }
      it('.schema') { compare described_class.schema, exp_json }
    end
    context 'instance' do
      it('event') { expect(instance).to be_a described_class }
      it('#topic_key') { expect(instance.topic_name).to be_nil }
      it('#topic_key') { expect(instance.topic_key).to be_nil }
      it('#schema_id') { expect(instance.schema_id).to be_nil }
      it('to_hash') { compare instance.to_hash, address_attrs.deep_stringify_keys }
    end
  end
  context 'registration' do
    let(:registration) { kafka.register_event_schema described_class }
    it('Kafka has event registered') { expect(kafka.events[described_class.name]).to eq described_class }
    it 'does not register with schema_registry' do
      expect { registration }.to_not raise_error
      expect(registration).to be_nil
      expect(described_class.schema_id).to be_nil
    end
  end
  context 'encoding and decoding', :vcr, :serde do
    let(:instance) { described_class.new address_attrs }
    let(:decoded) { kafka.decode encoded, described_class.topic_name }
    context 'avro' do
      # since we are not publishing this event to the Schema Registry we cannot use Avro
      # to encode/decode this single event unless it is nested inside another event that
      # is published to the registry.
    end
    context 'json' do
      # since we don't need the schema registry to encode/decode in JSON we can still
      # ensure we can encode/decode plain hashes/JSON
      let(:encoded) { kafka.encode_json instance }
      let(:exp_encoded) do
        '{"street":"123 Fast","city":"Speedy"}'
      end
      let(:exp_decoded) { JSON.parse instance.to_hash.to_json }
      it('encodes properly') { compare encoded, exp_encoded }
      it('decodes properly') { compare decoded, exp_decoded }
    end
  end
end
