# frozen_string_literal: true

require 'spec_helper'

module FieldStruct
  module MutableExamples
    class User < FieldStruct.mutable
      required :username, :string, format: /\A[a-z]/i
      optional :password, :string
      required :age, :integer
      required :owed, :float
      required :source, :string, enum: %w[A B C]
      required :level, :integer, default: -> { 2 }
      optional :at, :time
      optional :active, :boolean, default: false
    end

    class Person < FieldStruct.mutable
      required :first_name, :string
      required :last_name, :string

      def full_name
        format '%s %s', first_name, last_name
      end
    end

    class Employee < Person
      extras :add
      optional :title, :string
    end

    class Developer < Employee
      required :language, :string
    end

    class Team < FieldStruct.mutable
      required :name, :string
      required :leader, Employee
    end

    class Company < FieldStruct.mutable
      required :legal_name, :string
      optional :development_team, Team
      optional :marketing_team, Team
    end
  end
end

RSpec.describe FieldStruct::MutableExamples::User do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      let(:exp_hsh) do
        {
          type: 'record',
          name: 'user',
          namespace: 'field_struct.mutable_examples',
          doc: 'version 7d1bd1cb',
          fields: [
            { name: :username, type: 'string' },
            { name: :password, type: %w[null string] },
            { name: :age, type: 'int' },
            { name: :owed, type: 'float' },
            { name: :source, type: 'string' },
            { name: :level, type: 'int' },
            { name: :at, type: %w[null string] },
            { name: :active, type: %w[boolean null], default: false }
          ]
        }
      end
      let(:exp_json) { exp_hsh.to_json }
      it('#as_avro_schema') { expect(subject.as_avro_schema).to eq exp_hsh }
      it('#to_avro_json') { expect(subject.to_avro_json).to eq exp_json }
      context '#to_avro_schema' do
        let(:result) { subject.to_avro_schema }
        it('type') { expect(result).to be_a Avro::Schema }
        it('to_s') { expect(result.to_s).to eq exp_json }
      end
    end
  end
end

RSpec.describe FieldStruct::MutableExamples::Person do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      let(:exp_hsh) do
        {
          type: 'record',
          name: 'person',
          namespace: 'field_struct.mutable_examples',
          doc: 'version 8e0963f3',
          fields: [
            { name: :first_name, type: 'string' },
            { name: :last_name, type: 'string' }
          ]
        }
      end
      let(:exp_json) { exp_hsh.to_json }
      it('#as_avro_schema') { expect(subject.as_avro_schema).to eq exp_hsh }
      it('#to_avro_json') { expect(subject.to_avro_json).to eq exp_json }
      context '#to_avro_schema' do
        let(:result) { subject.to_avro_schema }
        it('type') { expect(result).to be_a Avro::Schema }
        it('to_s') { expect(result.to_s).to eq exp_json }
      end
    end
  end
end

RSpec.describe FieldStruct::MutableExamples::Employee do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      let(:exp_hsh) do
        {
          type: 'record',
          name: 'employee',
          namespace: 'field_struct.mutable_examples',
          doc: 'version 1a3ecbcb',
          fields: [
            { name: :first_name, type: 'string' },
            { name: :last_name, type: 'string' },
            { name: :title, type: %w[null string] }
          ]
        }
      end
      let(:exp_json) { exp_hsh.to_json }
      it('#as_avro_schema') { expect(subject.as_avro_schema).to eq exp_hsh }
      it('#to_avro_json') { expect(subject.to_avro_json).to eq exp_json }
      context '#to_avro_schema' do
        let(:result) { subject.to_avro_schema }
        it('type') { expect(result).to be_a Avro::Schema }
        it('to_s') { expect(result.to_s).to eq exp_json }
      end
    end
  end
end

RSpec.describe FieldStruct::MutableExamples::Developer do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      let(:exp_hsh) do
        {
          type: 'record',
          name: 'developer',
          namespace: 'field_struct.mutable_examples',
          doc: 'version a4cf4b53',
          fields: [
            { name: :first_name, type: 'string' },
            { name: :last_name, type: 'string' },
            { name: :title, type: %w[null string] },
            { name: :language, type: 'string' }
          ]
        }
      end
      let(:exp_json) { exp_hsh.to_json }
      it('#as_avro_schema') { expect(subject.as_avro_schema).to eq exp_hsh }
      it('#to_avro_json') { expect(subject.to_avro_json).to eq exp_json }
      context '#to_avro_schema' do
        let(:result) { subject.to_avro_schema }
        it('type') { expect(result).to be_a Avro::Schema }
        it('to_s') { expect(result.to_s).to eq exp_json }
      end
    end
  end
end

RSpec.describe FieldStruct::MutableExamples::Team do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      let(:exp_hsh) do
        [
          {
            type: 'record',
            name: 'employee',
            namespace: 'field_struct.mutable_examples',
            doc: 'version 1a3ecbcb',
            fields: [
              { name: :first_name, type: 'string' },
              { name: :last_name, type: 'string' },
              { name: :title, type: %w[null string] }
            ]
          },
          {
            type: 'record',
            name: 'team',
            namespace: 'field_struct.mutable_examples',
            doc: 'version a1d952ee',
            fields: [
              { name: :name, type: 'string' },
              { name: :leader, type: 'field_struct.mutable_examples.employee' }
            ]
          }
        ]
      end
      let(:exp_json) { exp_hsh.to_json }
      it('#as_avro_schema') { expect(subject.as_avro_schema).to eq exp_hsh }
      it('#to_avro_json') { expect(subject.to_avro_json).to eq exp_json }
      context '#to_avro_schema' do
        let(:result) { subject.to_avro_schema }
        it('type') { expect(result).to be_a Avro::Schema }
        it('to_s') { expect(result.to_s).to eq exp_json }
      end
    end
  end
end

RSpec.describe FieldStruct::MutableExamples::Company do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      let(:exp_hsh) do
        [
          {
            type: 'record',
            name: 'employee',
            namespace: 'field_struct.mutable_examples',
            doc: 'version 1a3ecbcb',
            fields: [
              { name: :first_name, type: 'string' },
              { name: :last_name, type: 'string' },
              { name: :title, type: %w[null string] }
            ]
          },
          {
            type: 'record',
            name: 'team',
            namespace: 'field_struct.mutable_examples',
            doc: 'version a1d952ee',
            fields: [
              { name: :name, type: 'string' },
              { name: :leader, type: 'field_struct.mutable_examples.employee' }
            ]
          },
          {
            type: 'record',
            name: 'company',
            namespace: 'field_struct.mutable_examples',
            doc: 'version b8b8c2dd',
            fields: [
              { name: :legal_name, type: 'string' },
              { name: :development_team, type: %w[null field_struct.mutable_examples.team] },
              { name: :marketing_team, type: %w[null field_struct.mutable_examples.team] }
            ]
          }
        ]
      end
      let(:exp_json) { exp_hsh.to_json }
      it('#as_avro_schema') { expect(subject.as_avro_schema).to eq exp_hsh }
      it('#to_avro_json') { expect(subject.to_avro_json).to eq exp_json }
      context '#to_avro_schema' do
        let(:result) { subject.to_avro_schema }
        it('type') { expect(result).to be_a Avro::Schema }
        it('to_s') { expect(result.to_s).to eq exp_json }
      end
    end
  end
end
