require "../depth_tracking"
require "../gate_options"

module PBTranslator::GateOptions::Module
  # Converts this scheme into one that has the gate option _depth_.
  def with_depth_added
    DepthTracking::Scheme.new(self)
  end

  # Converts this scheme into one that has the gate option _depth_, if needed.
  def with_depth
    s = with_depth_helper(**gate_options.named_tuple)
    s.tap &.gate_options.restrict(depth: true)
  end

  private def with_depth_helper(**options, depth : Bool)
    self
  end

  private def with_depth_helper(**options, depth : Nil)
    with_depth_added
  end

  private def with_depth_helper(**options, depth : Bool | Nil)
    {{ raise "Ambiguity error: depth is and is not provided by #{@type}" }}
  end

  private def with_depth_helper(**options)
    with_depth_added
  end

  # Returns this scheme object if it has the gate option _depth_ and
  # otherwise yields it.
  #
  # The block must return a scheme has the gate option _depth_.
  def with_depth
    s = with_depth_helper(**gate_options.named_tuple) { |x| yield x.tap &.gate_options.restrict(depth: nil) }
    s.tap &.gate_options.restrict(depth: true)
  end

  private def with_depth_helper(**options, depth : Bool, &block)
    self
  end

  private def with_depth_helper(**options, depth : Nil)
    yield self
  end

  private def with_depth_helper(**options, depth : Bool | Nil, &block)
    {{ raise "Ambiguity error: depth is and is not provided by #{@type}" }}
  end

  private def with_depth_helper(**options)
    yield self
  end
end
