# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    class AvroBuilder
      # This class implements a schema store that loads Avro::Builder
      # DSL files and returns Avro::Schema objects.
      # It implements the same API as Avro::Builder::SchemaStore but also
      # allows to set and persist a DSL schema from a string.
      class SchemaStore
        # @param [Pathname] path the path where DSL schemas will be stored
        def initialize(path)
          raise 'path must be a Pathname' unless path.is_a? Pathname

          ::Avro::Builder.add_load_path path.to_s
          @path = path
          @schemas = {}
        end

        # @param [String] name the name of the schema
        # @param [String] str the DSL schema
        # @param [String,nil] namespace the namespace of the schema
        # @return [Avro::Builder::DSL]
        def set(name, str, namespace = nil)
          full_name = Avro::Name.make_fullname(name, namespace)
          filename = build_schema_path(full_name)
          persist filename, str
          find full_name
        end

        # @param [String] name the name of the schema
        # @param [String,nil] namespace the namespace of the schema
        # @return [Avro::Builder::DSL]
        def find(name, namespace = nil)
          full_name = Avro::Name.make_fullname(name, namespace)

          @schemas[full_name] ||= Avro::Builder::DSL.new { eval_file(full_name) }
                                                    .as_schema.tap do |schema|
            if schema.respond_to?(:fullname) && schema.fullname != full_name
              raise SchemaError.new(schema.fullname, full_name)
            end
          end
        end

        def clear
          @schemas.keys.each { |full_name| FileUtils.rm build_schema_path(full_name) }
          @schemas = {}
        end

        private

        def persist(filename, str)
          FileUtils.mkdir_p filename.dirname
          File.open(filename, 'w') { |f| f.puts str }
        end

        def build_schema_path(full_name)
          @path.join full_name.gsub('.', '/') + '.rb'
        end
      end
    end
  end
end
