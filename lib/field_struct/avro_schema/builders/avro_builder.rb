# frozen_string_literal: true

require_relative 'avro_builder/schema_store'

module FieldStruct
  module AvroSchema
    class AvroBuilder
      class << self
        attr_reader :builder_store_path

        # @param [Pathname] value path to DSL schemas
        def builder_store_path=(value)
          @builder_store = SchemaStore.new value
          @builder_store_path = value
        end

        def builder_store
          @builder_store ||= SchemaStore.new builder_store_path
        end

        def build(metadata)
          new(metadata).build
        end
      end

      attr_reader :meta

      def initialize(meta)
        @meta = meta
      end

      def build
        build_namespace
        build_extras
        build_record
        build_dependencies
        build_attributes
        build_template
        build_dsl
      end

      private

      def build_namespace
        parts = meta.schema_name.split('.')
        @record_name = parts.pop
        @namespace = parts.join '.'
      end

      def build_extras
        @extras = []
      end

      def build_record
        @record_options = {
          doc: "| version #{meta.version}"
        }
      end

      def build_dependencies
        meta.attributes.each do |_name, attr|
          [attr.type, attr.of].compact.each do |type|
            self.class.build(type.metadata) if type.field_struct?
          end
        end
      end

      def build_attributes
        @attributes = meta.attributes.map do |name, attr|
          build_attribute name, attr
        end
      end

      def build_attribute(name, attr)
        hsh = {
          name: name,
          mode: attr.required? ? :required : :optional
        }
        add_field_type_for attr, hsh
        add_field_default_for attr, hsh
        add_field_doc_for attr, hsh
        hsh
      end

      def build_template
        ary = []
        ary << "namespace '#{@namespace}'" << '' if @namespace.present?
        rec_opts = @record_options.inspect[1..-2]
        ary << "record :#{@record_name}, #{rec_opts} do"
        @attributes.each { |opts| ary << build_attr_line(opts) }
        ary << 'end'

        @template = ary.join("\n")
      end

      def build_attr_line(opts)
        line = '  '.dup
        line << "#{opts[:mode]} :#{opts[:name]}"
        type_parts = opts[:type].to_s.split('.')
        if type_parts.size > 1
          type_name = type_parts.pop
          type_namespace = type_parts.join('.')
          line << ", :#{type_name}, namespace: '#{type_namespace}'"
        else
          line << ", :#{opts[:type]}"
        end
        line += ", items: #{opts[:items].inspect}" if opts.key?(:items)
        if opts.key?(:default) && !opts[:default].nil? && opts[:mode] == :required
          line += ", default: #{opts[:default].inspect}"
        end
        line += ", doc: #{opts[:doc].inspect}"
        puts "> build_attr_line | line [#{line}]"
        line
      end

      def build_dsl
        @dsl = self.class.builder_store.set meta.schema_name, @template
      end

      def add_field_type_for(attr, hsh)
        if attr.type == :array
          hsh[:type] = :array
          hsh[:items] = basic_type_for attr.of
        elsif ACTIVE_MODEL_TYPES.key?(attr.type)
          hsh[:type] = ACTIVE_MODEL_TYPES[attr.type].to_s
        else
          hsh[:type] = attr.type.field_struct? ? attr.type.metadata.schema_name : nil
        end
      end

      def basic_type_for(type)
        if ACTIVE_MODEL_TYPES.key?(type)
          ACTIVE_MODEL_TYPES[type].to_s
        elsif type.field_struct?
          type.metadata.schema_name
        end
      end

      def add_field_default_for(attr, hsh)
        return if attr.default.nil?
        return if attr.default.is_a?(::Proc) || attr.default.to_s == '<proc>'

        puts "add_field_default_for | attr.default (#{attr.default.class.name}) #{attr.default.inspect}"
        hsh[:default] = attr.default
        puts "add_field_default_for | hsh[:default] (#{hsh[:default].class.name}) #{hsh[:default].inspect}"
      end

      def add_field_doc_for(attr, hsh)
        hsh[:doc] = ''
        hsh[:doc] += format('%s ', attr.description) if attr.description?
        hsh[:doc] += '| type '
        if attr.of
          hsh[:doc] += 'array:'
          hsh[:doc] += attr.of.field_struct? ? attr.of.metadata.schema_name : attr.of.to_s
        else
          hsh[:doc] += attr.type.field_struct? ? attr.type.metadata.schema_name : attr.type.to_s
        end
      end
    end
  end

  class Metadata
    def as_avro
      AvroSchema::AvroBuilder.build self
    end

    def as_avro_schema
      str = as_avro.to_s
      puts "as_avro_schema | str : #{str}"
      JSON.parse(str).deep_symbolize_keys
    end

    def to_avro_json(pretty = false)
      pretty ? JSON.pretty_generate(as_avro_schema) : as_avro_schema.to_json
    end
  end
end
