struct PBTranslate::Visitor::Going(V, W)
  include Visitor

  delegate visit_gate, to: @visitor

  def initialize(@visitor : V, way : W)
  end

  def way : Way
    W.new
  end

  def visit_region(region) : Nil
    @visitor.visit_region(region) do |region_visitor|
      yield self.class.new(region_visitor, way)
    end
  end
end

module PBTranslate::Visitor
  def going(way : Way) : Visitor
    Going.new(self, way)
  end
end
