# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Kafka
      class InMemoryCache
        attr_reader :schemas_by_id, :ids_by_schema, :schema_by_subject_version

        def initialize
          clear
          @logger = AvroSchema.logger
          @mock_lookup = false
        end

        def store_by_id(id, schema)
          @schemas_by_id[id] = schema
        end

        def lookup_by_id(id)
          @schemas_by_id[id]
        end

        def store_by_schema(subject, schema, id)
          key = format '%s:%s', subject, get_crc_id(schema)
          @logger.debug "F:A:K:InMemoryCache : store_by_schema | #{subject} : #{id} : #{key}"
          store_by_id id, schema
          @ids_by_schema[key] = id
        end

        def lookup_by_schema(subject, schema)
          key = format '%s:%s', subject, get_crc_id(schema)
          if @mock_lookup && !@ids_by_schema.key?(key)
            mock_id = get_crc_id(subject)
            @logger.debug "F:A:K:InMemoryCache : lookup_by_schema | #{subject} : #{key} : mocking with id ##{mock_id}"
            store_by_schema(subject, schema, mock_id)
          end

          @ids_by_schema[key].tap do |res|
            @logger.debug "F:A:K:InMemoryCache : lookup_by_schema | #{subject} : #{key} : (#{res.class.name})"
          end
        end

        def store_by_version(subject, version, schema)
          key = format '%s:%s', subject, version
          @logger.debug "F:A:K:InMemoryCache : store_by_version | #{subject} : #{version} : #{key}"
          @schema_by_subject_version[key] = schema.to_s
        end

        def lookup_by_version(subject, version)
          key = format '%s:%s', subject, version
          @schema_by_subject_version[key].tap do |res|
            @logger.debug "F:A:K:InMemoryCache : lookup_by_version | #{subject} : #{key} : (#{res.class.name})"
          end
        end

        def mock!
          @mock_lookup = true
          self
        end

        def save(path)
          data = {
            schemas_by_id: @schemas_by_id,
            ids_by_schema: @ids_by_schema,
            schema_by_subject_version: @schema_by_subject_version
          }
          File.write path, data.to_yaml
          self
        end

        def clear
          @schemas_by_id = {}
          @ids_by_schema = {}
          @schema_by_subject_version = {}
        end

        def load(path)
          data = YAML.load_file path
          @schemas_by_id = data[:schemas_by_id]
          @ids_by_schema = data[:ids_by_schema]
          @schema_by_subject_version = data[:schema_by_subject_version]
          self
        end

        def stats
          {
            schemas_by_id: @schemas_by_id.size,
            ids_by_schema: @ids_by_schema.size,
            schema_by_subject_version: @schema_by_subject_version.size
          }
        end

        def to_s
          format '#<%s schemas_by_id=%i ids_by_schema=%i schema_by_subject_version=%i>',
                 self.class.name,
                 @schemas_by_id.size,
                 @ids_by_schema.size,
                 @schema_by_subject_version.size
        end

        alias inspect to_s

        private

        def get_crc_id(schema)
          str = schema.to_s.gsub(/\s/, '')
          Zlib.crc32 str, nil
        end
      end
    end
  end
end
