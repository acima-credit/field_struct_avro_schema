# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Team do
  let(:leader_class) { Examples::Employee }
  let(:member_class) { leader_class }
  describe 'class' do
    let(:exp_hsh) do
      [
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
          namespace: 'examples',
          doc: '| version 610c8bc7',
          fields: [
            { name: :name, type: 'string', doc: '| type string' },
            {
              name: :leader,
              type: 'examples.employee',
              doc: '| type examples.employee'
            },
            {
              name: :members,
              type: {
                type: 'array',
                items: 'examples.employee'
              },
              doc: 'Team members | type array:examples.employee'
            }
          ]
        }
      ]
    end
    context '.metadata' do
      subject { described_class.metadata }
      it '#as_avro_schema' do
        expect(subject.as_avro_schema).to eq exp_hsh
      end
      it '#to_avro_json' do
        expect(subject.to_avro_json).to eq exp_hsh.to_json
      end
    end
  end
end
