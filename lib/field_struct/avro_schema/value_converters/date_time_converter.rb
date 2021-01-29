# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module ValueConverters
      # datetime: [:long, 'timestamp-millis'],
      class DateTimeConverter < TimeConverter
        handles :datetime

        def from_avro
          return value if value.is_a?(DateTime)

          super.to_datetime
        end
      end

      Registry.register DateTimeConverter
    end
  end
end
