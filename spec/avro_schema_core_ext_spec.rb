# frozen_string_literal: true

require 'spec_helper'

RSpec.describe String do
  describe '#as_avro' do
    it { expect(str.as_avro).to eq str }
  end
end

RSpec.describe Numeric do
  describe '#as_avro' do
    it { expect(int.as_avro).to eq int }
    it { expect(flt.as_avro).to eq flt }
    it { expect(bdec.as_avro).to eq bdec }
  end
end

RSpec.describe Enumerable do
  describe '#as_avro' do
    it { expect(ary.as_avro).to eq ary }
  end
end

RSpec.describe Hash do
  describe '#as_avro' do
    it { expect(hsh.as_avro).to eq hsh }
  end
end

RSpec.describe Time do
  describe '#as_avro' do
    it { expect(time.as_avro).to eq '2019-01-02T03:04:05-07:00' }
  end
end

RSpec.describe Date do
  describe '#as_avro' do
    it { expect(date.as_avro).to eq '2019-01-02' }
  end
end

RSpec.describe Symbol do
  describe '#as_avro' do
    it { expect(sym.as_avro).to eq 'sym' }
  end
end

RSpec.describe NilClass do
  describe '#as_avro' do
    it { expect(null.as_avro).to eq null }
  end
end

RSpec.describe TrueClass do
  describe '#as_avro' do
    it { expect(yes.as_avro).to eq yes }
  end
end

RSpec.describe FalseClass do
  describe '#as_avro' do
    it { expect(no.as_avro).to eq no }
  end
end

#  expected: {:bdec=>0.3456e1, :flt=>3.15, :int=>3, :str=>"string"}
#       got: {"bdec"=>0.3456e1, "flt"=>3.15, "int"=>3, "str"=>"string"}
