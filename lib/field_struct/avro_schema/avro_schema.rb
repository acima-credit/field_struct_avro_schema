# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    AVRO_TYPES = {
      float: %i[float big_integer decimal currency],
      int: [:integer],
      bytes: [:binary],
      string: %i[string date datetime immutable_string time],
      boolean: [:boolean],
      array: [:array]
    }.freeze

    ACTIVE_MODEL_TYPES = {
      float: :float,
      big_integer: :float,
      decimal: :float,
      currency: :float,
      integer: :int,
      binary: :bytes,
      string: :string,
      date: :string,
      datetime: :string,
      immutable_string: :string,
      time: :string,
      boolean: :boolean,
      array: :array
    }.freeze
  end
end
require_relative 'builders/avro_builder'
require_relative 'builders/metadata_builder'
