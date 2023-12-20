# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module ValueConverters
      class Base
        class << self
          def handles(*values)
            @values = values unless values.empty?
            @values || []
          end

          def to_avro(value, logical_type)
            new(value, logical_type).to_avro
          end

          def from_avro(value, logical_type)
            new(value, logical_type).from_avro
          end
        end

        attr_reader :value

        def initialize(value, logical_type)
          @value        = value
          @logical_type = logical_type
        end

        def to_avro
          raise 'not implemented'
        end

        def from_avro
          raise 'not implemented'
        end
      end
    end
  end
end
