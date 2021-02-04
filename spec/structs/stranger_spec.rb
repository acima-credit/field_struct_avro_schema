# frozen_string_literal: true

RSpec.describe ExampleApp::Examples::Stranger do
  context 'class' do
    it('.from') { expect(subject).to_not respond_to :from }
    it('.schema_id') { expect(subject).to_not respond_to :schema_id }
    it('.default_topic_name') { expect(subject).to_not respond_to :default_topic_name }
    it('.topic_name') { expect(subject).to_not respond_to :topic_name }
    it('.default_topic_key') { expect(subject).to_not respond_to :default_topic_key }
    it('.topic_key') { expect(subject).to_not respond_to :topic_key }
    it('.avro_template') { expect(subject).to_not respond_to :avro_template }
    it('.schema') { expect(subject).to_not respond_to :schema }
  end
  context 'metadata' do
    subject { described_class.metadata }
    it('.as_avro_template') { expect(subject).to_not respond_to :as_avro_template }
    it('.as_avro') { expect(subject).to_not respond_to :as_avro }
    it('.as_avro_schema') { expect(subject).to_not respond_to :as_avro_schema }
    it('.to_avro_json') { expect(subject).to_not respond_to :to_avro_json }
    it('.from_avro_hash') { expect(subject).to_not respond_to :from_avro_hash }
  end
  context 'instance' do
    subject { described_class.new }
    it('#to_avro_hash') { expect(subject).to_not respond_to :to_avro_hash }
  end
  context 'registration' do
    it('Kafka does not have event registered') { expect(kafka.events[described_class.name]).to be_nil }
  end
end
