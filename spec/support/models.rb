# frozen_string_literal: true

module Examples
  class Base < FieldStruct.flexible
    # include FieldStruct::AvroExtension
    include FieldStruct::AvroSchema::Event

    publishable false

    def self.default_schema_naming_strategy
      :topic_name
    end
  end

  class User < Base
    topic_key :username

    required :username, :string, format: /\A[a-z]/i, description: 'login'
    optional :password, :string
    required :age, :integer
    required :source, :string, enum: %w[A B C]
    required :level, :integer, default: -> { 2 }
    optional :at, :time, avro: { logical_type: 'timestamp-millis' }
    required :active, :boolean, default: false
    optional :ssn, :string, avro: { logical_type: 'sensitive-data', field_id: 'social_security_number' }
    required :paycheck, :binary, avro: { logical_type: 'decimal', precision: 6, scale: 2 }
  end

  class Person < Base
    topic_key :full_name

    required :first_name, :string, length: 3..20
    required :last_name, :string

    def full_name
      [first_name, last_name].select(&:present?).join(' ')
    end
  end

  class Employee < Person
    extras :add
    optional :title, :string, default: -> { 'Staff' }
  end

  class Developer < Employee
    required :language, :string
    required :password, :string, avro: { logical_type: 'sensitive-data', field_id: 'dev_pw' }
  end

  class Team < Base
    topic_key :name

    extras :ignore
    required :name, :string
    required :leader, Employee
    required :members, :array, of: Developer, description: 'Team members'
  end

  class Company < Base
    topic_key :legal_name

    required :legal_name, :string
    optional :development_team, Team
    optional :marketing_team, Team
  end
end

module CustomNamespace
  class CustomRecordName < Examples::Base
    topic_key :last_name
    schema_record_name('custom.record')

    required :first_name, :string
    required :last_name, :string
  end
end

module ExampleApp
  module Examples
    class Friend < FieldStruct.flexible
      include FieldStruct::AvroSchema::Event
      topic_key :name

      required :name, :string
      optional :age, :integer
      optional :balance_owed, :currency, default: 0.0
      optional :balance_owed_d, :binary, avro: { logical_type: 'decimal', precision: 8, scale: 2 }, default: 0.0
      optional :gamer_level, :integer, enum: [1, 2, 3], default: -> { 1 }
      optional :zip_code, :string, format: /\A[0-9]{5}?\z/
    end

    class Stranger < FieldStruct.flexible
      required :name, :string
      optional :age, :integer
    end
  end
end

module PublishableApp
  module Examples
    class Address < FieldStruct.flexible
      include FieldStruct::AvroSchema::Event
      publishable false

      required :street, :string
      required :city, :string
    end

    class Runner < FieldStruct.flexible
      include FieldStruct::AvroSchema::Event
      topic_key :name

      required :name, :string
      required :races_count, :integer
      required :address, Address
    end
  end
end

module Coercions
  module Examples
    class TestStruct < FieldStruct.flexible
      include FieldStruct::AvroSchema::Event
      publishable false

      required :bare_date_field, :date
      required :bare_datetime_field, :datetime
      required :bare_time_field, :time
      required :date_to_avro_date, :date, avro: { logical_type: 'date' }
      required :time_to_avro_date, :time, avro: { logical_type: 'date' }
      required :datetime_to_avro_date, :datetime, avro: { logical_type: 'date' }
      required :time_to_timestamp_millis, :time, avro: { logical_type: 'timestamp-millis' }
      required :datetime_to_timestamp_millis, :datetime, avro: { logical_type: 'timestamp-millis' }
      required :time_to_timestamp_micros, :time, avro: { logical_type: 'timestamp-micros' }
      required :datetime_to_timestamp_micros, :datetime, avro: { logical_type: 'timestamp-micros' }
    end
  end
end
