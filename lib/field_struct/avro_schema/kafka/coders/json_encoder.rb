# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Kafka
      class JsonEncoder < BaseEncoder
        def encode
          ActiveSupport::JSON.encode @message
        end

        private

        def prepare_message(message)
          message.respond_to?(:to_hash) ? message.to_hash : {}
        end
      end
    end
  end
end
