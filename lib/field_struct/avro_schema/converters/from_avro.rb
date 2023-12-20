# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Converters
      class FromAvro
        attr_reader :klass, :metadata, :attrs

        def initialize(klass, attrs)
          @klass = klass
          @metadata = klass.metadata
          @attrs = attrs
        end

        def convert_attributes
          attrs.each_with_object({}) do |(key, value), hsh|
            next if value.nil?

            attr = metadata[key]
            hsh[key] = convert_value attr, value
          end.deep_symbolize_keys
        end

        def convert
          klass.new(**convert_attributes)
        end

        private

        def convert_value(attr, value)
          case value
          when Hash
            convert_hash_value attr, value
          when Array
            convert_array_value attr, value
          else
            convert_simple_value attr, value
          end
        end

        def convert_hash_value(attr, value)
          attr.type.from_avro_hash(value).to_hash
        end

        def convert_array_value(attr, value)
          value.map do |x|
            if attr.of.field_struct?
              attr.of.from_avro_hash(x).to_hash
            else
              convert_simple_value attr, x
            end
          end
        end

        def convert_simple_value(attr, value)
          converter = ValueConverters::Registry.find attr.of || attr.type
          return value unless converter

          converter.from_avro value, attr.avro&.fetch(:logical_type)
        end
      end

      def self.convert_avro_attributes(*args)
        FromAvro.new(*args).convert_attributes
      end

      def self.from_avro(*args)
        FromAvro.new(*args).convert
      end
    end
  end
end
