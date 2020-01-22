# frozen_string_literal: true

class String
  def as_avro
    self
  end
end

class Numeric
  def as_avro
    self
  end
end

module Enumerable
  def as_avro
    map(&:as_avro)
  end
end

class Hash
  def as_avro
    hsh = {}
    each { |k, v| hsh[k.as_avro] = v.as_avro }
    hsh
  end
end

class Time
  def as_avro
    iso8601
  end
end

class Date
  def as_avro
    iso8601
  end
end

class Symbol
  def as_avro
    to_s
  end
end

class NilClass
  def as_avro
    self
  end
end

class TrueClass
  def as_avro
    self
  end
end

class FalseClass
  def as_avro
    self
  end
end
