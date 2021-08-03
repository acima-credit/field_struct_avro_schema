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
          @logger = AvroSchema.logger
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
          @logger.debug "F:A:K:CachedSchemaRegistry : fetch | #{id} : found : (#{found.class.name})"
          return found if found

          pulled = @upstream.fetch id
          @logger.debug "F:A:K:CachedSchemaRegistry : fetch | #{id} : pulled : (#{found.class.name})"
          @cache.store_by_id id, pulled
        end

        def register(subject, schema)
          @logger.debug 'F:A:K:CachedSchemaRegistry : register | ' \
                        "#{subject} : (#{schema.class.name}) #{subject&.size || 'n/a'}"
          found = @cache.lookup_by_schema subject, schema
          @logger.debug "F:A:K:CachedSchemaRegistry : register | #{subject} : found : (#{found.class.name})"
          return found if found

          registered = @upstream.register subject, schema
          @logger.debug "F:A:K:CachedSchemaRegistry : register | #{subject} : registered : (#{registered.class.name})"
          @cache.store_by_schema subject, schema, registered
        end

        def subject_version(subject, version = 'latest')
          found = @cache.lookup_by_version subject, version
          @logger.debug 'F:A:K:CachedSchemaRegistry : subject_version | ' \
                        "#{subject} : #{version} : found (#{found.class.name})"
          return found if found

          pulled = @upstream.subject_version subject, version
          @logger.debug 'F:A:K:CachedSchemaRegistry : subject_version | ' \
                        "#{subject} : #{version} : pulled (#{pulled.class.name})"
          @cache.store_by_version subject, version, pulled
        end

        def to_s
          format '#<%s upstream=%s cache=%s>',
                 self.class.name,
                 @upstream.inspect,
                 @cache.inspect
        end

        alias inspect to_s
      end
    end
  end
end
