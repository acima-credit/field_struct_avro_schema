# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Developer do
  subject { described_class.metadata }

  let(:exp_meta) do
    {
      name: 'Examples::Developer',
      schema_name: 'examples.developer',
      version: '5251a97e',
      attributes: {
        first_name: { type: :string, required: true, min_length: 3, max_length: 20 },
        last_name: { type: :string, required: true },
        title: { type: :string, default: '<proc>' },
        language: { type: :string, required: true }
      }
    }
  end
  let(:exp_schema) do
    {
      type: 'record',
      name: 'developer',
      namespace: 'examples',
      doc: '| version 5251a97e',
      fields: [
        { name: :first_name, type: 'string', doc: '| type string' },
        { name: :last_name, type: 'string', doc: '| type string' },
        { name: :title, type: %w[null string], doc: '| type string' },
        { name: :language, type: 'string', doc: '| type string' }
      ]
    }
  end
  let(:exp_version_meta) do
    [
      {
        name: 'Schemas::Examples::Developer::V5251a97e',
        schema_name: 'schemas.examples.developer.v5251a97e',
        version: '5251a97e',
        attributes: {
          first_name: { type: :string, required: true },
          last_name: { type: :string, required: true },
          title: { type: :string },
          language: { type: :string, required: true }
        }
      }
    ]
  end

  let(:act_meta) { subject.to_hash }
  let(:act_avro) { subject.as_avro_schema }
  let(:blt_meta) { FieldStruct::Metadata.from_avro_schema act_avro }
  let(:blt_klas) { FieldStruct.from_metadata blt_meta.last }

  it('matches') { compare act_meta, exp_meta }

  context 'from Avro' do
    it 'builds a valid metadata' do
      expect { blt_meta }.to_not raise_error
      expect(blt_meta).to be_a Array
      expect(blt_meta.size).to eq 1
      expect(blt_meta.first).to be_a FieldStruct::Metadata
      compare blt_meta.map(&:to_hash), exp_version_meta
    end
  end

  context 'to Avro' do
    it('#as_avro_schema') { compare act_avro, exp_schema }
    it('#to_avro_json') { compare subject.to_avro_json, exp_schema.to_json }
  end

  context 'to and from Avro' do
    let(:original) { described_class.new developer_attrs }
    let(:clone) { blt_klas.new developer_attrs }
    it 'works' do
      expect { original }.to_not raise_error

      expect(original).to be_valid
      expect(original.first_name).to eq 'John'
      expect(original.last_name).to eq 'Max'
      expect(original.title).to eq 'VP of Engineering'
      expect(original.language).to eq 'Haskell'

      expect { blt_klas }.to_not raise_error

      expect { clone }.to_not raise_error

      expect(clone).to be_valid
      expect(clone.first_name).to eq 'John'
      expect(clone.last_name).to eq 'Max'
      expect(clone.title).to eq 'VP of Engineering'
      expect(clone.language).to eq 'Haskell'
    end
  end
end