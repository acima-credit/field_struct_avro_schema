# frozen_string_literal: true

#
# Shamelessly taken from:
# https://github.com/dasch/avro_turf/blob/master/lib/avro_turf/cached_confluent_schema_registry.rb
#

module FieldStruct
  module AvroSchema
    module Kafka
      class CachedSchemaRegistry
        def initialize(upstream, cache: nil)
          @upstream = upstream
          @cache = cache || InMemoryCache.new
        end

        %i[
          subjects
          subject_versions
          check
          compatible?
          global_config
          update_global_config
          subject_config
          update_subject_config
        ].each do |name|
          define_method(name) do |*args|
            instance_variable_get(:@upstream).send(name, *args)
          end
        end

        def fetch(id)
          found = @cache.lookup_by_id id
          return found if found

          pulled = @upstream.fetch id
          @cache.store_by_id id, pulled
        end

        def register(subject, schema)
          found = @cache.lookup_by_schema subject, schema
          return found if found

          registered = @upstream.register subject, schema
          @cache.store_by_schema subject, schema, registered
        end

        def subject_version(subject, version = 'latest')
          found = @cache.lookup_by_version subject, version
          return found if found

          pulled = @upstream.subject_version subject, version
          @cache.store_by_version subject, version, pulled
        end
      end
    end
  end
end
