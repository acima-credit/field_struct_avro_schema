# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module ValueConverters
      class CurrencyConverter < Base
        handles :currency

        def to_avro
          (value * 100).to_i
        end

        def from_avro
          (value / 100.0).round(2)
        end
      end

      Registry.register CurrencyConverter
    end
  end
end
