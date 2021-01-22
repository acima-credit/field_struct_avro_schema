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
  let(:exp_schema) do
    { type: 'record',
      name: 'friend',
      namespace: 'example_app.examples',
      doc: '| version 82f78509',
      fields: [
        { name: :name, type: 'string', doc: '| type string' },
        { name: :age, type: %w[null int], doc: '| type integer' },
        { name: :balance_owed, type: %w[float null], default: 0.0, doc: '| type currency' },
        { name: :gamer_level, type: %w[null int], doc: '| type integer' },
        { name: :zip_code, type: %w[null string], doc: '| type string' }
      ] }
  end
  let(:exp_version_meta) do
    [
      {
        name: 'Schemas::ExampleApp::Examples::Friend::V82f78509',
        schema_name: 'schemas.example_app.examples.friend.v82f78509',
        attributes: {
          name: { type: :string, required: true },
          age: { type: :integer },
          balance_owed: { type: :currency, default: 0.0 },
          gamer_level: { type: :integer },
          zip_code: { type: :string }
        },
        version: '82f78509'
      }
    ]
  end

  let(:act_meta) { subject.to_hash }
  let(:act_avro) { subject.as_avro_schema }
  let(:blt_meta) { FieldStruct::Metadata.from_avro_schema act_avro }
  let(:blt_klas) { FieldStruct.from_metadata blt_meta.last }

  it('matches') { compare act_meta, exp_meta }

  context 'to Avro' do
    it('#as_avro_schema') { compare act_avro, exp_schema }
    it('#to_avro_json') { compare subject.to_avro_json, exp_schema.to_json }
  end

  context 'from Avro' do
    it 'builds a valid metadata' do
      expect { blt_meta }.to_not raise_error
      expect(blt_meta).to be_a Array
      expect(blt_meta.size).to eq 1
      expect(blt_meta.first).to be_a FieldStruct::Metadata
      puts "> blt_meta.map(&:to_hash) : #{blt_meta.map(&:to_hash).inspect}"
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
end