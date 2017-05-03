require "./merging_network_helper"

module FlexibleMergeSpec
  extend self

  SCHEME =
    Scheme::FlexibleMerge.new(
      Scheme::OddEvenMerge::INSTANCE
    )

  def create_network(*args)
    SCHEME.network(args.map { |t| Width.from_value(Distance.new(t)) })
  end

  describe Scheme::FlexibleMerge do
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
