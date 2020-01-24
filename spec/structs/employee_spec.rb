# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examples::Employee do
  describe 'class' do
    context '.metadata' do
      subject { described_class.metadata }
      it '#as_avro_schema' do
        expect(subject.as_avro_schema).to eq name: 'employee',
                                             namespace: 'examples',
                                             type: 'record',
                                             fields: [
                                               { name: :first_name, type: 'string', doc: '| type string' },
                                               { name: :last_name, type: 'string', doc: '| type string' },
                                               { name: :title, type: %w[null string], doc: '| type string' }
                                             ],
                                             doc: '| version c4c4ab50'
      end
    end
  end
end
