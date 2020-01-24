# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Company do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
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
                type: { type: 'array', items: 'examples.employee' },
                doc: 'Team members | type array:examples.employee'
              }
            ]
          },
          {
            type: 'record',
            name: 'company',
            namespace: 'examples',
            doc: '| version b23718a6',
            fields: [
              { name: :legal_name, type: 'string', doc: '| type string' },
              {
                name: :development_team,
                type: ['null', 'examples.team'],
                doc: '| type examples.team'
              },
              {
                name: :marketing_team,
                type: ['null', 'examples.team'],
                doc: '| type examples.team'
              }
            ]
          }
        ]
      end
      it '#as_avro_schema' do
        expect(subject.as_avro_schema).to eq exp_hsh
      end
    end
  end
end
