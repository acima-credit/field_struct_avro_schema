# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    ACTIVE_MODEL_TYPES = {
      float: :float,
      big_integer: :float,
      decimal: :float,
      currency: :int,
      integer: :int,
      binary: :bytes,
      string: :string,
      date: :int,
      datetime: :long,
      immutable_string: :string,
      time: :long,
      boolean: :boolean,
      array: :array
    }.with_indifferent_access.freeze

    def self.logger
      @logger ||= Logger.new($stdout).tap { |x| x.level = Logger::INFO }
    end

    def self.logger=(value)
      @logger = value
    end
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
