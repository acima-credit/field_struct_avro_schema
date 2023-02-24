# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Kafka
      class BaseDecoder
        def self.decode(*args)
          new(*args).decode
        end

        def initialize(payload, *_args)
          @data = payload.to_s
        end

        def decode
          raise 'not implemented'
        end
      end
    end
  end
end
