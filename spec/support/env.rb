# frozen_string_literal: true

require 'rspec/core/shared_context'

module EnvHelpers
  def change_env(name, new_value)
    return false unless block_given?

    name      = name.to_s.upcase
    old_value = ENV[name]
    ENV[name] = new_value

    res = yield

    ENV[name] = old_value
    res
  end

  def change_env_set(set)
    return false unless block_given?

    previous = {}
    set.each do |name, value|
      new_name           = name.to_s.upcase
      previous[new_name] = ENV[new_name]
      if value.nil?
        ENV.delete new_name
      else
        ENV[new_name] = value.to_s
      end
    end

    res = yield

    previous.each do |name, value|
      ENV[name] = value
    end

    res
  end

  def change_argv_set(*entries)
    return false unless block_given?

    previous = ARGV.map(&:to_s)
    ARGV.clear
    entries.each_with_index { |value, idx| ARGV[idx] = value }

    res = yield

    ARGV.clear
    previous.each_with_index { |value, idx| ARGV[idx] = value }

    res
  end

  extend RSpec::Core::SharedContext

  let(:argv) { [] }

  let(:env) { {} }
end

RSpec.configure do |config|
  config.include EnvHelpers
  config.around(:example, env_change: true) { |example| change_env_set(env) { example.run } }
end
