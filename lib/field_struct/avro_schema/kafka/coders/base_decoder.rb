# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Kafka
      class BaseDecoder
        def self.decode(*args, **kwargs)
          new(*args, **kwargs).decode
        end

        def initialize(payload, *_args, **kwargs)
          @data = payload.to_s
        end

        def decode
          raise 'not implemented'
        end
      end
    end
  end
end
