# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FieldStruct::AvroSchema::ValueConverters::CurrencyConverter do
  describe '.to_avro' do
    it 'converts amount as float to currency' do
      result = described_class.to_avro(74.99)
      expect(result).to eq(7499)
    end

    it 'converts amount as int to currency' do
      result = described_class.to_avro(75)
      expect(result).to eq(7500)
    end
  end
end
