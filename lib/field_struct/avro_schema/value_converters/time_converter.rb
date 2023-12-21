# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module ValueConverters
      # time: [:long, 'timestamp-millis']
      class TimeConverter < Base
        handles :time

        EPOCH = Date.new(1970, 1, 1)

        def to_avro
          case @logical_type
          when nil, 'date'
            (value.utc.to_date - EPOCH).to_i
          when 'timestamp-millis'
            value.utc.strftime('%s%3N').to_i
          when 'timestamp-micros'
            value.utc.strftime('%s%6N').to_i
          end
        end

        def from_avro
          return value if value.is_a?(Time)

          case @logical_type
          when nil, 'date'
            Time.use_zone('UTC') { Time.zone.at(value * 86400) }
          when 'timestamp-millis'
            Time.use_zone('UTC') { Time.zone.at value / 1_000.0 }
          when 'timestamp-micros'
            Time.use_zone('UTC') { Time.zone.at value / 1_000_000.0 }
          end
        end
      end

      Registry.register TimeConverter
    end
  end
end
