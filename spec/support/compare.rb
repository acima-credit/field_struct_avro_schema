# frozen_string_literal: true

module CompareHelpers
  def compare(act, exp, prefix = '')
    if ENV.fetch('DEBUG', 'false') == 'true' && prefix == ''
      puts ' [ actual ] '.center(60, '-')
      puts act.to_yaml
      puts ' [ expected ] '.center(60, '-')
      puts exp.to_yaml
      puts ' [ done ] '.center(60, '-')
    end

    compare_hash(act, exp, prefix) ||
      compare_array(act, exp, prefix) ||
      compare_array(act, exp, prefix) ||
      compare_single_date(act, exp, prefix) ||
      compare_single_datetime(act, exp, prefix) ||
      compare_single_time(act, exp, prefix) ||
      compare_single_other(act, exp, prefix)
  end

  def compare_hash(act_hash, exp_hash, prefix = '')
    return false unless act_hash.is_a?(Hash) && exp_hash.is_a?(Hash)

    act_hash.keys.each do |k|
      act = act_hash[k]
      exp = exp_hash[k]
      compare act, exp, "#{prefix}[#{k}]"
    end
    expect(act_hash.keys.sort).to eq(exp_hash.keys.sort),
                                  "expected actual keys #{prefix} #{act_hash.keys.inspect}\n" \
                                  "          to eq keys #{prefix} #{exp_hash.keys.inspect}\n" \
                                  'but were different'
  end

  def compare_array(act_ary, exp_ary, prefix = '')
    return false unless act_ary.is_a?(Array) && exp_ary.is_a?(Array)

    act_ary.each_index do |idx|
      act_val = act_ary[idx]
      exp_val = exp_ary[idx]
      compare act_val, exp_val, "#{prefix}[#{idx}]"
    end
    expect(act_ary.size).to eq(exp_ary.size),
                            "expected actual size #{prefix} #{act_ary.size}\n" \
                            "          to eq size #{prefix} #{exp_ary.size}\n" \
                            'but was different'
  end

  def compare_single_date(act, exp, prefix)
    compare_single_instance(act, exp, prefix, DateTime, &:iso8601)
  end

  def compare_single_datetime(act, exp, prefix)
    compare_single_instance(act, exp, prefix, DateTime) { |x| x.iso8601(3) }
  end

  def compare_single_time(act, exp, prefix)
    compare_single_instance(act, exp, prefix, Time) { |x| x.iso8601(3) }
  end

  def compare_single_other(act, exp, prefix)
    compare_single_instance(act, exp, prefix, Object) { |x| x }
  end

  def compare_single_instance(act, exp, prefix, klass)
    return unless act.is_a?(klass) && exp.is_a?(klass)
    raise 'missing block' unless block_given?

    act_cnv = yield act
    exp_cnv = yield exp
    expect(act_cnv).to eq(exp_cnv),
                       "[#{klass}] expected #{prefix} (#{act.class.name}) #{act_cnv.inspect}\n" \
                     "[#{klass}]    to eq #{prefix} (#{exp.class.name}) #{exp_cnv.inspect}\n" \
                     'but was different'
  end
end

RSpec.configure do |config|
  config.include CompareHelpers
end
