# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    class MetadataBuilder
      class SingleBuilder
        attr_reader :schema, :options, :prefix_schema

        def initialize(schema, options = {})
          puts "initialize | schema (#{schema.class.name}) #{schema.inspect}"
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
            default_value = attr[:default]
            if default_value.to_s == '<proc>'
              puts "build_attribute | name : #{name.inspect} | fields[:default] : proc ..."
            elsif default_value.nil?
              puts "build_attribute | name : #{name.inspect} | fields[:default] : proc ..."
            else
              fields[:default] = default_value
              puts "build_attribute | name : #{name.inspect} | fields[:default] : 1 : (#{fields[:default].class.name}) #{fields[:default].inspect}"
            end
          else
            puts "build_attribute | name : #{name.inspect} | fields[:default] : missing ..."
          end

          puts "build_attribute | name : #{name.inspect} | fields : #{fields.inspect}"
          [name, fields]
        end

        def build_attribute_doc(attr, fields)
          return unless attr[:doc]

          doc, meta = attr[:doc].to_s.split('|')
          fields[:description] = doc.strip if doc.present?
          match = meta.match(/ type ([\w:\.]+)/)
          return unless match

          add_attribute_dependency attr
          build_attribute_type_from attr, fields, match
        end

        def add_attribute_dependency(attr)
          type = attr[:type]
          type = type.reject { |x| x == 'null' }.first if type.is_a? Array
          puts "add_attribute_dependency | type : 0 : (#{type.class.name}) #{type.inspect}"
          if type.is_a?(Hash)
            puts "add_attribute_dependency | type : Hash : 1 : #{type.inspect}"
            if type[:type] == 'record'
              @dependencies << type
            elsif type[:type] == 'array' && type.dig(:items, :type) == 'record'
              @dependencies << type[:items]
            else
              raise 'unknown complex type'
            end
          end
          puts "add_attribute_dependency | attr[:type] (#{attr[:type].class.name}) #{attr[:type].inspect} ..."
        end

        def build_attribute_type_from(attr, fields, match)
          puts "build_attribute_type_from | attr : #{attr.inspect}"

          main, extra = match[1].to_s.split(':')
          puts "build_attribute_type_from | name : #{attr[:name]} | attr[:type] : #{attr[:type].inspect} | main : #{main.inspect} | extra : #{extra.inspect}"
          fields[:type] = ACTIVE_MODEL_TYPES.key?(main) ? main.to_sym : main
          puts "build_attribute_type_from | fields : 1 : #{fields.inspect}"
          return unless extra.present?

          fields[:of] = ACTIVE_MODEL_TYPES.key?(extra) ? extra.to_sym : extra
          puts "build_attribute_type_from | fields : 2 : #{fields.inspect}"
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
        puts ">> build | building #{@schemas.size} schemas ..."
        @schemas.each { |schema| @results << build_schema(schema) }
        until @dependencies.empty?
          puts ">> build | building #{@dependencies.size} dependencies ..."
          @results << build_schema(@dependencies.shift)
        end
        puts ">> build | reversing #{@results.size} results ..."
        @results.reverse!
        review_schema_names
        puts ">> build | (#{@results.class.name}) #{@results.to_yaml}"
        @results
      end

      private

      def build_schema(schema)
        @cnt ||= 0
        @cnt += 1
        puts " [ build_schema ##{@cnt} ] ".center(90, '=')
        puts ">> build_schema | schema (#{schema.class.name}) #{schema.inspect}"
        meta, deps = SingleBuilder.new(schema, @options.dup).build
        puts ">> build_schema | meta (#{meta.class.name}) : schema_name : #{meta.schema_name} : to_hash : #{meta.to_hash.to_yaml}"
        puts ">> build_schema | deps (#{deps.class.name}) : #{deps.inspect}"
        name = meta.schema_name.split('.')[0..-2].join('.')
        @options[:schema_names][name] = meta.name
        @dependencies += deps
        meta
      end

      def review_schema_names
        puts ">> review_schema_names | @options[:schema_names] : #{@options[:schema_names].to_yaml}"
        puts ">> review_schema_names | @options[:prefix] : #{@options[:prefix].inspect}"
        @results.each_with_index do |meta, idx|
          puts ">> review_schema_names | #{idx} : meta (#{meta.class.name}) ..."
          meta.keys.each do |attr_name|
            attr = meta[attr_name]
            puts ">> review_schema_names | attr (#{attr.class.name}) #{attr.inspect}"
            # type
            if attr[:type].is_a?(String)
              puts ">> review_schema_names | trying to change attr[:type] #{attr[:type].inspect}"
              new_name = aliased_name attr[:type]
              if new_name
                attr[:type] = new_name
                puts ">> review_schema_names | changed : attr (#{attr.class.name}) #{attr.inspect}"
              else
                puts ">> review_schema_names | NOT changed : attr (#{attr.class.name}) #{attr.inspect}"
              end
            end
            # of
            next unless attr[:of].is_a?(String)

            puts ">> review_schema_names | trying to change attr[:of] #{attr[:of].inspect}"
            new_name = aliased_name attr[:of]
            if new_name
              attr[:of] = new_name
              puts ">> review_schema_names | changed : attr (#{attr.class.name}) #{attr.inspect}"
            else
              puts ">> review_schema_names | NOT changed : attr (#{attr.class.name}) #{attr.inspect}"
            end
            attr[:of] = new_name if new_name
          end
        end
      end

      def aliased_name(str)
        key = prefixed_schema(str)
        res = @options.dig :schema_names, key
        puts ">> review_schema_names | aliased_name : #{key.inspect} : #{res.inspect}"
        res
      end

      def prefixed_schema(str)
        return str unless @options[:prefix].present?

        format('%s.%s', @options[:prefix], str).underscore
      end
    end
  end

  class Metadata
    def self.from_avro_schema(schemas, options = {})
      AvroSchema::MetadataBuilder.build schemas, options
    end
  end
end
