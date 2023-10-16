# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Kafka
      class AvroEncoder < BaseEncoder
        def initialize(message, schema_name: nil, subject: nil, version: nil, schema_id: nil)
          super
          @schema_name = schema_name
          @subject = subject
          @version = version
          @schema_id = schema_id
        end

        def encode
          schema_id, schema = fetch_schema_from_registry

          stream = ::StringIO.new
          writer = ::Avro::IO::DatumWriter.new schema
          encoder = ::Avro::IO::BinaryEncoder.new stream

          encoder.write MAGIC_BYTE
          encoder.write [schema_id].pack('N')
          writer.write @message, encoder

          stream.string
        end

        private

        def fetch_schema_from_registry
          fetch_schema_by_id || fetch_schema || register_schema || missing_get_schema_args
        rescue Excon::Error::NotFound
          raise SchemaNotFoundError, "Schema with id: #{@schema_id} is not found on registry" if @schema_id

          raise SchemaNotFoundError, "Schema with subject: `#{@subject}` version: `#{@version}` is not found on registry"
        end

        def fetch_schema_by_id
          return unless @schema_id

          schema_json = Kafka.schema_registry.fetch @schema_id
          schema = Avro::Schema.parse schema_json
          [@schema_id, schema]
        end

        def fetch_schema
          return unless @subject && @version

          schema_data = Kafka.schema_registry.subject_version @subject, @version
          schema_id = schema_data.fetch('id')
          schema = Avro::Schema.parse(schema_data.fetch('schema'))
          [schema_id, schema]
        end

        def register_schema
          return unless @schema_name

          schema = Kafka.builder_store.find @schema_name
          schema_id = @registry.register @subject || schema.fullname, schema
          [schema_id, schema]
        end

        def missing_get_schema_args
          raise ArgumentError,
                'Neither schema_name nor schema_id nor subject + version provided to determine the schema.'
        end

        def prepare_message(message)
          msg = message.respond_to?(:to_avro_hash) ? message.to_avro_hash : message
          msg = msg.deep_stringify_keys if msg.respond_to?(:deep_stringify_keys)
          msg
        end
      end
    end
  end
end
