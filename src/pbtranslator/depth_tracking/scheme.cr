require "../depth_tracking"
require "../scheme"

module PBTranslator::Scheme
  # Converts this scheme into one that has the gate option _depth_.
  def with_gate_depth_added
    DepthTracking::Scheme.new(self)
  end

  # Converts this scheme into one that has the gate option _depth_, if needed.
  def with_gate_depth
    with_gate_depth &.with_gate_depth_added
  end

  # Returns this scheme object if it has the gate option _depth_ and
  # otherwise yields it.
  #
  # The block must return a scheme has the gate option _depth_.
  def with_gate_depth
    s = with_gate_depth_helper(**gate_options.named_tuple) { |x| yield x.tap &.gate_options.restrict(depth: nil) }
    s.tap &.gate_options.restrict(depth: true)
  end

  private def with_gate_depth_helper(**options, depth : Bool, &block)
    self
  end

  private def with_gate_depth_helper(**options, depth : Nil)
    yield self
  end

  private def with_gate_depth_helper(**options, depth : Bool | Nil, &block)
    {{ raise "Ambiguity error: depth is and is not provided by #{@type}" }}
  end

  private def with_gate_depth_helper(**options)
    yield self
  end
end
