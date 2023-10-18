# frozen_string_literal: true

# This is an AvroBuilder type that permits serializing sensitive-data schema elements
module AvroBuilder
  module Extensions
    class SensitiveData < Avro::Builder::Types::Type
      dsl_attributes(:field_id)

      def initialize(cache: nil, field: nil, field_id: nil)
        @logical_type = 'sensitive-data'
        @abstract = true
        @field_id = field_id
        super('string', field: field, cache: cache)
      end

      def serialize(reference_state, _overrides: {})
        super(reference_state, overrides: serialized_attributes)
      end

      def to_h(reference_state, _overrides: {})
        super(reference_state, overrides: serialized_attributes)
      end

      def validate!
        super
        validate_required_attribute!(:field_id)
      end

      private

      def serialized_attributes
        { fieldId: @field_id }
      end
    end
  end
end
