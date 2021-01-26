# frozen_string_literal: true

module Examples
  class User < FieldStruct.flexible
    required :username, :string, format: /\A[a-z]/i, description: 'login'
    optional :password, :string
    required :age, :integer
    required :owed, :currency, description: 'amount owed to the company'
    required :source, :string, enum: %w[A B C]
    required :level, :integer, default: -> { 2 }
    optional :at, :time
    required :active, :boolean, default: false
  end

  class Person < FieldStruct.flexible
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
  end

  class Team < FieldStruct.flexible
    extras :ignore
    required :name, :string
    required :leader, Employee
    required :members, :array, of: Developer, description: 'Team members'
  end

  class Company < FieldStruct.flexible
    required :legal_name, :string
    optional :development_team, Team
    optional :marketing_team, Team
  end
end

module ExampleApp
  module Examples
    class Friend < FieldStruct.flexible
      required :name, :string
      optional :age, :integer
      optional :balance_owed, :currency, default: 0.0
      optional :gamer_level, :integer, enum: [1, 2, 3], default: -> { 1 }
      optional :zip_code, :string, format: /\A[0-9]{5}?\z/

      def topic_key
        format '%s', name
      end
    end
  end
end
