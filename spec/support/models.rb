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

  let(:person_attrs) do
    {
      first_name: 'John',
      last_name: 'Max'
    }
  end

  let(:employee_attrs) do
    person_attrs.merge title: 'VP of Engineering'
  end

  let(:developer_attrs) do
    employee_attrs.merge language: 'Haskell'
  end

  let(:leader_attrs) do
    { first_name: 'Karl', last_name: 'Marx', title: 'Team Lead' }
  end

  let(:leader2_attrs) do
    { first_name: 'Evan', last_name: 'Majors', title: 'Team Lead' }
  end

  let(:dev1_attrs) do
    { first_name: 'John', last_name: 'Stalingrad', title: 'Developer', language: 'Ruby' }
  end

  let(:dev2_attrs) do
    { first_name: 'Steve', last_name: 'Romanoff', title: 'Designer', language: 'In Design' }
  end

  let(:mke1_attrs) do
    { first_name: 'Rob', last_name: 'Morris', title: 'Developer', language: 'Javascript' }
  end

  let(:mke2_attrs) do
    { first_name: 'Zach', last_name: 'Evanoff', title: 'Designer', language: 'Photoshop' }
  end

  let(:team_attrs) do
    {
      name: 'Duper Team',
      leader: leader_attrs,
      members: [dev1_attrs, dev2_attrs]
    }
  end

  let(:mark_attrs) do
    {
      name: 'Growing Team',
      leader: leader2_attrs,
      members: [mke1_attrs, mke2_attrs]
    }
  end

  let(:company_attrs) do
    {
      legal_name: 'My Super Company',
      development_team: team_attrs,
      marketing_team: mark_attrs
    }
  end

  let(:friend_attrs) do
    {
      name: 'Carl Rovers',
      age: 45,
      balance_owed: 25.75,
      gamer_level: 2,
      zip_code: '84120'
    }
  end
end

RSpec.configure do |config|
  config.include ModelHelpers
end
