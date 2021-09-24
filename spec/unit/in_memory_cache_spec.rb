# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FieldStruct::AvroSchema::Kafka::InMemoryCache do
  let(:model) { Examples::Person }
  let(:schema) { model.metadata.to_avro_json }
  let(:schema_name) { model.topic_name }
  context 'mocked' do
    subject { described_class.new.mock! }
    it 'registers and then can find that schema' do
      expect(subject.stats).to eq schemas_by_id: 0,
                                  ids_by_schema: 0,
                                  schema_by_subject_version: 0
      expect { subject.lookup_by_schema schema_name, schema }.to_not raise_error
      expect(subject.stats).to eq schemas_by_id: 1,
                                  ids_by_schema: 1,
                                  schema_by_subject_version: 0
    end
  end
end
