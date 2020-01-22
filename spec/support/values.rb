# frozen_string_literal: true

module ValueHelpers
  extend RSpec::Core::SharedContext
  let(:str) { 'string' }
  let(:int) { 3 }
  let(:flt) { 3.15 }
  let(:bdec) { BigDecimal '3.456' }
  let(:ary) { [str, int, flt, bdec] }
  let(:hsh) { { 'str' => str, 'int' => int, 'flt' => flt, 'bdec' => bdec } }
  let(:time) { Time.new 2019, 1, 2, 3, 4, 5 }
  let(:date) { time.to_date }
  let(:sym) { :sym }
  let(:null) { nil }
  let(:yes) { true }
  let(:no) { false }
end

RSpec.configure do |config|
  config.include ValueHelpers
end
