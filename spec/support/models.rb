# frozen_string_literal: true

module Examples
  class Base < FieldStruct.flexible
    include FieldStruct::AvroExtension
  end

  class User < Base
    required :username, :string, format: /\A[a-z]/i, description: 'login'
    optional :password, :string
    required :age, :integer
    required :owed, :currency, description: 'amount owed to the company'
    required :source, :string, enum: %w[A B C]
    required :level, :integer, default: -> { 2 }
    optional :at, :time
    required :active, :boolean, default: false
  end

  class Person < Base
    include FieldStruct::AvroExtension

    required :first_name, :string, length: 3..20
    required :last_name, :string

    def full_name
      [first_name, last_name].select(&:present?).join(' ')
    end
  end

  class Employee < Person
    include FieldStruct::AvroExtension

    extras :add
    optional :title, :string, default: -> { 'Staff' }
  end

  class Developer < Employee
    include FieldStruct::AvroExtension

    required :language, :string
  end

  class Team < Base
    include FieldStruct::AvroExtension

    extras :ignore
    required :name, :string
    required :leader, Employee
    required :members, :array, of: Developer, description: 'Team members'
  end

  class Company < Base
    include FieldStruct::AvroExtension

    required :legal_name, :string
    optional :development_team, Team
    optional :marketing_team, Team
  end
end

module ExampleApp
  module Examples
    class Friend < FieldStruct.flexible
      include FieldStruct::AvroExtension

      required :name, :string
      optional :age, :integer
      optional :balance_owed, :currency, default: 0.0
      optional :gamer_level, :integer, enum: [1, 2, 3], default: -> { 1 }
      optional :zip_code, :string, format: /\A[0-9]{5}?\z/

      def topic_key
        format '%s', name
      end
    end

    class Stranger < FieldStruct.flexible
      required :name, :string
      optional :age, :integer
    end
  end
end
