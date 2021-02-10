# frozen_string_literal: true

require_relative 'karafka/serializer'
require_relative 'karafka/deserializer'

module FieldStruct
  module AvroSchema
    module Karafka
      module_function

      def serializer
        Serialization::AvroMessaging::Serializer
      end

      def deserializer
        Serialization::AvroMessaging::Deserializer
      end
    end
  end
end
