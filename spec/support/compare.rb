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

    if act.is_a?(Hash) && exp.is_a?(Hash)
      compare_hash act, exp, prefix
    elsif act.is_a?(Array) && exp.is_a?(Array)
      compare_array act, exp, prefix
    else
      expect(act).to eq(exp),
                     "expected #{prefix} (#{act.class.name}) #{act.inspect}\n" \
                     "   to eq #{prefix} (#{exp.class.name}) #{exp.inspect}\n" \
                     'but was different'
    end
  end

  def compare_hash(act_hash, exp_hash, prefix = '')
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
end

RSpec.configure do |config|
  config.include CompareHelpers
end
