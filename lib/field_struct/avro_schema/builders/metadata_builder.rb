# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    class MetadataBuilder
      class SingleBuilder
        attr_reader :schema, :options, :prefix_schema

        def initialize(schema, options = {})
          @schema = schema
          @options = options
          @prefix_schema = options[:prefix].to_s.split('::').map(&:underscore).join('.')
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
          [
            prefix_schema,
            schema[:namespace],
            schema[:name],
            version_name
          ].select(&:present?).join('.')
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
          match                = meta.match(/ type ([\w:\.]+)/)
          return unless match

          build_attribute_type_from attr, fields, match
        end

        def build_attribute_type_from(_attr, fields, match)
          main, extra = match[1].to_s.split(':')

          fields[:type] = options[:schema_names].fetch(prefixed_schema(main), main.to_sym)
          return unless extra.present?

          fields[:of] = options[:schema_names].fetch(prefixed_schema(extra), extra.to_sym)
        end

        def prefixed_schema(str)
          return str unless prefix_schema.present?

          format '%s.%s', prefix_schema, str
        end
      end

      def self.default_options
        {
          type: :flexible,
          extras: :ignore,
          prefix: 'Schemas'
        }
      end

      def self.build(schema, options = {})
        new(schema, options).build
      end

      def initialize(schemas, options = {})
        @schemas = Array([schemas]).flatten
        @options = self.class.default_options.merge(schema_names: {}).merge(options)
      end

      def build
        @schemas.map do |schema|
          SingleBuilder.new(schema, @options.dup).build.tap do |res|
            name = res.schema_name.split('.')[0..-2].join('.')
            @options[:schema_names][name] = res.name
          end
        end
      end
    end
  end

  class Metadata
    def self.from_avro_schema(schemas, options = {})
      AvroSchema::MetadataBuilder.build schemas, options
    end
  end
end
