# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Kafka
      class BaseEncoder
        def self.encode(*args, **kwargs)
          new(*args, **kwargs).encode
        end

        def initialize(message, *_args, **kwargs)
          @message = prepare_message message
        end

        def encode
          raise 'not implemented'
        end

        def prepare_message(_message)
          raise 'not implemented'
        end
      end
    end
  end
end
