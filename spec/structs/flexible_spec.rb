# frozen_string_literal: true

require 'spec_helper'

module FieldStruct
  module FlexibleExamples
    class User < FieldStruct.flexible
      required :username, :string, format: /\A[a-z]/i, description: 'login'
      optional :password, :string
      required :age, :integer
      required :owed, :float, description: 'amount owed to the company'
      required :source, :string, enum: %w[A B C]
      required :level, :integer, default: -> { 2 }
      optional :at, :time
      optional :active, :boolean, default: false
    end

    class Person < FieldStruct.flexible
      required :first_name, :string, length: 3..20
      required :last_name, :string

      def full_name
        [first_name, last_name].select(&:present?).join(' ')
      end
    end

    class Employee < Person
      extras :add
      optional :title, :string
    end

    class Developer < Employee
      required :language, :string
    end

    class Team < FieldStruct.flexible
      extras :ignore
      required :name, :string
      required :leader, Employee
      required :members, :array, of: Employee, description: 'Team members'
    end

    class Company < FieldStruct.flexible
      required :legal_name, :string
      optional :development_team, Team
      optional :marketing_team, Team
    end
  end
end

RSpec.describe FieldStruct::FlexibleExamples::User do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      let(:exp_hsh) do
        {
          type: 'record',
          name: 'user',
          namespace: 'field_struct.flexible_examples',
          doc: 'version 245178bc',
          fields: [
            { name: :username, type: 'string', doc: 'login' },
            { name: :password, type: %w[null string] },
            { name: :age, type: 'int' },
            { name: :owed, type: 'float', doc: 'amount owed to the company' },
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

RSpec.describe FieldStruct::FlexibleExamples::Person do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      let(:exp_hsh) do
        {
          type: 'record',
          name: 'person',
          namespace: 'field_struct.flexible_examples',
          doc: 'version 75b71433',
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

RSpec.describe FieldStruct::FlexibleExamples::Employee do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      it '#as_avro_schema' do
        expect(subject.as_avro_schema).to eq name: 'employee',
                                             namespace: 'field_struct.flexible_examples',
                                             type: 'record',
                                             fields: [
                                               { name: :first_name, type: 'string' },
                                               { name: :last_name, type: 'string' },
                                               { name: :title, type: %w[null string] }
                                             ],
                                             doc: 'version c4c4ab50'
      end
    end
  end
end

RSpec.describe FieldStruct::FlexibleExamples::Developer do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      it '#as_avro_schema' do
        expect(subject.as_avro_schema).to eq name: 'developer',
                                             namespace: 'field_struct.flexible_examples',
                                             type: 'record',
                                             fields: [
                                               { name: :first_name, type: 'string' },
                                               { name: :last_name, type: 'string' },
                                               { name: :title, type: %w[null string] },
                                               { name: :language, type: 'string' }
                                             ],
                                             doc: 'version b061a6fa'
      end
    end
  end
end

RSpec.describe FieldStruct::FlexibleExamples::Team do
  let(:leader_class) { FieldStruct::FlexibleExamples::Employee }
  let(:member_class) { leader_class }
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      it '#as_avro_schema' do
        expect(subject.as_avro_schema).to eq [
          {
            name: 'employee',
            namespace: 'field_struct.flexible_examples',
            type: 'record',
            fields: [
              { name: :first_name, type: 'string' },
              { name: :last_name, type: 'string' },
              { name: :title, type: %w[null string] }
            ],
            doc: 'version c4c4ab50'
          },
          {
            name: 'team',
            namespace: 'field_struct.flexible_examples',
            type: 'record',
            fields: [
              { name: :name, type: 'string' },
              { name: :leader, type: 'field_struct.flexible_examples.employee' },
              {
                name: :members,
                type: { type: 'array', items: 'field_struct.flexible_examples.employee' },
                doc: 'Team members'
              }
            ],
            doc: 'version 5a034ba'
          }
        ]
      end
    end
  end
end

RSpec.describe FieldStruct::FlexibleExamples::Company do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      it '#as_avro_schema' do
        expect(subject.as_avro_schema).to eq [
          {
            name: 'employee',
            namespace: 'field_struct.flexible_examples',
            type: 'record',
            fields: [
              { name: :first_name, type: 'string' },
              { name: :last_name, type: 'string' },
              { name: :title, type: %w[null string] }
            ],
            doc: 'version c4c4ab50'
          },
          {
            name: 'team',
            namespace: 'field_struct.flexible_examples',
            type: 'record',
            fields: [
              { name: :name, type: 'string' },
              { name: :leader, type: 'field_struct.flexible_examples.employee' },
              {
                name: :members,
                type: { type: 'array', items: 'field_struct.flexible_examples.employee' },
                doc: 'Team members'
              }
            ],
            doc: 'version 5a034ba'
          },
          {
            name: 'company',
            namespace: 'field_struct.flexible_examples',
            type: 'record',
            fields: [
              { name: :legal_name, type: 'string' },
              { name: :development_team, type: ['null', 'field_struct.flexible_examples.team'] },
              { name: :marketing_team, type: ['null', 'field_struct.flexible_examples.team'] }
            ],
            doc: 'version 21b9bca5'
          }
        ]
      end
    end
  end
end
