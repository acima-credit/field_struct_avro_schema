# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Team do
  subject { described_class.metadata }

  let(:exp_meta) do
    {
      name: 'Examples::Team',
      schema_name: 'examples.team',
      version: '6ce37c6d',
      attributes: {
        name: { type: :string, required: true },
        leader: { type: Examples::Employee, version: '115d6e02', required: true },
        members: {
          type: :array,
          version: '5251a97e',
          required: true,
          of: Examples::Developer,
          description: 'Team members'
        }
      }
    }
  end
  let(:exp_template) do
    <<~CODE.chomp
      namespace 'examples'

      record :team, :doc=>"| version 6ce37c6d" do
        required :name, :string, doc: "| type string"
        required :leader, :employee, namespace: 'examples', doc: "| type examples.employee"
        required :members, :array, items: "examples.developer", doc: "Team members | type array:examples.developer"
      end
    CODE
  end
  let(:exp_schema) do
    { type: 'record',
      name: 'team',
      namespace: 'examples',
      doc: '| version 6ce37c6d',
      fields: [
        { name: 'name', type: 'string', doc: '| type string' },
        {
          name: 'leader',
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
          doc: '| type examples.employee'
        },
        {
          name: 'members',
          type: {
            type: 'array',
            items: { type: 'record',
                     name: 'developer',
                     namespace: 'examples',
                     doc: '| version 5251a97e',
                     fields: [
                       { name: 'first_name', type: 'string', doc: '| type string' },
                       { name: 'last_name', type: 'string', doc: '| type string' },
                       { name: 'title', type: %w[null string], default: nil, doc: '| type string' },
                       { name: 'language', type: 'string', doc: '| type string' }
                     ] }
          },
          doc: 'Team members | type array:examples.developer'
        }
      ] }
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
      }
    ]
  end

  let(:act_meta) { subject.to_hash }
  let(:act_template) { subject.as_avro_template }
  let(:act_avro) { subject.as_avro_schema }
  let(:blt_meta) { FieldStruct::Metadata.from_avro_schema act_avro }
  let(:team_klass) { FieldStruct.from_metadata blt_meta[2] }
  let(:emp_klass) { FieldStruct.from_metadata blt_meta[1] }
  let(:dev_klass) { FieldStruct.from_metadata blt_meta[0] }

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
      expect(blt_meta.size).to eq 3
      expect(blt_meta[2]).to be_a FieldStruct::Metadata
      expect(blt_meta[1]).to be_a FieldStruct::Metadata
      expect(blt_meta[0]).to be_a FieldStruct::Metadata
      compare blt_meta.map(&:to_hash), exp_version_meta
    end
  end

  context 'to and from Avro' do
    let(:leader) { Examples::Employee.new leader_attrs }
    let(:dev1) { Examples::Developer.new dev1_attrs }
    let(:dev2) { Examples::Developer.new dev2_attrs }

    let(:leaderb) { emp_klass.new leader_attrs }
    let(:dev1b) { dev_klass.new dev1_attrs }
    let(:dev2b) { dev_klass.new dev2_attrs }

    let(:original) { described_class.new team_attrs }
    let(:clone) { team_klass.new team_attrs }
    it 'works' do
      expect { original }.to_not raise_error

      expect(original).to be_valid
      expect(original.name).to eq 'Duper Team'
      expect(original.leader).to eq leader
      expect(original.members).to eq [dev1, dev2]

      expect { emp_klass }.to_not raise_error
      expect(emp_klass).to eq Schemas::Examples::Employee::V115d6e02

      expect { leaderb }.to_not raise_error
      expect(leaderb.first_name).to eq leader_attrs[:first_name]
      expect(leaderb.last_name).to eq leader_attrs[:last_name]
      expect(leaderb.title).to eq leader_attrs[:title]

      expect { dev_klass }.to_not raise_error
      expect(dev_klass).to eq Schemas::Examples::Developer::V5251a97e

      expect { dev1b }.to_not raise_error
      expect(dev1b.first_name).to eq dev1_attrs[:first_name]
      expect(dev1b.last_name).to eq dev1_attrs[:last_name]
      expect(dev1b.title).to eq  dev1_attrs[:title]
      expect(dev1b.language).to eq dev1_attrs[:language]

      expect { dev2b }.to_not raise_error
      expect(dev2b.first_name).to eq dev2_attrs[:first_name]
      expect(dev2b.last_name).to eq dev2_attrs[:last_name]
      expect(dev2b.title).to eq  dev2_attrs[:title]
      expect(dev2b.language).to eq dev2_attrs[:language]

      expect { team_klass }.to_not raise_error
      expect(team_klass).to eq Schemas::Examples::Team::V6ce37c6d

      expect { clone }.to_not raise_error
      expect(clone).to be_a Schemas::Examples::Team::V6ce37c6d
      expect(clone).to be_valid
      expect(clone.name).to eq 'Duper Team'
      expect(clone.leader).to eq leaderb
      expect(clone.members).to eq [dev1b, dev2b]
    end
  end
end
