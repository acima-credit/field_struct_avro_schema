# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    class MetadataBuilder
      class << self
        def build(schema)
          new(schema).build
        end

        def default_options
          {
            type: :flexible,
            extras: :ignore
          }
        end
      end

      attr_reader :schema, :options

      def initialize(schema, options = {})
        @schema  = schema
        @options = options
      end

      def build
        args = [name, schema_name, options[:type], options[:extras], attributes]
        Metadata.new(*args).tap { |x| x.version = version }
      end

      private

      def name
        schema_name.split('.').map(&:camelize).join('::')
      end

      def schema_name
        [schema[:namespace], schema[:name], version_name].compact.join('.')
      end

      def version_name
        found = version
        found ? "v#{found}" : nil
      end

      def version
        return nil unless schema[:doc]

        match = schema[:doc].to_s.match(/version ([a-f0-9]{3,15})/)
        match ? match[1] : nil
      end

      def attributes
        schema[:fields].each_with_object({}) do |attr, hsh|
          name, fields = build_attribute attr
          hsh[name]    = fields
        end
      end

      def build_attribute(attr)
        name   = attr.delete :name
        fields = {}

        build_attribute_type attr, fields
        fields[:default]     = attr[:default] if attr.key?(:default)
        fields[:description] = attr[:doc] if attr.key?(:doc)

        [name, fields]
      end

      def build_attribute_type(attr, fields)
        if attr[:type].is_a?(Array)
          type = attr[:type].reject { |x| x == 'null' }.first.to_sym
        else
          type              = attr[:type].to_sym
          fields[:required] = true
        end
        fields[:type] = AVRO_TYPES[type].first if AVRO_TYPES.key?(type)
      end
    end
  end

  class Metadata
    def self.from_avro_schema(schema)
      AvroSchema::MetadataBuilder.build schema
    end
  end
end
