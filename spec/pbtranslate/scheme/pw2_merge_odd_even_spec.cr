require "../../bidirectional_host_helper"
require "./merging_network_helper"

private module Private
  SCHEME = Scheme.pw2_merge_odd_even
end

describe Scheme::Pw2MergeOddEven do
  [1, 2, 4, 8, 16, 32].each do |half_width|
    it_merges(
      half_width,
      half_width,
      Visitor::ArrayLogic,
      Private::SCHEME.network(Width.from_pw2(Distance.new(half_width)))
    )

    BidirectionalHostHelper.it_works_predictably_in_reverse ->{
      Private::SCHEME.network(Width.from_pw2(Distance.new(half_width)))
    }
  end
end
