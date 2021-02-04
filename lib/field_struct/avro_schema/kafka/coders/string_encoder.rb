# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Kafka
      class StringEncoder < BaseEncoder
        def encode
          @message
        end

        private

        def prepare_message(message)
          message.to_s
        end
      end
    end
  end
end
