# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    class MetadataBuilder
      def self.build(schema)
        new(schema).build
      end

      def self.default_options
        {
          type: :flexible,
          extras: :ignore
        }
      end

      attr_reader :schema, :options

      def initialize(schema, options = {})
        @schema  = schema
        @options = self.class.default_options.merge options
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

        build_attribute_doc attr, fields
        fields[:required] = true unless attr[:type].is_a?(Array)
        fields[:default]  = attr[:default] if attr.key?(:default)

        [name, fields]
      end

      def build_attribute_doc(attr, fields)
        return unless attr[:doc]

        doc, meta            = attr[:doc].to_s.split('|')
        fields[:description] = doc.strip if doc.present?
        match                = meta.match(/ type ([\w:]+)/)
        return unless match

        build_attribute_type_from attr, fields, match
      end

      def build_attribute_type_from(_attr, fields, match)
        main, extra = match[1].to_s.split(':')
        return unless ACTIVE_MODEL_TYPES.include?(main.to_sym)

        fields[:type] = main.to_sym
        fields[:of]   = extra if extra.present? && ACTIVE_MODEL_TYPES.include?(extra.to_sym)
      end
    end
  end

  class Metadata
    def self.from_avro_schema(schema)
      AvroSchema::MetadataBuilder.build schema
    end
  end
end
