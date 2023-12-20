# frozen_string_literal: true

RSpec.describe Coercions::Examples::TestStruct do
  subject { described_class.metadata }
  let(:exp_hash) do
    {
      name: "Coercions::Examples::TestStruct",
      schema_name: "coercions.examples.test_struct",
      version: "a6cdd95f",
      attributes: {
        bare_date_field: { type: :date, required: true },
        bare_datetime_field: { type: :datetime, required: true },
        bare_time_field: { type: :time, required: true },
        date_to_avro_date: { type: :date, required: true, avro: { logical_type: "date" } },
        time_to_avro_date: { type: :time, required: true, avro: { logical_type: "date" } },
        datetime_to_avro_date: { type: :datetime, required: true, avro: { logical_type: "date" } },
        time_to_timestamp_millis: { type: :time, required: true, avro: { logical_type: "timestamp-millis" } },
        datetime_to_timestamp_millis: { type: :datetime, required: true, avro: { logical_type: "timestamp-millis" } },
        time_to_timestamp_micros: { type: :time, required: true, avro: { logical_type: "timestamp-micros" } },
        datetime_to_timestamp_micros: { type: :datetime, required: true, avro: { logical_type: "timestamp-micros" } }
      }
    }
  end
  let(:exp_template) do
    <<~CODE.chomp
      namespace 'coercions.examples'

      record :test_struct, :doc=>"| version a6cdd95f" do
        required :bare_date_field, :int, doc: "| type date"
        required :bare_datetime_field, :int, doc: "| type datetime"
        required :bare_time_field, :int, doc: "| type time"
        required :date_to_avro_date, :int, logical_type: "date", doc: "| type date"
        required :time_to_avro_date, :int, logical_type: "date", doc: "| type time"
        required :datetime_to_avro_date, :int, logical_type: "date", doc: "| type datetime"
        required :time_to_timestamp_millis, :long, logical_type: "timestamp-millis", doc: "| type time"
        required :datetime_to_timestamp_millis, :long, logical_type: "timestamp-millis", doc: "| type datetime"
        required :time_to_timestamp_micros, :long, logical_type: "timestamp-micros", doc: "| type time"
        required :datetime_to_timestamp_micros, :long, logical_type: "timestamp-micros", doc: "| type datetime"
      end
    CODE
  end
  let(:exp_schema) do
    {
      type: "record",
      name: "test_struct",
      namespace: "coercions.examples",
      doc: "| version a6cdd95f",
      fields: [
        { name: "bare_date_field", type: "int", doc: "| type date" },
        { name: "bare_datetime_field", type: "int", doc: "| type datetime" },
        { name: "bare_time_field", type: "int", doc: "| type time" },
        { name: "date_to_avro_date", type: { type: "int", logicalType: "date" }, doc: "| type date" },
        { name: "time_to_avro_date", type: { type: "int", logicalType: "date" }, doc: "| type time" },
        { name: "datetime_to_avro_date", type: { type: "int", logicalType: "date" }, doc: "| type datetime" },
        { name: "time_to_timestamp_millis", type: { type: "long", logicalType: "timestamp-millis" }, doc: "| type time" },
        { name: "datetime_to_timestamp_millis", type: { type: "long", logicalType: "timestamp-millis" }, doc: "| type datetime" },
        { name: "time_to_timestamp_micros", type: { type: "long", logicalType: "timestamp-micros" }, doc: "| type time" },
        { name: "datetime_to_timestamp_micros", type: { type: "long", logicalType: "timestamp-micros" }, doc: "| type datetime" }
      ]
    }
  end
  let(:exp_json) do
    <<~JSON.chomp
      {
        "type": "record",
        "name": "test_struct",
        "namespace": "coercions.examples",
        "doc": "| version a6cdd95f",
        "fields": [
          {
            "name": "bare_date_field",
            "type": "int",
            "doc": "| type date"
          },
          {
            "name": "bare_datetime_field",
            "type": "int",
            "doc": "| type datetime"
          },
          {
            "name": "bare_time_field",
            "type": "int",
            "doc": "| type time"
          },
          {
            "name": "date_to_avro_date",
            "type": {
              "type": "int",
              "logicalType": "date"
            },
            "doc": "| type date"
          },
          {
            "name": "time_to_avro_date",
            "type": {
              "type": "int",
              "logicalType": "date"
            },
            "doc": "| type time"
          },
          {
            "name": "datetime_to_avro_date",
            "type": {
              "type": "int",
              "logicalType": "date"
            },
            "doc": "| type datetime"
          },
          {
            "name": "time_to_timestamp_millis",
            "type": {
              "type": "long",
              "logicalType": "timestamp-millis"
            },
            "doc": "| type time"
          },
          {
            "name": "datetime_to_timestamp_millis",
            "type": {
              "type": "long",
              "logicalType": "timestamp-millis"
            },
            "doc": "| type datetime"
          },
          {
            "name": "time_to_timestamp_micros",
            "type": {
              "type": "long",
              "logicalType": "timestamp-micros"
            },
            "doc": "| type time"
          },
          {
            "name": "datetime_to_timestamp_micros",
            "type": {
              "type": "long",
              "logicalType": "timestamp-micros"
            },
            "doc": "| type datetime"
          }
        ]
      }
    JSON
  end
  let(:exp_version_meta) do
    [
      {
        name: "Schemas::Coercions::Examples::TestStruct::Va6cdd95f",
        schema_name: "schemas.coercions.examples.test_struct.va6cdd95f",
        version: "a6cdd95f",
        attributes: {
          bare_date_field: { type: :date, required: true },
          bare_datetime_field: { type: :datetime, required: true },
          bare_time_field: { type: :time, required: true },
          date_to_avro_date: { type: :date, required: true },
          time_to_avro_date: { type: :time, required: true },
          datetime_to_avro_date: { type: :datetime, required: true },
          time_to_timestamp_millis: { type: :time, required: true },
          datetime_to_timestamp_millis: { type: :datetime, required: true },
          time_to_timestamp_micros: { type: :time, required: true },
          datetime_to_timestamp_micros: { type: :datetime, required: true }
        }
      }
    ]
  end

  let(:act_hash) { subject.to_hash }
  let(:act_template) { subject.as_avro_template }
  let(:act_avro) { subject.as_avro_schema }
  let(:blt_meta) { FieldStruct::Metadata.from_avro_schema act_avro }
  let(:blt_klas) { FieldStruct.from_metadata blt_meta.last }

  it('matches') { compare act_hash, exp_hash }

  context 'to Avro' do
    it('#as_avro_template') { compare act_template, exp_template }
    it('#as_avro_schema') { compare act_avro, exp_schema }
    it('#to_avro_json') { compare subject.to_avro_json, exp_schema.to_json }
  end

  context 'from Avro' do
    it 'builds a valid metadata array' do
      expect { blt_meta }.to_not raise_error
      expect(blt_meta).to be_a Array
      expect(blt_meta.size).to eq 1
      expect(blt_meta.first).to be_a FieldStruct::Metadata
      compare blt_meta.map(&:to_hash), exp_version_meta
    end
  end

  context 'to and from Avro' do
    let(:original) { described_class.new coercion_attrs }
    let(:clone) { blt_klas.new coercion_attrs }
    it 'works' do
      expect { original }.to_not raise_error

      expect(original).to be_valid
      expect(original.bare_date_field).to eq Date.new(2023, 12, 25)
      expect(original.bare_datetime_field).to eq DateTime.new(2024, 12, 25, 6)
      expect(original.bare_time_field).to eq Time.utc(2022, 12, 25, 12, 50)
      expect(original.date_to_avro_date).to eq Date.new(1955, 11, 5)
      expect(original.time_to_avro_date).to eq Time.utc(1984, 12, 19, 10, 32)
      expect(original.datetime_to_avro_date).to eq DateTime.new(1959, 12, 19, 16, 18, 30)
      expect(original.time_to_timestamp_millis).to eq Time.utc(1996, 7, 4, 18, 30)
      expect(original.datetime_to_timestamp_millis).to eq DateTime.new(1985, 3, 17, 11, 27, 03)
      expect(original.time_to_timestamp_micros).to eq Time.utc(1981, 3, 15, 8, 17)
      expect(original.datetime_to_timestamp_micros).to eq DateTime.new(1984, 5, 9, 13, 45)

      expect { blt_klas }.to_not raise_error

      expect { clone }.to_not raise_error

      expect(clone).to be_valid
      expect(clone.bare_date_field).to eq Date.new(2023, 12, 25)
      expect(clone.bare_datetime_field).to eq DateTime.new(2024, 12, 25, 6)
      expect(clone.bare_time_field).to eq Time.utc(2022, 12, 25, 12, 50)
      expect(clone.date_to_avro_date).to eq Date.new(1955, 11, 5)
      expect(clone.time_to_avro_date).to eq Time.utc(1984, 12, 19, 10, 32)
      expect(clone.datetime_to_avro_date).to eq DateTime.new(1959, 12, 19, 16, 18, 30)
      expect(clone.time_to_timestamp_millis).to eq Time.utc(1996, 7, 4, 18, 30)
      expect(clone.datetime_to_timestamp_millis).to eq DateTime.new(1985, 3, 17, 11, 27, 03)
      expect(clone.time_to_timestamp_micros).to eq Time.utc(1981, 3, 15, 8, 17)
      expect(clone.datetime_to_timestamp_micros).to eq DateTime.new(1984, 5, 9, 13, 45)
    end
  end

  context 'to Avro hash' do
    let(:instance) { described_class.new coercion_attrs }
    let(:act_hash) { instance.to_avro_hash }
    let(:cloned_attrs) { described_class.convert_avro_attributes act_hash }
    let(:cloned) { described_class.from_avro_hash act_hash }
    let(:cloned_hsh) { cloned.to_hash.deep_symbolize_keys }
    let(:exp_avro_hsh) do
      {
        bare_date_field: 19716,
        bare_datetime_field: 20082,
        bare_time_field: 19351,
        date_to_avro_date: -5171,
        time_to_avro_date: 5466,
        datetime_to_avro_date: -3666,
        time_to_timestamp_millis: 836505000000,
        datetime_to_timestamp_millis: 479906823000,
        time_to_timestamp_micros: 353492220000000,
        datetime_to_timestamp_micros: 452958300000000,
      }
    end
    let(:exp_hsh) do
      # 'Larger' types that are coerced to 'smaller' types will lose information.
      # i.e. If you encode a Time like this '2024-12-25T12:06:30' as an avro
      # date, then when you deserialize your struct will contain a Time(2024, 12, 25)
      # instance and you'll lose the HMS information.
      {
        bare_date_field: Date.new(2023, 12, 25),
        bare_datetime_field: DateTime.new(2024, 12, 25),
        bare_time_field: Time.utc(2022, 12, 25),
        date_to_avro_date: Date.new(1955, 11, 5),
        time_to_avro_date: Time.utc(1984, 12, 19),
        datetime_to_avro_date: DateTime.new(1959, 12, 19),
        time_to_timestamp_millis: Time.utc(1996, 7, 4, 18, 30),
        datetime_to_timestamp_millis: DateTime.new(1985, 3, 17, 11, 27, 03),
        time_to_timestamp_micros: Time.utc(1981, 3, 15, 8, 17),
        datetime_to_timestamp_micros: DateTime.new(1984, 5, 9, 13, 45)
      }
    end
    it('#to_avro_hash') { compare instance.to_avro_hash, exp_avro_hsh }
    it('.convert_avro_attributes') do
      expect { cloned_attrs }.to_not raise_error
      expect(cloned_attrs).to be_a Hash
      compare cloned_attrs, exp_hsh
    end
    it('.from_avro_hash') do
      expect { cloned }.to_not raise_error
      expect(cloned).to be_a described_class
      expect(cloned).to be_valid
      compare cloned_hsh, exp_hsh
    end
  end

end
