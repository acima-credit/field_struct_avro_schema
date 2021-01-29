# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module ValueConverters
      # time: [:long, 'timestamp-millis']
      class TimeConverter < Base
        handles :time

        def to_avro
          value.utc.strftime('%s%3N').to_i
        end

        def from_avro
          return value if value.is_a?(Time)

          Time.use_zone('UTC') { Time.zone.at value / 1_000.0 }
        end
      end

      Registry.register TimeConverter
    end
  end
end
