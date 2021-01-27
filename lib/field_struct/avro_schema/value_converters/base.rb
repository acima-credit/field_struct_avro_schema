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

          def to_avro(value)
            new(value).to_avro
          end

          def from_avro(value)
            new(value).from_avro
          end
        end

        attr_reader :value

        def initialize(value)
          @value = value
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
