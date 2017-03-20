require "../depth_tracking"
require "../gate_options"

module PBTranslator::GateOptions::Module
  def with_depth
    s = with_depth_helper(**gate_options.named_tuple)
    s.tap &.gate_options.restrict(depth: true)
  end

  private def with_depth_helper(**options, depth : Bool)
    self
  end

  private def with_depth_helper(**options, depth : Nil)
    DepthTracking::Scheme.new(self)
  end

  private def with_depth_helper(**options, depth : Bool | Nil)
    {{ raise "Ambiguity error: depth is and is not provided by #{@type}" }}
  end

  private def with_depth_helper(**options)
    DepthTracking::Scheme.new(self)
  end
end
