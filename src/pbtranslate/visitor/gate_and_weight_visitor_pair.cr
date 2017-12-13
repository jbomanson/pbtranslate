struct PBTranslate::Visitor::GateAndWeightVisitorPair(G, W)
  include Visitor

  delegate way, to: @gate_visitor

  def initialize(*, @gate_visitor : G, @weight_visitor : W)
  end

  def visit_gate(g, memo, *empty_args, input_weights = Tuple.new, output_weights = Tuple.new, **options)
    e = g.wires
    v = @weight_visitor
    input_weights.zip(e) do |weight, wire|
      memo = v.visit_weighted_wire(weight: weight, wire: wire, memo: memo)
    end
    memo = @gate_visitor.visit_gate(g, memo, **options)
    output_weights.zip(e) do |weight, wire|
      memo = v.visit_weighted_wire(weight: weight, wire: wire, memo: memo)
    end
    memo
  end

  def visit_region(region) : Nil
    @gate_visitor.visit_region(region) do |region_visitor|
      yield self.class.new(
        gate_visitor: region_visitor,
        weight_visitor: @weight_visitor)
    end
  end
end
