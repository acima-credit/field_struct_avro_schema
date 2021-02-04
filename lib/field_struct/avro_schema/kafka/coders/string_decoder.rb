# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Kafka
      class StringDecoder < BaseDecoder
        def decode
          @data
        end
      end
    end
  end
end
