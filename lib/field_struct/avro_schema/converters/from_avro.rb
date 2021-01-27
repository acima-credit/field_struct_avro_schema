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

        def convert
          klass.new build_final_attrs
        end

        private

        def build_final_attrs
          attrs.each_with_object({}) do |(key, value), hsh|
            next if value.nil?

            attr = metadata[key]
            hsh[key] = convert_value attr, value
          end
        end

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
          attr.type.from_avro_hash value
        end

        def convert_array_value(attr, value)
          value.map { |x| attr.of.from_avro_hash x }
        end

        def convert_simple_value(attr, value)
          converter = ValueConverters::Registry.find attr.of || attr.type
          return value unless converter

          res = converter.from_avro value
          puts "> convert_simple_value | #{attr.of || attr.type} : #{res.class.name} : #{res.inspect}"
          res
        end
      end

      def self.from_avro(*args)
        FromAvro.new(*args).convert
      end
    end
  end
end
