# frozen_string_literal: true

module KafkaHelpers
  extend RSpec::Core::SharedContext

  let(:kafka) { FieldStruct::AvroSchema::Kafka }
end

RSpec.configure do |config|
  config.include KafkaHelpers
end
