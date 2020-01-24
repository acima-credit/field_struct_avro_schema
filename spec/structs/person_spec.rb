# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Person do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      let(:exp_hsh) do
        {
          type: 'record',
          name: 'person',
          namespace: 'examples',
          doc: '| version 75b71433',
          fields: [
            { name: :first_name, type: 'string', doc: '| type string' },
            { name: :last_name, type: 'string', doc: '| type string' }
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
