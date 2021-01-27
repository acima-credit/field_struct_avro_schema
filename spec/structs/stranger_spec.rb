# frozen_string_literal: true

RSpec.describe ExampleApp::Examples::Stranger do
  subject { described_class.metadata }
  let(:instance) { described_class.new }

  context 'class' do
    it('#as_avro_template') { expect(subject).to_not respond_to :as_avro_template }
    it('#as_avro') { expect(subject).to_not respond_to :as_avro }
    it('#as_avro_schema') { expect(subject).to_not respond_to :as_avro_schema }
    it('#to_avro_json') { expect(subject).to_not respond_to :to_avro_json }
    it('#from_avro_hash') { expect(subject).to_not respond_to :from_avro_hash }
  end
  context 'instance' do
    subject { described_class.new }
    it('#to_avro_hash') { expect(subject).to_not respond_to :to_avro_hash }
  end
end
