# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Company do
  subject { described_class.metadata }
  let(:exp_schema_id) { 3 }

  let(:exp_hash) do
    {
      name: 'Examples::Company',
      schema_name: 'examples.company',
      attributes: {
        legal_name: { type: :string, required: true },
        development_team: {
          type: {
            name: 'Examples::Team',
            schema_name: 'examples.team',
            attributes: {
              name: { type: :string, required: true },
              leader: {
                type: {
                  name: 'Examples::Employee',
                  schema_name: 'examples.employee',
                  attributes: {
                    first_name: { type: :string, required: true, min_length: 3, max_length: 20 },
                    last_name: { type: :string, required: true },
                    title: { type: :string, default: '<proc>' }
                  },
                  version: '115d6e02'
                },
                version: '115d6e02',
                required: true
              },
              members: {
                type: :array,
                version: '5251a97e',
                required: true,
                of: {
                  name: 'Examples::Developer',
                  schema_name: 'examples.developer',
                  attributes: {
                    first_name: { type: :string, required: true, min_length: 3, max_length: 20 },
                    last_name: { type: :string, required: true },
                    title: { type: :string, default: '<proc>' },
                    language: { type: :string, required: true }
                  },
                  version: '5251a97e'
                },
                description: 'Team members'
              }
            },
            version: 'c055f985'
          },
          version: 'c055f985'
        },
        marketing_team: {
          type: {
            name: 'Examples::Team',
            schema_name: 'examples.team',
            attributes: {
              name: { type: :string, required: true },
              leader: {
                type: {
                  name: 'Examples::Employee',
                  schema_name: 'examples.employee',
                  attributes: {
                    first_name: { type: :string, required: true, min_length: 3, max_length: 20 },
                    last_name: { type: :string, required: true }, title: { type: :string, default: '<proc>' }
                  },
                  version: '115d6e02'
                },
                version: '115d6e02',
                required: true
              },
              members: {
                type: :array,
                version: '5251a97e',
                required: true,
                of: {
                  name: 'Examples::Developer',
                  schema_name: 'examples.developer',
                  attributes: {
                    first_name: { type: :string, required: true, min_length: 3, max_length: 20 },
                    last_name: { type: :string, required: true },
                    title: { type: :string, default: '<proc>' },
                    language: { type: :string, required: true }
                  },
                  version: '5251a97e'
                },
                description: 'Team members'
              }
            },
            version: 'c055f985'
          },
          version: 'c055f985'
        }
      },
      version: '2e14ef35'
    }
  end
  let(:exp_template) do
    <<~CODE.chomp
      namespace 'examples'

      record :company, :doc=>"| version 2e14ef35" do
        required :legal_name, :string, doc: "| type string"
        optional :development_team, "examples.team", doc: "| type examples.team"
        optional :marketing_team, "examples.team", doc: "| type examples.team"
      end
    CODE
  end
  let(:exp_schema) do
    {
      type: 'record',
      name: 'company',
      namespace: 'examples',
      doc: '| version 2e14ef35',
      fields: [
        { name: 'legal_name', type: 'string', doc: '| type string' },
        { name: 'development_team',
          type: ['null',
                 { type: 'record',
                   name: 'team',
                   namespace: 'examples',
                   doc: '| version c055f985',
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
  let(:exp_json) do
    <<~JSON.chomp
      {
        "type": "record",
        "name": "company",
        "namespace": "examples",
        "doc": "| version 2e14ef35",
        "fields": [
          {
            "name": "legal_name",
            "type": "string",
            "doc": "| type string"
          },
          {
            "name": "development_team",
            "type": [
              "null",
              {
                "type": "record",
                "name": "team",
                "namespace": "examples",
                "doc": "| version c055f985",
                "fields": [
                  {
                    "name": "name",
                    "type": "string",
                    "doc": "| type string"
                  },
                  {
                    "name": "leader",
                    "type": {
                      "type": "record",
                      "name": "employee",
                      "namespace": "examples",
                      "doc": "| version 115d6e02",
                      "fields": [
                        {
                          "name": "first_name",
                          "type": "string",
                          "doc": "| type string"
                        },
                        {
                          "name": "last_name",
                          "type": "string",
                          "doc": "| type string"
                        },
                        {
                          "name": "title",
                          "type": [
                            "null",
                            "string"
                          ],
                          "default": null,
                          "doc": "| type string"
                        }
                      ]
                    },
                    "doc": "| type examples.employee"
                  },
                  {
                    "name": "members",
                    "type": {
                      "type": "array",
                      "items": {
                        "type": "record",
                        "name": "developer",
                        "namespace": "examples",
                        "doc": "| version 5251a97e",
                        "fields": [
                          {
                            "name": "first_name",
                            "type": "string",
                            "doc": "| type string"
                          },
                          {
                            "name": "last_name",
                            "type": "string",
                            "doc": "| type string"
                          },
                          {
                            "name": "title",
                            "type": [
                              "null",
                              "string"
                            ],
                            "default": null,
                            "doc": "| type string"
                          },
                          {
                            "name": "language",
                            "type": "string",
                            "doc": "| type string"
                          }
                        ]
                      }
                    },
                    "doc": "Team members | type array:examples.developer"
                  }
                ]
              }
            ],
            "default": null,
            "doc": "| type examples.team"
          },
          {
            "name": "marketing_team",
            "type": [
              "null",
              "examples.team"
            ],
            "default": null,
            "doc": "| type examples.team"
          }
        ]
      }
    JSON
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
        name: 'Schemas::Examples::Team::Vc055f985',
        schema_name: 'schemas.examples.team.vc055f985',
        version: 'c055f985',
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
        name: 'Schemas::Examples::Company::V2e14ef35',
        schema_name: 'schemas.examples.company.v2e14ef35',
        attributes: { legal_name: { type: :string, required: true },
                      development_team: { type: 'Schemas::Examples::Team::Vc055f985' },
                      marketing_team: { type: 'Schemas::Examples::Team::Vc055f985' } },
        version: '2e14ef35'
      }
    ]
  end
  let(:exp_hash_hash) do
    {}
  end

  let(:act_hash) { subject.to_hash }
  let(:act_template) { subject.as_avro_template }
  let(:act_avro) { subject.as_avro_schema }
  let(:blt_meta) { FieldStruct::Metadata.from_avro_schema act_avro }
  let(:comp_klass) { FieldStruct.from_metadata blt_meta[3] }
  let(:team_klass) { FieldStruct.from_metadata blt_meta[2] }
  let(:emp_klass) { FieldStruct.from_metadata blt_meta[1] }
  let(:dev_klass) { FieldStruct.from_metadata blt_meta[0] }

  it('matches') { compare act_hash, exp_hash }

  context 'to Avro' do
    it('#as_avro_template') { compare act_template, exp_template }
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
    it 'works' do
      expect { original }.to_not raise_error

      expect(original).to be_valid
      expect(original.to_hash).to eq exp_comp_hsh

      expect { emp_klass }.to_not raise_error
      expect(emp_klass).to eq Schemas::Examples::Employee::V115d6e02

      expect { dev_klass }.to_not raise_error
      expect(dev_klass).to eq Schemas::Examples::Developer::V5251a97e

      expect { team_klass }.to_not raise_error
      expect(team_klass).to eq Schemas::Examples::Team::Vc055f985

      expect { comp_klass }.to_not raise_error
      expect(comp_klass).to eq Schemas::Examples::Company::V2e14ef35

      expect { clone }.to_not raise_error

      expect(clone).to be_a Schemas::Examples::Company::V2e14ef35
      expect(clone).to be_valid
      expect(clone.to_hash).to eq exp_comp_hsh
      expect(clone.development_team).to be_a team_klass
      expect(clone.development_team.members.map(&:class)).to eq [dev_klass, dev_klass]
      expect(clone.marketing_team).to be_a team_klass
      expect(clone.marketing_team.members.map(&:class)).to eq [dev_klass, dev_klass]
    end
  end

  context 'to Avro hash' do
    let(:instance) { described_class.new company_attrs }
    let(:act_hash) { instance.to_avro_hash }
    let(:cloned_attrs) { described_class.convert_avro_attributes act_hash }
    let(:cloned) { described_class.from_avro_hash act_hash }
    let(:cloned_hsh) { cloned.to_hash.deep_symbolize_keys }
    let(:exp_avro_hsh) { exp_hsh }
    let(:exp_hsh) do
      {
        legal_name: 'My Super Company',
        development_team: {
          name: 'Duper Team',
          leader: { first_name: 'Karl', last_name: 'Marx', title: 'Team Lead' },
          members: [
            { first_name: 'John', last_name: 'Stalingrad', title: 'Developer', language: 'Ruby' },
            { first_name: 'Steve', last_name: 'Romanoff', title: 'Designer', language: 'In Design' }
          ]
        },
        marketing_team: {
          name: 'Growing Team',
          leader: { first_name: 'Evan', last_name: 'Majors', title: 'Team Lead' },
          members: [
            { first_name: 'Rob', last_name: 'Morris', title: 'Developer', language: 'Javascript' },
            { first_name: 'Zach', last_name: 'Evanoff', title: 'Designer', language: 'Photoshop' }
          ]
        }
      }
    end
    it('#to_avro_hash') { compare instance.to_avro_hash, exp_avro_hsh }
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

  context 'event' do
    let(:source) { OpenStruct.new attributes: company_attrs }
    let(:instance) { described_class.from source }
    let(:topic_name) { 'examples.company' }
    let(:topic_key) { :legal_name }
    let(:new_schema_id) { 99 }
    let(:new_topic_name) { 'some.topic' }
    let(:new_topic_key) { :other }

    context 'class' do
      it('.schema_id') do
        old_schema_id = described_class.schema_id
        described_class.schema_id new_schema_id
        expect(described_class.schema_id).to eq new_schema_id
        described_class.schema_id nil
        expect(described_class.schema_id).to be_nil
        described_class.schema_id old_schema_id
      end
      it('.topic_name') do
        expect(described_class.topic_name).to eq topic_name
        described_class.topic_name new_topic_name
        expect(described_class.topic_name).to eq new_topic_name
        described_class.topic_name nil
        expect(described_class.topic_name).to eq topic_name
      end
      it('.topic_key') do
        expect(described_class.topic_key).to eq topic_key
        described_class.topic_key new_topic_key
        expect(described_class.topic_key).to eq new_topic_key
        described_class.topic_key topic_key
        expect(described_class.topic_key).to eq topic_key
      end
      it('.avro_template') { compare described_class.avro_template, exp_template }
      it('.schema') { compare described_class.schema, exp_json }
    end
    context 'instance' do
      it('event') { expect(instance).to be_a described_class }
      it('#topic_name') { expect(instance.topic_name).to eq topic_name }
      it('#topic_key') { compare instance.topic_key, 'My Super Company' }
      it('#schema_id') { expect(instance.schema_id).to be_nil }
      it('to_hash') { compare instance.to_hash, company_attrs.deep_stringify_keys }
    end
  end
  context 'registration', :vcr, :registers do
    let(:registration) { kafka.register_event_schema described_class }
    it('Kafka has event registered') { expect(kafka.events[described_class.name]).to eq described_class }
    it 'registers with schema_registry' do
      expect { registration }.to_not raise_error
      expect(described_class.schema_id).to eq exp_schema_id
    end
  end
  context 'encoding and decoding', :vcr, :serde do
    let(:instance) { described_class.new company_attrs }
    let(:decoded) { kafka.decode encoded, described_class.topic_name }
    context 'avro' do
      let(:encoded) { kafka.encode_avro instance, schema_id: exp_schema_id }
      let(:exp_encoded) do
        "\u0000\u0000\u0000\u0000\u0003 My Super Company\u0002\u0014Duper Team" \
          "\bKarl\bMarx\u0002\u0012Team Lead\u0004\bJohn\u0014Stalingrad\u0002" \
          "\u0012Developer\bRuby\nSteve\u0010Romanoff\u0002\u0010Designer" \
          "\u0012In Design\u0000\u0002\u0018Growing Team\bEvan\fMajors\u0002" \
          "\u0012Team Lead\u0004\u0006Rob\fMorris\u0002\u0012Developer" \
          "\u0014Javascript\bZach\u000EEvanoff\u0002\u0010Designer" \
          "\u0012Photoshop\u0000"
      end
      let(:exp_decoded) { instance.to_hash.deep_symbolize_keys }
      it('encodes properly') { compare encoded, exp_encoded }
      it('decodes properly') { compare decoded, exp_decoded }
    end
    context 'json' do
      let(:encoded) { kafka.encode_json instance }
      let(:exp_encoded) do
        '{"legal_name":"My Super Company","development_team":{"name":"Duper Team","leader":{"first_name":"Karl","las' \
          't_name":"Marx","title":"Team Lead"},"members":[{"first_name":"John","last_name":"Stalingrad","title":"Dev' \
          'eloper","language":"Ruby"},{"first_name":"Steve","last_name":"Romanoff","title":"Designer","language":"In ' \
          'Design"}]},"marketing_team":{"name":"Growing Team","leader":{"first_name":"Evan","last_name":"Majors","t' \
          'itle":"Team Lead"},"members":[{"first_name":"Rob","last_name":"Morris","title":"Developer","language":"Ja' \
          'vascript"},{"first_name":"Zach","last_name":"Evanoff","title":"Designer","language":"Photoshop"}]}}'
      end
      let(:exp_decoded) { JSON.parse instance.to_hash.to_json }
      it('encodes properly') { compare encoded, exp_encoded }
      it('decodes properly') { compare decoded, exp_decoded }
    end
  end
end
