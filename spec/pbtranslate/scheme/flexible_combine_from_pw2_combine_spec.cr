require "./merging_network_helper"

module FlexibleCombineFromPw2CombineSpec
  extend self

  SCHEME = Scheme.pw2_merge_odd_even.to_scheme_flexible_combine

  def create_network(*args)
    SCHEME.network(args.map { |t| Width.from_value(Distance.new(t)) })
  end

  describe Scheme::FlexibleCombineFromPw2Combine do
    {% begin %}
      {% a = [1, 2, 3, 4, 5] %}
      {% for l in a %}
        {% for r in a %}
          it_merges({{l}}, {{r}}, Visitor::ArrayLogic) do |i, j|
            create_network(i, j)
          end
        {% end %}
      {% end %}
    {% end %}
  end
end
