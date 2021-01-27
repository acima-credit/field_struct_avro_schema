# frozen_string_literal: true

RSpec.describe ExampleApp::Examples::Friend do
  subject { described_class.metadata }

  let(:exp_meta) do
    {
      name: 'ExampleApp::Examples::Friend',
      schema_name: 'example_app.examples.friend',
      attributes: {
        name: { type: :string, required: true },
        age: { type: :integer },
        balance_owed: { type: :currency, default: 0.0 },
        gamer_level: { type: :integer, enum: [1, 2, 3], default: '<proc>' },
        zip_code: { type: :string, format: /\A[0-9]{5}?\z/ }
      },
      version: '82f78509'
    }
  end
  let(:exp_template) do
    <<~CODE.chomp
      namespace 'example_app.examples'

      record :friend, :doc=>"| version 82f78509" do
        required :name, :string, doc: "| type string"
        optional :age, :int, doc: "| type integer"
        optional :balance_owed, :float, default: 0.0, doc: "| type currency"
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
      doc: '| version 82f78509',
      fields: [
        { name: 'name', type: 'string', doc: '| type string' },
        { name: 'age', type: %w[null int], default: nil, doc: '| type integer' },
        { name: 'balance_owed', type: %w[null float], default: nil, doc: '| type currency' },
        { name: 'gamer_level', type: %w[null int], default: nil, doc: '| type integer' },
        { name: 'zip_code', type: %w[null string], default: nil, doc: '| type string' }
      ]
    }
  end
  let(:exp_version_meta) do
    [
      {
        name: 'Schemas::ExampleApp::Examples::Friend::V82f78509',
        schema_name: 'schemas.example_app.examples.friend.v82f78509',
        attributes: {
          name: { type: :string, required: true },
          age: { type: :integer },
          balance_owed: { type: :currency },
          gamer_level: { type: :integer },
          zip_code: { type: :string }
        },
        version: '82f78509'
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
    let(:cloned) { described_class.from_avro_hash act_hash }
    let(:cloned_hsh) { cloned.to_hash.deep_symbolize_keys }
    let(:exp_avro_hsh) { exp_hsh }
    let(:exp_hsh) do
      {
        name: 'Carl Rovers',
        age: 45,
        balance_owed: 25.75,
        gamer_level: 2,
        zip_code: '84120'
      }
    end
    it('#to_avro_hash') { compare instance.to_avro_hash, exp_avro_hsh }
    it('.from_avro_hash') do
      expect { cloned }.to_not raise_error
      expect(cloned).to be_a described_class
      expect(cloned).to be_valid
      compare cloned_hsh, exp_hsh
    end
  end
end
