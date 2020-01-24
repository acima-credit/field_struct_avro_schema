# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Company, :focus2 do
  subject { described_class.metadata }

  let(:exp_meta) do
    {
      name: 'Examples::Company',
      schema_name: 'examples.company',
      version: '7dda35cf',
      attributes: {
        legal_name: { type: :string, required: true },
        development_team: { type: Examples::Team, version: 'f280c56c' },
        marketing_team: { type: Examples::Team, version: 'f280c56c' }
      }
    }
  end
  let(:exp_schema) do
    [
      {
        type: 'record',
        name: 'developer',
        namespace: 'examples',
        doc: '| version b061a6fa',
        fields: [
          { name: :first_name, type: 'string', doc: '| type string' },
          { name: :last_name, type: 'string', doc: '| type string' },
          { name: :title, type: %w[null string], doc: '| type string' },
          { name: :language, type: 'string', doc: '| type string' }
        ]
      },
      {
        type: 'record',
        name: 'employee',
        namespace: 'examples',
        doc: '| version c4c4ab50',
        fields: [
          { name: :first_name, type: 'string', doc: '| type string' },
          { name: :last_name, type: 'string', doc: '| type string' },
          { name: :title, type: %w[null string], doc: '| type string' }
        ]
      },
      {
        type: 'record',
        name: 'team',
        namespace: 'examples', doc: '| version f280c56c',
        fields: [
          { name: :name, type: 'string', doc: '| type string' },
          { name: :leader, type: 'examples.employee', doc: '| type examples.employee' },
          { name: :members, type: { type: 'array', items: 'examples.developer' },
            doc: 'Team members | type array:examples.developer' }
        ]
      },
      {
        type: 'record',
        name: 'company',
        namespace: 'examples',
        doc: '| version 7dda35cf',
        fields: [
          { name: :legal_name, type: 'string', doc: '| type string' },
          { name: :development_team, type: ['null', 'examples.team'], doc: '| type examples.team' },
          { name: :marketing_team, type: ['null', 'examples.team'], doc: '| type examples.team' }
        ]
      }
    ]
  end
  let(:exp_version_meta) do
    [
      {
        name: 'Schemas::Examples::Developer::Vb061a6fa',
        schema_name: 'schemas.examples.developer.vb061a6fa',
        version: 'b061a6fa',
        attributes: {
          first_name: { type: :string, required: true },
          last_name: { type: :string, required: true },
          title: { type: :string },
          language: { type: :string, required: true }
        }
      },
      {
        name: 'Schemas::Examples::Employee::Vc4c4ab50',
        schema_name: 'schemas.examples.employee.vc4c4ab50',
        version: 'c4c4ab50',
        attributes: {
          first_name: { type: :string, required: true },
          last_name: { type: :string, required: true },
          title: { type: :string }
        }
      },
      {
        name: 'Schemas::Examples::Team::Vf280c56c',
        schema_name: 'schemas.examples.team.vf280c56c',
        version: 'f280c56c',
        attributes: {
          name: { type: :string, required: true },
          leader: { type: 'Schemas::Examples::Employee::Vc4c4ab50', required: true },
          members: {
            description: 'Team members',
            type: :array,
            of: 'Schemas::Examples::Developer::Vb061a6fa',
            required: true
          }
        }
      },
      {
        name: 'Schemas::Examples::Company::V7dda35cf',
        schema_name: 'schemas.examples.company.v7dda35cf',
        version: '7dda35cf',
        attributes: {
          legal_name: { type: :string, required: true },
          development_team: { type: 'Schemas::Examples::Team::Vf280c56c' },
          marketing_team: { type: 'Schemas::Examples::Team::Vf280c56c' }
        }
      }
    ]
  end

  let(:act_meta) { subject.to_hash }
  let(:act_avro) { subject.as_avro_schema }
  let(:blt_meta) { FieldStruct::Metadata.from_avro_schema act_avro }
  let(:comp_klass) { FieldStruct.from_metadata blt_meta[3] }
  let(:team_klass) { FieldStruct.from_metadata blt_meta[2] }
  let(:emp_klass) { FieldStruct.from_metadata blt_meta[1] }
  let(:dev_klass) { FieldStruct.from_metadata blt_meta[0] }

  it('matches') { expect(act_meta).to eq exp_meta }

  context 'to Avro' do
    it('#as_avro_schema') { expect(act_avro).to eq exp_schema }
    it('#to_avro_json') { expect(subject.to_avro_json).to eq exp_schema.to_json }
    context '#to_avro_schema' do
      it('type') { expect(subject.to_avro_schema).to be_a Avro::Schema::UnionSchema }
      it('type') { expect(subject.to_avro_schema).to be_a Avro::Schema }
      it('to_s') { expect(subject.to_avro_schema.to_s).to eq exp_schema.to_json }
    end
  end

  context 'from Avro' do
    it 'builds a valid metadata' do
      expect { blt_meta }.to_not raise_error
      expect(blt_meta).to be_a Array
      expect(blt_meta.size).to eq 4
      expect(blt_meta[3]).to be_a FieldStruct::Metadata
      expect(blt_meta[2]).to be_a FieldStruct::Metadata
      expect(blt_meta[1]).to be_a FieldStruct::Metadata
      expect(blt_meta[0]).to be_a FieldStruct::Metadata
      expect(blt_meta.map(&:to_hash)).to eq exp_version_meta
    end
  end

  context 'to and from Avro', :focus do
    let(:original) { described_class.new company_attrs }
    let(:clone) { comp_klass.new company_attrs }
    let(:exp_comp_hsh) do
      {
        'legal_name' => 'My Super Company',
        'development_team' => {
          'name' => 'Duper Team',
          'leader' => { 'first_name' => 'Karl', 'last_name' => 'Marx', 'title' => 'Team Lead' },
          'members' => [
            { 'first_name' => 'John', 'last_name' => 'Stalingrad', 'title' => 'Developer', 'language' => 'Ruby' },
            { 'first_name' => 'Steve', 'last_name' => 'Romanoff', 'title' => 'Designer', 'language' => 'In Design' }
          ]
        },
        'marketing_team' => {
          'name' => 'Growing Team',
          'leader' => { 'first_name' => 'Evan', 'last_name' => 'Majors', 'title' => 'Team Lead' },
          'members' => [
            { 'first_name' => 'Rob', 'last_name' => 'Morris', 'title' => 'Developer', 'language' => 'Javascript' },
            { 'first_name' => 'Zach', 'last_name' => 'Evanoff', 'title' => 'Designer', 'language' => 'Photoshop' }
          ]
        }
      }
    end
    it 'works' do
      expect { original }.to_not raise_error

      expect(original).to be_valid
      expect(original.to_hash).to eq exp_comp_hsh
      expect { emp_klass }.to_not raise_error
      expect(emp_klass).to eq Schemas::Examples::Employee::Vc4c4ab50

      expect { dev_klass }.to_not raise_error
      expect(dev_klass).to eq Schemas::Examples::Developer::Vb061a6fa

      expect { team_klass }.to_not raise_error
      expect(team_klass).to eq Schemas::Examples::Team::Vf280c56c

      expect { comp_klass }.to_not raise_error
      expect(comp_klass).to eq Schemas::Examples::Company::V7dda35cf

      expect { clone }.to_not raise_error

      expect(clone).to be_a Schemas::Examples::Company::V7dda35cf
      expect(clone).to be_valid
      expect(clone.to_hash).to eq exp_comp_hsh
      expect(clone.development_team).to be_a team_klass
      expect(clone.development_team.members.map(&:class)).to eq [dev_klass, dev_klass]
      expect(clone.marketing_team).to be_a team_klass
      expect(clone.marketing_team.members.map(&:class)).to eq [dev_klass, dev_klass]
    end
  end
end
