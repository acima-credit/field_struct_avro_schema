# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module ValueConverters
      # time: [:long, 'timestamp-millis']
      class TimeConverter < Base
        handles :time

        def to_avro
          value.strftime('%s%3N').to_i
        end

        def from_avro
          Time.at value / 1_000.0
        end
      end

      Registry.register TimeConverter
    end
  end
end
