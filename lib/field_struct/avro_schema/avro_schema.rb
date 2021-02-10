# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    AVRO_TYPES = {
      float: %i[float big_integer decimal],
      int: %i[integer currency],
      bytes: [:binary],
      string: %i[string date datetime immutable_string time],
      boolean: [:boolean],
      array: [:array]
    }.with_indifferent_access.freeze

    ACTIVE_MODEL_TYPES = {
      float: :float,
      big_integer: :float,
      decimal: :float,
      currency: :int,
      integer: :int,
      binary: :bytes,
      string: :string,
      date: :int,
      datetime: :int,
      immutable_string: :string,
      time: :int,
      boolean: :boolean,
      array: :array
    }.with_indifferent_access.freeze

    LOGICAL_TYPES = {
      date: [:int, 'date'],
      datetime: [:long, 'timestamp-millis'],
      time: [:long, 'timestamp-millis']
    }.with_indifferent_access.freeze
  end
end

require_relative 'version'
require_relative 'kafka'
require_relative 'builders/avro_builder'
require_relative 'builders/metadata_builder'
require_relative 'converters'
require_relative 'extension'
require_relative 'event'
require_relative 'karafka' if defined?(Karafka)
