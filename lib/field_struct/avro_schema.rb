# frozen_string_literal: true

require 'pathname'
require 'zlib'

require 'active_support'

require 'excon'
require 'field_struct'
require 'avro/builder'
require 'avro_acima'

require_relative 'ext/sensitive_data'
require_relative 'avro_schema/avro_schema'
