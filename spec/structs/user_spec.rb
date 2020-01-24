# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::User do
  subject { described_class.metadata }

  let(:exp_meta) do
    {
      name: 'Examples::User',
      schema_name: 'examples.user',
      version: '5cf8302f',
      attributes: {
        username: { type: :string, required: true, format: /\A[a-z]/i, description: 'login' },
        password: { type: :string },
        age: { type: :integer, required: true },
        owed: { type: :currency, required: true, description: 'amount owed to the company' },
        source: { type: :string, required: true, enum: %w[A B C] },
        level: { type: :integer, required: true, default: '<proc>' },
        at: { type: :time },
        active: { type: :boolean, default: false }
      }
    }
  end
  let(:exp_schema) do
    {
      type: 'record',
      name: 'user',
      namespace: 'examples',
      doc: '| version 5cf8302f',
      fields: [
        { name: :username, type: 'string', doc: 'login | type string' },
        { name: :password, type: %w[null string], doc: '| type string' },
        { name: :age, type: 'int', doc: '| type integer' },
        { name: :owed, type: 'float', doc: 'amount owed to the company | type currency' },
        { name: :source, type: 'string', doc: '| type string' },
        { name: :level, type: 'int', doc: '| type integer' },
        { name: :at, type: %w[null string], doc: '| type time' },
        { name: :active, type: %w[boolean null], default: false, doc: '| type boolean' }
      ]
    }
  end
  let(:exp_version_meta) do
    {
      name: 'Examples::User::V5cf8302f',
      schema_name: 'examples.user.v5cf8302f',
      version: '5cf8302f',
      attributes: {
        username: { type: :string, required: true, description: 'login' },
        password: { type: :string },
        age: { type: :integer, required: true },
        owed: { type: :currency, required: true, description: 'amount owed to the company' },
        source: { type: :string, required: true },
        level: { type: :integer, required: true },
        at: { type: :time },
        active: { type: :boolean, default: false }
      }
    }
  end

  let(:act_meta) { subject.to_hash }
  let(:act_avro) { subject.as_avro_schema }
  let(:blt_meta) { FieldStruct::Metadata.from_avro_schema act_avro }
  let(:blt_klas) { FieldStruct.from_metadata blt_meta, 'My::Schemas' }

  it('matches') do
    # puts "act_meta | (#{act_meta.class.name}) #{act_meta.inspect}"
    # puts "act_avro | (#{act_avro.class.name}) #{act_avro.inspect}"
    # puts "blt_meta | (#{blt_meta.class.name}) #{blt_meta.to_hash.inspect}"
    expect(act_meta).to eq exp_meta
  end

  context 'to Avro' do
    it('#as_avro_schema') { expect(act_avro).to eq exp_schema }
    it('#to_avro_json') { expect(subject.to_avro_json).to eq exp_schema.to_json }
    context '#to_avro_schema' do
      it('type') { expect(subject.to_avro_schema).to be_a Avro::Schema::RecordSchema }
      it('type') { expect(subject.to_avro_schema).to be_a Avro::Schema }
      it('to_s') { expect(subject.to_avro_schema.to_s).to eq exp_schema.to_json }
    end
  end

  context 'from Avro' do
    it 'builds a valid metadata' do
      expect { blt_meta }.to_not raise_error
      expect(blt_meta).to be_a FieldStruct::Metadata
      expect(blt_meta.to_hash).to eq exp_version_meta
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
    end
  end
end
