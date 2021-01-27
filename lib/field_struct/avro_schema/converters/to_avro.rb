# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Converters
      class ToAvro
        attr_reader :instance, :metadata

        def initialize(instance)
          @instance = instance
          @metadata = instance.class.metadata
        end

        def convert
          metadata.keys.each_with_object({}) do |key, hsh|
            value = instance.get_attribute key.to_s
            next if value.nil?

            attr = metadata[key]
            hsh[key] = convert_value attr, value
          end
        end

        private

        def convert_value(attr, value)
          if value.respond_to? :to_avro_hash
            value.to_avro_hash
          elsif value.is_a? Array
            value.map { |x| convert_value attr, x }
          else
            convert_simple_value attr, value
          end
        end

        def convert_simple_value(attr, value)
          converter = ValueConverters::Registry.find attr.of || attr.type
          return value unless converter

          converter.to_avro value
        end
      end

      def self.to_avro(*args)
        ToAvro.new(*args).convert
      end
    end
  end
end
