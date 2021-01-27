# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module ValueConverters
      # date: [:int, 'date']
      class DateConverter < Base
        handles :date

        THRESHOLD = Date.new(1970, 1, 1)

        def to_avro
          (value - THRESHOLD).to_i
        end

        def from_avro
          THRESHOLD + 1
        end
      end

      Registry.register DateConverter
    end
  end
end
