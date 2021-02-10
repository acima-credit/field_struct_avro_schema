# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Karafka
      module Serialization
        module AvroMessaging
          class Deserializer
            # @param params [Karafka::Params::Params] Full params object that we want to deserialize
            # @return [Hash] hash with deserialized JSON data
            # @example
            #   params = {
            #     'payload' => binary_string,
            #     'topic' => 'my-topic',
            #     'headers' => { 'message_type' => :test }
            #   }
            #   Deserializer.call(params) #=> { 'a' => 1 }
            def call(params)
              return nil if params.raw_payload.nil?

              decoded = AvroSchema::Kafka::AvroDecoder.new(params.raw_payload, params.topic).decode
              return decoded unless decoded == false

              raise params.raw_payload
            rescue StandardError => e
              raise ::Karafka::Errors::DeserializationError, e
            end
          end
        end
      end
    end
  end
end
