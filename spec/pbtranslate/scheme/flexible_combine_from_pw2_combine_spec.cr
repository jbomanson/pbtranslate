require "./merging_network_helper"

private SCHEME = Scheme.pw2_merge_odd_even.to_scheme_flexible_combine

private def wrap(*args)
  args.map { |t| Width.from_value(Distance.new(t)) }
end

describe Scheme::FlexibleCombineFromPw2Combine do
  a = [1, 2, 3, 4, 5]
  a.each do |left|
    a.each do |right|
      it_merges(
        left,
        right,
        Visitor::ArrayLogic,
        SCHEME.network(wrap(left, right)),
      )
    end
  end
end
