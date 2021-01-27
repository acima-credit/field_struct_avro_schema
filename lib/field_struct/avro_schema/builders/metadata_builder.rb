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
          @dependencies = []
        end

        def build
          args = [name, schema_name, options[:type], options[:extras], attributes]
          [Metadata.new(*args).tap { |x| x.version = version }, @dependencies]
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
            hsh[name] = fields
          end
        end

        def build_attribute(attr)
          name = attr[:name]
          fields = {}

          build_attribute_doc attr, fields
          fields[:required] = true unless attr[:type].is_a?(Array)
          if attr.keys.include?(:default) && (attr[:default] != '<proc>' && !attr[:default].nil?)
            fields[:default] = attr[:default]
          end
          if attr.key? :default
            fields[:default] = attr[:default] unless attr[:default].to_s == '<proc>' || attr[:default].nil?
          end

          [name, fields]
        end

        def build_attribute_doc(attr, fields)
          return unless attr[:doc]

          doc, meta = attr[:doc].to_s.split('|')
          fields[:description] = doc.strip if doc.present?
          match = meta.match(/ type ([\w:.]+)/)
          return unless match

          add_attribute_dependency attr
          build_attribute_type_from attr, fields, match
        end

        def add_attribute_dependency(attr)
          type = attr[:type]
          type = type.reject { |x| x == 'null' }.first if type.is_a? Array
          return unless type.is_a?(Hash)

          if type[:type] == 'record'
            @dependencies << type
          elsif type[:type] == 'array' && type.dig(:items, :type) == 'record'
            @dependencies << type[:items]
          end
        end

        def build_attribute_type_from(_attr, fields, match)
          main, extra = match[1].to_s.split(':')
          fields[:type] = ACTIVE_MODEL_TYPES.key?(main) ? main.to_sym : main
          return unless extra.present?

          fields[:of] = ACTIVE_MODEL_TYPES.key?(extra) ? extra.to_sym : extra
        end
      end

      def self.default_options
        {
          type: :flexible,
          extras: :ignore,
          prefix: 'Schemas'
        }
      end

      def self.build(schemas, options = {})
        new(schemas, options).build
      end

      def initialize(schemas, options = {})
        @schemas = Array([schemas]).flatten
        @options = self.class.default_options.merge(schema_names: {}).merge(options)
        @dependencies = []
        @results = []
      end

      def build
        @schemas.each { |schema| @results << build_schema(schema) }
        @results << build_schema(@dependencies.shift) until @dependencies.empty?
        @results.reverse!
        review_schema_names
        @results
      end

      private

      def build_schema(schema)
        @cnt ||= 0
        @cnt += 1
        meta, deps = SingleBuilder.new(schema, @options.dup).build
        name = meta.schema_name.split('.')[0..-2].join('.')
        @options[:schema_names][name] = meta.name
        @dependencies += deps
        meta
      end

      def review_schema_names
        @results.each_with_index do |meta, _idx|
          meta.keys.each do |attr_name|
            attr = meta[attr_name]
            # type
            if attr[:type].is_a?(String)
              new_name = aliased_name attr[:type]
              attr[:type] = new_name if new_name
            end
            # of
            next unless attr[:of].is_a?(String)

            new_name = aliased_name attr[:of]
            attr[:of] = new_name if new_name
          end
        end
      end

      def aliased_name(str)
        @options.dig :schema_names, prefixed_schema(str)
      end

      def prefixed_schema(str)
        return str unless @options[:prefix].present?

        format('%s.%s', @options[:prefix], str).underscore
      end
    end
  end
end
