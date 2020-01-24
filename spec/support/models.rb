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
    optional :active, :boolean, default: false
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
    optional :title, :string
  end

  class Developer < Employee
    required :language, :string
  end

  class Team < FieldStruct.flexible
    extras :ignore
    required :name, :string
    required :leader, Employee
    required :members, :array, of: Employee, description: 'Team members'
  end

  class Company < FieldStruct.flexible
    required :legal_name, :string
    optional :development_team, Team
    optional :marketing_team, Team
  end
end

module ModelHelpers
  extend RSpec::Core::SharedContext

  let(:past_time) { Time.new 2019, 3, 4, 5, 6, 7 }

  let(:user_attrs) do
    {
      username: 'some_user',
      password: 'some_password',
      age: 45,
      owed: 1537.25,
      source: 'B',
      level: 2,
      at: past_time
    }
  end
end

RSpec.configure do |config|
  config.include ModelHelpers
end
