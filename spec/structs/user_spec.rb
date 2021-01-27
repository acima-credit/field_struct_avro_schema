# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::User do
  subject { described_class.metadata }

  let(:exp_meta) do
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
        required :owed, :float, doc: "amount owed to the company | type currency"
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
        { name: 'owed', type: 'float', doc: 'amount owed to the company | type currency' },
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
    let(:cloned) { described_class.from_avro_hash act_hash }
    let(:cloned_hsh) { cloned.to_hash.deep_symbolize_keys }
    let(:exp_avro_hsh) do
      {
        username: 'some_user',
        password: 'some_password',
        age: 45,
        owed: 1537.25,
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
        at: past_time,
        active: true
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
