# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Employee, :focus2 do
  subject { described_class.metadata }

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
end
