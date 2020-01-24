# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Developer do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      it '#as_avro_schema' do
        expect(subject.as_avro_schema).to eq name: 'developer',
                                             namespace: 'examples',
                                             type: 'record',
                                             fields: [
                                               { name: :first_name, type: 'string', doc: '| type string' },
                                               { name: :last_name, type: 'string', doc: '| type string' },
                                               { name: :title, type: %w[null string], doc: '| type string' },
                                               { name: :language, type: 'string', doc: '| type string' }
                                             ],
                                             doc: '| version b061a6fa'
      end
    end
  end
end
