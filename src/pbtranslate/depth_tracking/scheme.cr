require "../depth_tracking"
require "../scheme"

module PBTranslate::Scheme
  # Converts this scheme into one that has the gate option _depth_.
  #
  # Calls to this method on schemes that already have the gate option should be
  # caught by the compiler, but the error message will not necessarily be nice.
  # To verify that a scheme does not have the gate option in a way that results
  # in potentially nicer error messages, use
  # `scheme.gate_options.restrict(depth: nil)`.
  #
  # See `GateOptions#restrict`.
  def to_scheme_with_gate_depth_added
    DepthTracking::Scheme.new(self)
  end

  # Converts this scheme into one that has the gate option _depth_, if needed.
  def to_scheme_with_gate_depth
    to_scheme_with_gate_depth &.to_scheme_with_gate_depth_added
  end

  # Yields this scheme to a block that must return a scheme with the gate
  # option _depth_, or returns this scheme as is without yielding anything if
  # this scheme already has that gate option.
  #
  # The return value of the block is statically checked to have the gate option
  # _depth_.
  # In the case that this scheme is yielded to the block, it is statically
  # checked to not already have the gate option _depth_.
  def to_scheme_with_gate_depth
    s = to_scheme_with_gate_depth_helper(**gate_options.named_tuple) { |x| yield x.tap &.gate_options.restrict(depth: nil) }
    s.tap &.gate_options.restrict(depth: true)
  end

  private def to_scheme_with_gate_depth_helper(*empty_args, depth : Bool, **options, &block)
    self
  end

  private def to_scheme_with_gate_depth_helper(*empty_args, depth : Nil, **options)
    yield self
  end

  private def to_scheme_with_gate_depth_helper(*empty_args, depth : Bool | Nil, **options, &block)
    {{ raise "Ambiguity error: depth is and is not provided by #{@type}" }}
  end

  private def to_scheme_with_gate_depth_helper(*empty_args, **options)
    yield self
  end
end
