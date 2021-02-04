# frozen_string_literal: true

# This class implements a schema store that loads Avro::Builder
# DSL files and returns Avro::Schema objects.
# It implements the same API as Avro::Builder::SchemaStore but also
# allows to set and persist a DSL schema from a string and keep entries
# in memory only if desired.

module FieldStruct
  module AvroSchema
    module Kafka
      class SchemaStore
        class Entry
          attr_reader :full_name, :filename, :str, :schema

          def initialize(full_name, filename, str, schema)
            @full_name = full_name
            @filename = filename
            @str = str
            @schema = schema

            check_name_mismatch
          end

          def check_name_mismatch
            return unless schema.respond_to?(:fullname) && schema.fullname != full_name

            raise ::Avro::Builder::SchemaError.new(schema.fullname, full_name)
          end

          def to_s
            format '#<%s full_name=%s filename=%s>',
                   self.class.name,
                   @full_name.inspect,
                   @filename.inspect
          end

          alias inspect to_s
        end

        attr_reader :path, :schemas

        def initialize(path = nil)
          raise 'path must be a Pathname' if !path.nil? && !path.is_a?(Pathname)

          ::Avro::Builder.add_load_path(path.to_s) unless path.nil?
          @path = path
          @schemas = {}
        end

        def get_by_full_name(name)
          schemas[name]
        end

        def get_by_filename(name)
          schemas.values.find { |x| x.filename == name }
        end

        def set(name, str, namespace = nil)
          full_name = Avro::Name.make_fullname(name, namespace)
          persist full_name, str

          add_entry_from_str(full_name, str).schema
        end

        def find(name, namespace = nil)
          full_name = Avro::Name.make_fullname(name, namespace)
          found = get_by_full_name full_name
          return found.schema if found

          add_entry_from_file(full_name).schema
        end

        def clear
          schemas = {}
          return if path.nil?

          schemas.keys.each { |full_name| FileUtils.rm build_schema_path(full_name) }
        end

        def to_s
          format '#<%s path=%s schemas=%i>',
                 self.class.name,
                 @path.inspect,
                 @schemas.size
        end

        alias inspect to_s

        private

        def persist(full_name, str)
          return false if path.nil?

          filename = build_schema_path full_name
          FileUtils.mkdir_p filename.dirname
          File.write filename, str
          true
        end

        def build_schema_path(full_name)
          schema_path = full_name.tr('.', '/') + '.rb'
          return Pathname.new(schema_path) unless path

          path.join(schema_path)
        end

        def add_entry_from_file(full_name)
          filename = build_schema_path full_name
          add_entry_from_str full_name, File.read(filename)
        end

        def add_entry_from_str(full_name, str)
          filename = build_schema_path(full_name).to_s
          schema = ::Avro::Builder::DSL.new(str).as_schema
          entry = Entry.new(full_name, filename, str, schema)
          schemas[full_name] = entry
          entry
        end
      end
    end
  end
end
