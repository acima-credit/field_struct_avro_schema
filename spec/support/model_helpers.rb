# frozen_string_literal: true

module ModelHelpers
  extend RSpec::Core::SharedContext

  let(:past_time) { '2019-03-04T05:06:07.891-07:00'.in_time_zone(TIME_ZONE) }

  let(:user_attrs) do
    {
      username: 'some_user',
      password: 'some_password',
      age: 45,
      owed: 1537.25,
      source: 'B',
      level: 2,
      at: past_time,
      active: true
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
