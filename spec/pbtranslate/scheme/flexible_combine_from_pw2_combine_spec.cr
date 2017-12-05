require "./merging_network_helper"

module FlexibleCombineFromPw2CombineSpec
  extend self

  SCHEME =
    Scheme::FlexibleCombineFromPw2Combine.new(
      Scheme::Pw2MergeOddEven::INSTANCE
    )

  def create_network(*args)
    SCHEME.network(args.map { |t| Width.from_value(Distance.new(t)) })
  end

  describe Scheme::FlexibleCombineFromPw2Combine do
    {% begin %}
      {% a = [1, 2, 3, 4, 5] %}
      {% for l in a %}
        {% for r in a %}
          it_merges({{l}}, {{r}}, Visitor::ArrayLogic.new, create_network)
        {% end %}
      {% end %}
    {% end %}
  end
end
