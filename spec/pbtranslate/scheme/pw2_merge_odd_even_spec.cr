require "./merging_network_helper"

module Pw2MergeOddEvenSpec
  extend self

  SCHEME = Scheme.pw2_merge_odd_even

  def create_network(i, j)
    SCHEME.network(Width.from_pw2(Distance.new(i)))
  end

  describe Scheme::Pw2MergeOddEven do
    {% begin %}
      {% a = [1, 2, 4, 8, 16, 32] %}
      {% for l in a %}
        it_merges({{l}}, {{l}}, Visitor::ArrayLogic.new, create_network)
      {% end %}
    {% end %}
  end
end
