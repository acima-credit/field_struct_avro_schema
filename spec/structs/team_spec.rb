# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Team do
  subject { described_class.metadata }
  let(:exp_schema_id) { 5 }

  let(:exp_hash) do
    {
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
          version: '57552ad2',
          required: true,
          of: {
            name: 'Examples::Developer',
            schema_name: 'examples.developer',
            attributes: {
              first_name: { type: :string, required: true, min_length: 3, max_length: 20 },
              last_name: { type: :string, required: true },
              title: { type: :string, default: '<proc>' },
              language: { type: :string, required: true },
              password: { type: :string, required: true, avro: { logical_type: 'sensitive-data', field_id: 'dev_pw' } }
            },
            version: '57552ad2'
          },
          description: 'Team members'
        }
      },
      version: '0f4f0194'
    }
  end
  let(:exp_template) do
    <<~CODE.chomp
      namespace 'examples'

      record :team, :doc=>"| version 0f4f0194" do
        required :name, :string, doc: "| type string"
        required :leader, "examples.employee", doc: "| type examples.employee"
        required :members, :array, items: "examples.developer", doc: "Team members | type array:examples.developer"
      end
    CODE
  end
  let(:exp_schema) do
    { type: 'record',
      name: 'team',
      namespace: 'examples',
      doc: '| version 0f4f0194',
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
                     doc: '| version 57552ad2',
                     fields: [
                       { name: 'first_name', type: 'string', doc: '| type string' },
                       { name: 'last_name', type: 'string', doc: '| type string' },
                       { name: 'title', type: %w[null string], default: nil, doc: '| type string' },
                       { name: 'language', type: 'string', doc: '| type string' },
                       { name: 'password', type: { type: 'string', logicalType: 'sensitive-data', fieldId: 'dev_pw' }, doc: '| type string' }
                     ] }
          },
          doc: 'Team members | type array:examples.developer'
        }
      ] }
  end
  let(:exp_json) do
    <<~JSON.chomp
      {
        "type": "record",
        "name": "team",
        "namespace": "examples",
        "doc": "| version 0f4f0194",
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
                "doc": "| version 57552ad2",
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
                  },
                  {
                    "name": "password",
                    "type": {
                      "type": "string",
                      "logicalType": "sensitive-data",
                      "fieldId": "dev_pw"
                    },
                    "doc": "| type string"
                  }
                ]
              }
            },
            "doc": "Team members | type array:examples.developer"
          }
        ]
      }
    JSON
  end
  let(:exp_version_meta) do
    [
      {
        name: 'Schemas::Examples::Developer::V57552ad2',
        schema_name: 'schemas.examples.developer.v57552ad2',
        version: '57552ad2',
        attributes: {
          first_name: { type: :string, required: true },
          last_name: { type: :string, required: true },
          title: { type: :string },
          language: { type: :string, required: true },
          password: { type: :string, required: true }
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
        name: 'Schemas::Examples::Team::V0f4f0194',
        schema_name: 'schemas.examples.team.v0f4f0194',
        version: '0f4f0194',
        attributes: {
          name: { type: :string, required: true },
          leader: { type: 'Schemas::Examples::Employee::V115d6e02', required: true },
          members: {
            description: 'Team members',
            type: :array,
            of: 'Schemas::Examples::Developer::V57552ad2',
            required: true
          }
        }
      }
    ]
  end

  let(:act_hash) { subject.to_hash }
  let(:act_template) { subject.as_avro_template }
  let(:act_avro) { subject.as_avro_schema }
  let(:blt_meta) { FieldStruct::Metadata.from_avro_schema act_avro }
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
      expect(dev_klass).to eq Schemas::Examples::Developer::V57552ad2

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
      expect(team_klass).to eq Schemas::Examples::Team::V0f4f0194

      expect { clone }.to_not raise_error
      expect(clone).to be_a Schemas::Examples::Team::V0f4f0194
      expect(clone).to be_valid
      expect(clone.name).to eq 'Duper Team'
      expect(clone.leader).to eq leaderb
      expect(clone.members).to eq [dev1b, dev2b]
    end
  end

  context 'to Avro hash' do
    let(:instance) { described_class.new team_attrs }
    let(:act_hash) { instance.to_avro_hash }
    let(:cloned_attrs) { described_class.convert_avro_attributes act_hash }
    let(:cloned) { described_class.from_avro_hash act_hash }
    let(:cloned_hsh) { cloned.to_hash.deep_symbolize_keys }
    let(:exp_hsh) do
      {
        name: 'Duper Team',
        leader: {
          first_name: 'Karl',
          last_name: 'Marx',
          title: 'Team Lead'
        },
        members: [
          { first_name: 'John', last_name: 'Stalingrad', title: 'Developer', language: 'Ruby', password: 'rubyroxx' },
          { first_name: 'Steve', last_name: 'Romanoff', title: 'Designer', language: 'In Design', password: 'IHeartComputers' }
        ]
      }
    end
    let(:exp_avro_hsh) { exp_hsh }
    it('#to_avro_hash') { compare instance.to_avro_hash, exp_hsh }
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
    let(:source) { OpenStruct.new attributes: team_attrs }
    let(:instance) { described_class.from source }
    let(:topic_name) { 'examples.team' }
    let(:topic_key) { :name }
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
      it('#topic_key') { compare instance.topic_key, 'Duper Team' }
      it('#schema_id') { expect(instance.schema_id).to be_nil }
      it('to_hash') { compare instance.to_hash, team_attrs.deep_stringify_keys }
    end
  end
  context 'registration' do
    let(:registration) { kafka.register_event_schema described_class }
    it('Kafka has event registered') { expect(kafka.events[described_class.name]).to eq described_class }
    it 'registers with schema_registry', :vcr, :registers do
      expect { registration }.to_not raise_error
      expect(described_class.schema_id).to eq exp_schema_id
    end
  end
  context 'encoding and decoding', :vcr, :serde do
    let(:instance) { described_class.new team_attrs }
    let(:decoded) { kafka.decode encoded, described_class.topic_name }
    context 'avro' do
      let(:encoded) { kafka.encode_avro instance, schema_id: exp_schema_id }
      let(:exp_encoded) do
        "\u0000\u0000\u0000\u0000\u0005\u0014Duper Team\bKarl\bMarx\u0002\u0012" \
          "Team Lead\u0004\bJohn\u0014Stalingrad\u0002\u0012Developer\bRuby2ENCRYPTED" \
          ":dev_pw:rubyroxx\nSteve\u0010Romanoff\u0002\u0010Designer\u0012In Design@" \
          "ENCRYPTED:dev_pw:IHeartComputers\u0000"
      end
      let(:exp_decoded) { instance.to_hash.deep_symbolize_keys }
      it('encodes properly') { compare encoded, exp_encoded }
      it('decodes properly') { compare decoded, exp_decoded }
    end
    context 'json' do
      let(:encoded) { kafka.encode_json instance }
      let(:exp_encoded) do
        '{"name":"Duper Team","leader":{"first_name":"Karl","last_name":"Marx","title":"Team Lead"},"members":[{' \
          '"first_name":"John","last_name":"Stalingrad","title":"Developer","language":"Ruby","password":"rubyroxx"}' \
          ',{"first_name":"Steve","last_name":"Romanoff","title":"Designer","language":"In Design","password":"IHeartComputers"}]}'
      end
      let(:exp_decoded) { JSON.parse instance.to_hash.to_json }
      it('encodes properly') { compare encoded, exp_encoded }
      it('decodes properly') { compare decoded, exp_decoded }
    end
  end
end
