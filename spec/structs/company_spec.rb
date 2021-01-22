# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Company, :focus do
  subject { described_class.metadata }

  let(:exp_meta) do
    {
      name: 'Examples::Company',
      schema_name: 'examples.company',
      version: 'bb40ff23',
      attributes: {
        legal_name: { type: :string, required: true },
        development_team: { type: Examples::Team, version: '6ce37c6d' },
        marketing_team: { type: Examples::Team, version: '6ce37c6d' }
      }
    }
  end
  let(:exp_schema) do
    {
      type: 'record',
      name: 'company',
      namespace: 'examples',
      doc: '| version bb40ff23',
      fields: [
        { name: 'legal_name', type: 'string', doc: '| type string' },
        { name: 'development_team',
          type: ['null',
                 { type: 'record',
                   name: 'team',
                   namespace: 'examples',
                   doc: '| version 6ce37c6d',
                   fields: [
                     { name: 'name', type: 'string', doc: '| type string' },
                     { name: 'leader',
                       type: {
                         type: 'record',
                         name: 'employee',
                         namespace: 'examples',
                         doc: '| version 115d6e02',
                         fields: [
                           { name: 'first_name', type: 'string', doc: '| type string' },
                           { name: 'last_name', type: 'string', doc: '| type string' },
                           { name: 'title', type: %w[null string], default: nil, doc: '| type string' }
                         ]
                       },
                       doc: '| type examples.employee' },
                     { name: 'members',
                       type: {
                         type: 'array',
                         items: {
                           type: 'record',
                           name: 'developer',
                           namespace: 'examples',
                           doc: '| version 5251a97e',
                           fields: [
                             { name: 'first_name', type: 'string', doc: '| type string' },
                             { name: 'last_name', type: 'string', doc: '| type string' },
                             { name: 'title', type: %w[null string], default: nil, doc: '| type string' },
                             { name: 'language', type: 'string', doc: '| type string' }
                           ]
                         }
                       },
                       doc: 'Team members | type array:examples.developer' }
                   ] }],
          default: nil,
          doc: '| type examples.team' },
        { name: 'marketing_team', type: ['null', 'examples.team'], default: nil, doc: '| type examples.team' }
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
      },
      {
        name: 'Schemas::Examples::Employee::V115d6e02',
        schema_name: 'schemas.examples.employee.v115d6e02',
        version: '115d6e02',
        attributes: {
          first_name: { type: :string, required: true },
          last_name: { type: :string, required: true },
          title: { type: :string }
        }
      },
      {
        name: 'Schemas::Examples::Team::V6ce37c6d',
        schema_name: 'schemas.examples.team.v6ce37c6d',
        version: '6ce37c6d',
        attributes: {
          name: { type: :string, required: true },
          leader: { type: 'Schemas::Examples::Employee::V115d6e02', required: true },
          members: {
            description: 'Team members',
            type: :array,
            of: 'Schemas::Examples::Developer::V5251a97e',
            required: true
          }
        }
      },
      {
        name: 'Schemas::Examples::Company::Vbb40ff23',
        schema_name: 'schemas.examples.company.vbb40ff23',
        attributes: { legal_name: { type: :string, required: true },
                      development_team: { type: 'Schemas::Examples::Team::V6ce37c6d' },
                      marketing_team: { type: 'Schemas::Examples::Team::V6ce37c6d' } },
        version: 'bb40ff23'
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

  it('matches') { compare act_meta, exp_meta }

  context 'to Avro' do
    it('#as_avro_schema') { compare act_avro, exp_schema }
    it('#to_avro_json') { compare subject.to_avro_json, exp_schema.to_json }
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

      act_version_hash = blt_meta.map(&:to_hash)
      compare act_version_hash, exp_version_meta
    end
  end

  context 'to and from Avro' do
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
    it 'works', :focus do
      expect { original }.to_not raise_error

      expect(original).to be_valid
      expect(original.to_hash).to eq exp_comp_hsh

      expect { emp_klass }.to_not raise_error
      expect(emp_klass).to eq Schemas::Examples::Employee::V115d6e02

      expect { dev_klass }.to_not raise_error
      expect(dev_klass).to eq Schemas::Examples::Developer::V5251a97e

      expect { team_klass }.to_not raise_error
      expect(team_klass).to eq Schemas::Examples::Team::V6ce37c6d

      expect { comp_klass }.to_not raise_error
      expect(comp_klass).to eq Schemas::Examples::Company::Vbb40ff23

      expect { clone }.to_not raise_error

      expect(clone).to be_a Schemas::Examples::Company::Vbb40ff23
      expect(clone).to be_valid
      expect(clone.to_hash).to eq exp_comp_hsh
      expect(clone.development_team).to be_a team_klass
      expect(clone.development_team.members.map(&:class)).to eq [dev_klass, dev_klass]
      expect(clone.marketing_team).to be_a team_klass
      expect(clone.marketing_team.members.map(&:class)).to eq [dev_klass, dev_klass]
    end
  end
end
