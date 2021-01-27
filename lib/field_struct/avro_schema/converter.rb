# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    class Converter
      attr_reader :instance, :metadata

      def initialize(instance)
        @instance = instance
        @metadata = metadata
      end
    end
  end
end
