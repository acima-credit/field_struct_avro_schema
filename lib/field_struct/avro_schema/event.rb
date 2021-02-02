# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Event
      def self.included(base)
        base.send :include, FieldStruct::AvroExtension
        base.extend ClassMethods
      end

      module ClassMethods
        def inherited(child)
          super
          child.send :include, FieldStruct::AvroExtension
          child.topic_key topic_key
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

        def default_topic_key
          :guid
        end

        def topic_key(value = :none)
          @topic_key = value unless value == :none
          @topic_key || default_topic_key
        end

        def avro_template
          @avro_template ||= metadata.as_avro_template
        end

        def schema
          @schema ||= metadata.to_avro_json true
        end

        # def schema_path
        #   @schema_path ||= ::Messaging::Kafka.schema_store_path.join topic_name.gsub('.', '/') + '.avsc'
        # end
        #
        # def builder_schema_path
        #   @builder_schema_path ||= ::Messaging::Kafka.builder_schema_store_path.join topic_name.gsub('.', '/') + '.rb'
        # end
        #
        # def inherited(child)
        #   ::Messaging::Kafka.events[child.topic_name] = child
        #   child.send :include, ::Logging::Mixin
        # end
        #
        # def publish_many(events)
        #   events.map(&:publish)
        # end
      end

      # def publish
      #   DeliveryBoy.deliver_async! topic_encoded(:avro_messaging),
      #                              topic: topic_name,
      #                              key: topic_key
      # end

      def topic_name
        self.class.topic_name
      end

      def topic_key
        send self.class.topic_key
      end

      def schema_id
        self.class.schema_id
      end

      # def to_avro_messaging
      #   ::Messaging::Kafka.encode_avro to_avro_hash, schema_id: schema_id
      # end

      # def topic_encoded(mode = :json)
      #   case mode
      #   when :json
      #     to_json
      #   when :avro_messaging
      #     to_avro_messaging
      #   else
      #     raise "unknown mode [#{mode}]"
      #   end
      # end
    end
  end
end
