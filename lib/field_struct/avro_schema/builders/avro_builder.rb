# frozen_string_literal: true

require_relative 'avro_builder/ext'

module FieldStruct
  module AvroSchema
    class AvroBuilder
      class TemplateBuilder
        def self.build(*args)
          new(*args).build
        end

        def initialize(namespace, record_options, record_name, attributes)
          @namespace = namespace
          @record_options = record_options
          @record_name = record_name
          @attributes = attributes
        end

        def build
          ary = []
          ary << "namespace '#{@namespace}'" << '' if @namespace.present?
          rec_opts = @record_options.inspect[1..-2]
          ary << "record :#{@record_name}, #{rec_opts} do"
          @attributes.each { |attr| ary << build_attr_line(attr) }
          ary << 'end'
          ary.join("\n")
        end

        private

        def build_attr_line(attr)
          ary = []
          build_attr_base_line attr, ary
          build_attr_type_line attr, ary
          build_attr_items_line attr, ary
          build_attr_default_line attr, ary
          build_attr_doc_line attr, ary
          '  ' + ary.join(', ')
        end

        def build_attr_base_line(attr, ary)
          ary << "#{attr[:mode]} :#{attr[:name]}"
        end

        def build_attr_type_line(attr, ary)
          type_parts = attr[:type].to_s.split('.')
          ary << if type_parts.size > 1
                   type_parts.join('.').inspect
                 elsif attr[:logical_type] == 'sensitive-data'
                   field_id = attr.dig(:avro, :field_id)
                   raise 'Missing field_id' unless field_id

                   "AvroBuilder::Extensions::SensitiveData.new(cache: nil, field_id: '#{field_id}')"
                 else
                   ":#{attr[:type]}"
                 end
          ary << "logical_type: #{attr[:logical_type].inspect}" if attr[:logical_type]
        end

        def build_attr_items_line(attr, ary)
          return unless attr.key? :items

          items = attr[:items]
          ary << if items.is_a?(Array)
                   "items: type(#{items.first.inspect}, logical_type: #{items.last.inspect})"
                 else
                   "items: #{attr[:items].inspect}"
                 end
        end

        def build_attr_default_line(attr, ary)
          return unless attr.key?(:default)

          default = attr[:default]
          return if default.nil? # || opts[:mode] == :required

          ary << "default: #{attr[:default].inspect}"
        end

        def build_attr_doc_line(attr, ary)
          ary << "doc: #{attr[:doc].inspect}"
        end
      end

      class << self
        def build_template(metadata)
          new(metadata).build_template
        end

        def build(metadata)
          new(metadata).build
        end

        def clean_builder_load_paths
          ::Avro::Builder::DSL.load_paths.tap do |paths|
            paths.each do |path|
              full_path = Pathname.new path
              next if full_path.exist? && full_path.directory?

              paths.delete path
            end
          end
        end
      end

      attr_reader :meta

      def initialize(meta)
        @meta = meta
      end

      def build_template
        build_namespace
        build_extras
        build_record
        build_dependencies
        build_attributes
        build_lines
      end

      def build
        build_template
        build_dsl
      end

      private

      def field_struct_klass
        @field_struct_klass ||= Object.const_get(meta.name)
      end

      def build_namespace
        parts = field_struct_klass.schema_record_name.split('.')
        @record_name = parts.pop
        @namespace = parts.join('.')
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
          mode: attr.required? ? :required : :optional,
          avro: attr.avro
        }
        add_field_type_for attr, hsh
        add_field_default_for attr, hsh
        add_field_doc_for attr, hsh
        hsh
      end

      def build_lines
        @template = TemplateBuilder.build @namespace, @record_options, @record_name, @attributes
      end

      def build_dsl
        @dsl = Kafka.builder_store.set field_struct_klass.schema_record_name, @template
      end

      def add_field_type_for(attr, hsh)
        add_array_field_type_for(attr, hsh) || add_single_field_type_for(attr, hsh)
      end

      def add_array_field_type_for(attr, hsh)
        return false unless attr.type == :array

        hsh[:type] = :array
        type = attr.of
        if (type_ary = logical_type_tuple(attr, type))
          hsh[:items] = type_ary
        elsif (type_key = ACTIVE_MODEL_TYPES[type])
          hsh[:items] = type_key.to_s
        elsif type.field_struct?
          hsh[:items] = type.schema_record_name
        end
      end

      def add_single_field_type_for(attr, hsh)
        type = attr.type
        if (type_ary = logical_type_tuple(attr, type))
          hsh[:type] = type_ary.first.to_s
          hsh[:logical_type] = type_ary.last
        elsif (type_key = ACTIVE_MODEL_TYPES[type])
          hsh[:type] = type_key.to_s
        elsif type.field_struct?
          hsh[:type] = type.schema_record_name
        end
      end

      def logical_type_tuple(attr, type)
        if !attr.avro.nil? && attr.avro.key?(:logical_type)
          [type, attr.avro[:logical_type]]
        elsif (type_ary = LOGICAL_TYPES[type])
          type_ary
        end
      end

      def add_field_default_for(attr, hsh)
        return if attr.default.nil?
        return if attr.default.is_a?(::Proc) || attr.default.to_s == '<proc>'

        hsh[:default] = attr.default
      end

      def add_field_doc_for(attr, hsh)
        hsh[:doc] = ''
        hsh[:doc] += format('%s ', attr[:description]) if attr[:description]
        hsh[:doc] += '| type '
        if attr.of
          hsh[:doc] += 'array:'
          hsh[:doc] += attr.of.field_struct? ? attr.of.schema_record_name : attr.of.to_s
        else
          hsh[:doc] += attr.type.field_struct? ? attr.type.schema_record_name : attr.type.to_s
        end
      end
    end
  end
end

FieldStruct::AvroSchema::AvroBuilder.clean_builder_load_paths
