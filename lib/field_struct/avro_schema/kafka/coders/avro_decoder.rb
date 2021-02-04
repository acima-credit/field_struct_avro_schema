# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Kafka
      class AvroDecoder < BaseDecoder
        def initialize(payload, schema_name)
          super
          @schema_name = schema_name
        end

        def decode
          return false unless @data[0, 1] == MAGIC_BYTE

          stream      = StringIO.new @data
          decoder     = ::Avro::IO::BinaryDecoder.new stream
          _magic_byte = decoder.read 1

          schema_id   = decoder.read(4).unpack1 'N'

          readers_schema = nil
          begin
            readers_schema = Kafka.builder_store.find @schema_name
            readers_schema = ::Avro::Schema.parse(readers_schema) if readers_schema.is_a?(String)
          rescue SchemaNotFoundError
            #   log 'readers_schema not found for [%s]', schema_name
          end

          writers_schema = Kafka.schema_registry.fetch schema_id
          writers_schema = ::Avro::Schema.parse(writers_schema) if writers_schema.is_a?(String)

          reader = ::Avro::IO::DatumReader.new writers_schema, readers_schema
          attributes = reader.read(decoder).tap do |res|
            res.deep_symbolize_keys! if res.respond_to? :deep_symbolize_keys!
          end

          event_klass = Kafka.events.values.find { |x| x.topic_name == @schema_name }
          return attributes unless event_klass

          event_klass.convert_avro_attributes(attributes)
        end
      end
    end
  end
end
