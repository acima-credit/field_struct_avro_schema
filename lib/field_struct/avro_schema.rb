# frozen_string_literal: true

require 'pathname'
require 'zlib'

require 'active_support'

require 'excon'
require 'field_struct'
require 'avro/builder'

require_relative 'avro_schema/avro_schema'
