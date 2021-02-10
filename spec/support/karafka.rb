# frozen_string_literal: true

module Karafka
  module Errors
    BaseError = Class.new(StandardError)
    SerializationError = Class.new(BaseError)
    DeserializationError = Class.new(BaseError)
  end
end

require 'field_struct/avro_schema/karafka'
