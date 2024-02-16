# frozen_string_literal: true

require 'uri'

module FieldStruct
  module AvroSchema
    class Configuration
      attr_accessor :user_name, :password, :schema_registry_url, :automatic_schema_registration

      def initialize
        @user_name = env_or_default('KAFKA_SCHEMA_REGISTRY_USERNAME', nil)
        @password = env_or_default('KAFKA_SCHEMA_REGISTRY_PASSWORD', nil)
        @schema_registry_url = env_or_default('KAFKA_SCHEMA_REGISTRY_URL', 'http://localhost:8081')
        @automatic_schema_registration = env_or_default('KAFKA_AUTO_REGISTER_SCHEMAS', 'false') == 'true'
      end

      def schema_registry_base_url
        uri = URI(schema_registry_url)
        uri.path = ''
        uri.query = nil
        uri.to_s
      end

      def schema_registry_path_prefix
        uri = URI(schema_registry_url)
        uri.path
      end

      private

      def env_or_default(name, default_value)
        value = ENV.fetch(name, nil)
        value = default_value if value.blank?
        value
      end
    end
  end
end
