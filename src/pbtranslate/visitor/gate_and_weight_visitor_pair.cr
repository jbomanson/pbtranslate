struct PBTranslate::Visitor::GateAndWeightVisitorPair(G, W)
  include Visitor

  delegate way, to: @gate_visitor

  def initialize(*, @gate_visitor : G, @weight_visitor : W)
  end

  def visit_gate(g, *empty_args, input_weights = Tuple.new, output_weights = Tuple.new, **options) : Nil
    e = g.wires
    v = @weight_visitor
    input_weights.zip(e) do |weight, wire|
      v.visit_weighted_wire(weight: weight, wire: wire)
    end
    @gate_visitor.visit_gate(g, **options)
    output_weights.zip(e) do |weight, wire|
      v.visit_weighted_wire(weight: weight, wire: wire)
    end
  end

  def visit_region(region) : Nil
    @gate_visitor.visit_region(region) do |region_visitor|
      yield self.class.new(
        gate_visitor: region_visitor,
        weight_visitor: @weight_visitor)
    end
  end
end
