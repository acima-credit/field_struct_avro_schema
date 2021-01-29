# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Person do
  subject { described_class.metadata }

  let(:exp_meta) do
    {
      name: 'Examples::Person',
      schema_name: 'examples.person',
      version: '75b71433',
      attributes: {
        first_name: { type: :string, required: true, min_length: 3, max_length: 20 },
        last_name: { type: :string, required: true }
      }
    }
  end
  let(:exp_template) do
    <<~CODE.chomp
      namespace 'examples'

      record :person, :doc=>"| version 75b71433" do
        required :first_name, :string, doc: "| type string"
        required :last_name, :string, doc: "| type string"
      end
    CODE
  end
  let(:exp_schema) do
    {
      type: 'record',
      name: 'person',
      namespace: 'examples',
      doc: '| version 75b71433',
      fields: [
        { name: 'first_name', type: 'string', doc: '| type string' },
        { name: 'last_name', type: 'string', doc: '| type string' }
      ]
    }
  end
  let(:exp_version_meta) do
    [
      {
        name: 'Schemas::Examples::Person::V75b71433',
        schema_name: 'schemas.examples.person.v75b71433',
        attributes: {
          first_name: { type: :string, required: true },
          last_name: { type: :string, required: true }
        },
        version: '75b71433'
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

  context 'to and from Avro hash' do
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
    it('#to_avro_hash') { compare act_hash, exp_avro_hsh }
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
end
