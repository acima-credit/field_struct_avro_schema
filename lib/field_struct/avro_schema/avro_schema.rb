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
      date: {
        nil    => :int,
        'date' => :int
      },
      datetime: {
        nil                 => :int,
        :date               => :int,
        :'timestamp-millis' => :long,
        :'timestamp-micros' => :long
      },
      immutable_string: :string,
      time: {
        nil                 => :int,
        :date               => :int,
        :'timestamp-millis' => :long,
        :'timestamp-micros' => :long
      },
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
