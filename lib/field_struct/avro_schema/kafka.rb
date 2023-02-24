# frozen_string_literal: true

require_relative 'kafka/in_memory_cache'
require_relative 'kafka/schema_registry'
require_relative 'kafka/cached_schema_registry'
require_relative 'kafka/schema_store'

require_relative 'kafka/coders/base_decoder'
require_relative 'kafka/coders/base_encoder'
require_relative 'kafka/coders/avro_decoder'
require_relative 'kafka/coders/avro_encoder'
require_relative 'kafka/coders/json_decoder'
require_relative 'kafka/coders/json_encoder'
require_relative 'kafka/coders/string_decoder'
require_relative 'kafka/coders/string_encoder'

module FieldStruct
  module AvroSchema
    module Kafka
      class SchemaNotFoundError < StandardError
      end

      MAGIC_BYTE = [0].pack('C').freeze

      SCHEMA_NAMING_STRATEGIES = %i[legacy_topic_name topic_name record_name topic_record_name].freeze

      module_function

      def logger
        @logger || AvroSchema.logger
      end

      def logger=(value)
        @logger = value
      end

      def events
        @events ||= {}
      end

      def schema_registry
        @schema_registry ||= CachedSchemaRegistry.new base_schema_registry, cache: schema_registry_cache
      end

      def base_schema_registry
        @base_schema_registry ||= SchemaRegistry.new registry_url, logger: logger
      end

      def registry_url
        @registry_url ||
          ENV.fetch('SCHEMA_REGISTRY_URL') do
            ENV.fetch('KAFKA_SCHEMA_REGISTRY_URL', 'http://localhost:8081')
          end.delete_suffix('/')
      end

      def schema_registry_cache
        @schema_registry_cache ||= InMemoryCache.new
      end

      def builder_store_path
        @builder_store_path
      end

      def builder_store_path=(value)
        @builder_store = SchemaStore.new value
        @builder_store_path = value
      end

      def builder_store
        @builder_store ||= SchemaStore.new builder_store_path
      end

      def build_subject_name(klass)
        case klass.schema_naming_strategy
        when :legacy_topic_name
          klass.topic_name
        when :topic_name
          "#{klass.topic_name}-value"
        when :record_name
          "#{klass.schema_record_name}-value"
        when :topic_record_name
          "#{klass.topic_name}-#{klass.schema_record_name}-value"
        else
          raise(StandardError, "Naming strategy #{klass.schema_naming_strategy} is invalid or not supported.")
        end
      end

      def register_event(klass)
        events[klass.name] = klass
      end

      def register_event_schemas
        events.values
              .select(&:publishable?)
              .each { |klass| register_event_schema klass }
        events
      end

      def register_event_schema(klass)
        return nil unless klass.publishable?

        id = schema_registry.register build_subject_name(klass), klass.schema
        klass.schema_id id
        klass
      rescue StandardError => e
        logger.error "Could not register event schema for #{klass} : #{e.class.name} : #{e.message}"
        raise e
      end

      def encode_avro(*args, **kwargs)
        AvroEncoder.encode(*args, **kwargs)
      end

      def encode_json(*args, **kwargs)
        JsonEncoder.encode(*args, **kwargs)
      end

      def encode_string(*args, **kwargs)
        StringEncoder.encode(*args, **kwargs)
      end

      def decode(payload, topic)
        AvroDecoder.decode(payload, topic) ||
          JsonDecoder.decode(payload, topic) ||
          StringDecoder.decode(payload, topic)
      end
    end
  end
end
