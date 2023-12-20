# frozen_string_literal: true

module ModelHelpers
  extend RSpec::Core::SharedContext

  let(:past_time) { '2019-03-04T05:06:07.891-07:00'.in_time_zone(TIME_ZONE) }

  let(:user_attrs) do
    {
      username: 'some_user',
      password: 'some_password',
      age: 45,
      source: 'B',
      level: 2,
      at: past_time,
      active: true,
      ssn: '123-45-6789',
      paycheck: BigDecimal('1234.56')
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
    employee_attrs.merge language: 'Haskell', password: 'password123!'
  end

  let(:leader_attrs) do
    { first_name: 'Karl', last_name: 'Marx', title: 'Team Lead' }
  end

  let(:leader2_attrs) do
    { first_name: 'Evan', last_name: 'Majors', title: 'Team Lead' }
  end

  let(:dev1_attrs) do
    { first_name: 'John', last_name: 'Stalingrad', title: 'Developer', language: 'Ruby', password: 'rubyroxx' }
  end

  let(:dev2_attrs) do
    { first_name: 'Steve', last_name: 'Romanoff', title: 'Designer', language: 'In Design', password: 'IHeartComputers' }
  end

  let(:mke1_attrs) do
    { first_name: 'Rob', last_name: 'Morris', title: 'Developer', language: 'Javascript', password: 'hurrdurr' }
  end

  let(:mke2_attrs) do
    { first_name: 'Zach', last_name: 'Evanoff', title: 'Designer', language: 'Photoshop', password: 'drool' }
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
      balance_owed: BigDecimal("25.75"),
      gamer_level: 2,
      zip_code: '84120'
    }
  end

  let(:runner_attrs) do
    {
      name: 'Usain Bolt',
      races_count: 150,
      address: address_attrs
    }
  end

  let(:address_attrs) do
    {
      street: '123 Fast',
      city: 'Speedy'
    }
  end

  let(:coercion_attrs) do
    {
      bare_date_field: Date.new(2023, 12, 25),
      bare_datetime_field: DateTime.new(2024, 12, 25, 6),
      bare_time_field: Time.utc(2022, 12, 25, 12, 50),
      date_to_avro_date: Date.new(1955, 11, 5),
      time_to_avro_date: Time.utc(1984, 12, 19, 10, 32),
      datetime_to_avro_date: DateTime.new(1959, 12, 19, 16, 18, 30),
      time_to_timestamp_millis: Time.utc(1996, 7, 4, 18, 30),
      datetime_to_timestamp_millis: DateTime.new(1985, 3, 17, 11, 27, 03),
      time_to_timestamp_micros: Time.utc(1981, 3, 15, 8, 17),
      datetime_to_timestamp_micros: DateTime.new(1984, 5, 9, 13, 45)
    }
  end

end

RSpec.configure do |config|
  config.include ModelHelpers
end
