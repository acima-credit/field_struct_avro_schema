# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Kafka
      class JsonDecoder < BaseDecoder
        def decode
          return false unless @data[0, 1] == '{'

          ActiveSupport::JSON.decode @data
          # JSON.parse @data, symbolize_names: false
        end
      end
    end
  end
end
