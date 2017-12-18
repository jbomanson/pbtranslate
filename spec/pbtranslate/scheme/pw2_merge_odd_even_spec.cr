require "./merging_network_helper"

private SCHEME = Scheme.pw2_merge_odd_even

private def create_network(i, j)
  SCHEME.network(Width.from_pw2(Distance.new(i)))
end

describe Scheme::Pw2MergeOddEven do
  [1, 2, 4, 8, 16, 32].each do |half_width|
    it_merges(half_width, half_width, Visitor::ArrayLogic) do |i, j|
      create_network(i, j)
    end
  end
end
