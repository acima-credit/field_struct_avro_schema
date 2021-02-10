# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Karafka
      # Module for all supported by default serialization and deserialization ways
      module Serialization
        module AvroMessaging
          class Serializer
            # @param content [Object] any object that we want to convert to an avro string
            # @return [String] Valid AVRO Messaging string containing serialized data
            # @raise [Karafka::Errors::SerializationError] raised when we don't have a way to
            #   serialize provided data to json
            # @note When string is passed to this method, we assume that it is already an Avro
            #   string and we don't serialize it again. This allows us to serialize data before
            #   it is being forwarded to this serializer if we want to have a custom (not that simple)
            #   json serialization
            #
            # @example From an Event object
            #   Serializer.call(Event.first) #=> binary string
            # @example From a string (no changes)
            #   Serializer.call(binary_string) #=> binary_string
            def call(content)
              return content if content.is_a?(String)

              if content.respond_to?(:to_avro_hash)
                encoded = AvroSchema::Kafka.encode_avro(content, schema_id: content.schema_id)
                return encoded
              end

              raise ::Karafka::Errors::SerializationError, content
            end
          end
        end
      end
    end
  end
end
