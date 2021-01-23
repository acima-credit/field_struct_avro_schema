# frozen_string_literal: true

# We monkey-patch these methods to allow for searching the schema store we built first
# so we can catch the cached definitions and then search the load paths for real files,

module Avro
  module Builder
    module FileHandler
      def read_file(name)
        found = schema_store.get_by_filename(name)
        return found.str if found

        File.read(find_file(name))
      end

      def find_file(name)
        found = schema_store.get_by_full_name(name)
        return found.filename if found

        file_name = "/#{name.to_s.tr('.', '/').sub(%r{^/}, '').sub(/\.rb$/, '')}.rb"
        matches = real_load_paths.flat_map do |load_path|
          Dir["#{load_path}/**/*.rb"].select do |file_path|
            file_path.end_with?(file_name)
          end
        end.uniq
        raise "Multiple matches: #{matches}" if matches.size > 1
        raise FileNotFoundError.new("File not found #{file_name}") if matches.empty?

        matches.first
      end

      private

      def schema_store
        FieldStruct::AvroSchema::AvroBuilder.builder_store
      end
    end

    class DSL
      private

      def eval_file(name)
        file_path = if namespace
                      begin
                        find_file([namespace, name].join('.'))
                      rescue FileNotFoundError
                        find_file(name)
                      end
                    else
                      find_file(name)
                    end
        str = read_file file_path
        instance_eval(str, file_path)
      end
    end
  end
end
