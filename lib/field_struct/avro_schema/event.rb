# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Event
      def self.included(base)
        base.send :include, FieldStruct::AvroExtension
        base.extend ClassMethods
        AvroSchema::Kafka.register_event base
      end

      module ClassMethods
        def inherited(child)
          super
          child.send :include, FieldStruct::AvroExtension
          child.topic_key topic_key
          child.topic_key topic_key
          AvroSchema::Kafka.register_event child
        end

        def from(instance)
          new instance.attributes.to_hash
        end

        def schema_id(value = :none)
          @schema_id = value unless value == :none
          @schema_id
        end

        def default_topic_name
          name.split('::').map(&:underscore).join('.')
        end

        def topic_name(value = :none)
          @topic_name = value unless value == :none
          @topic_name || default_topic_name
        end

        def default_schema_record_name
          metadata.schema_name
        end

        def schema_record_name(value = :none)
          @schema_record_name = value unless value == :none
          @schema_record_name || default_schema_record_name
        end

        def default_schema_naming_strategy
          :legacy_topic_name
        end

        def schema_naming_strategy(value = :none)
          unless value == :none
            unless AvroSchema::Kafka::SCHEMA_NAMING_STRATEGIES.include?(value)
              raise(ArgumentError, "must be one of [#{AvroSchema::Kafka::SCHEMA_NAMING_STRATEGIES.join(',')}]")
            end

            @schema_naming_strategy = value
          end

          @schema_naming_strategy || default_schema_naming_strategy
        end

        def default_topic_key
          :guid
        end

        def topic_key(value = :none)
          @topic_key = value unless value == :none
          @topic_key || default_topic_key
        end

        def default_publishable
          true
        end

        def publishable(value = :none)
          @publishable = value unless value == :none
          @publishable || default_publishable
        end

        def publishable?
          publishable
        end

        def avro_template
          @avro_template ||= metadata.as_avro_template
        end

        def schema
          @schema ||= metadata.to_avro_json true
        end
      end

      def topic_name
        self.class.topic_name
      end

      def topic_key
        send self.class.topic_key
      end

      def schema_id
        self.class.schema_id
      end

      def publishable?
        self.class.publishable
      end

      def topic_encoded(mode = :json)
        case mode
        when :json
          to_json
        when :avro_messaging
          to_avro_messaging
        else
          raise "unknown mode [#{mode}]"
        end
      end

      def to_avro_messaging
        ::FieldStruct::AvroSchema::Kafka.encode_avro to_avro_hash, schema_id: schema_id
      end
    end
  end
end
