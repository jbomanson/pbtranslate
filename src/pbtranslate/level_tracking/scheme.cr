require "../compile_time_set"
require "../level_tracking"
require "../scheme"

module PBTranslate::Scheme
  # Converts this scheme into one that has the gate option _level_.
  def to_scheme_with_gate_level_added
    LevelTracking::Scheme.new(self)
  end

  # Converts this scheme into one that has the gate option _level_, if needed.
  def to_scheme_with_gate_level
    to_scheme_with_gate_level &.to_scheme_with_gate_level_added
  end

  # Yields this scheme to a block that must return a scheme with the gate
  # option _depth_, or returns this scheme as is without yielding anything if
  # this scheme already has that gate option.
  #
  # The return value of the block is statically checked to have the gate option
  # _depth_.
  # In the case that this scheme is yielded to the block, it is statically
  # checked to not already have the gate option _level_.
  def to_scheme_with_gate_level
    scheme_with_level =
      to_scheme_with_gate_level_helper(**gate_options.named_tuple) do |scheme|
        (scheme.gate_option_keys & CompileTimeSet.create(:level)).empty!
        yield scheme
      end
    scheme_with_level.gate_option_keys.superset! CompileTimeSet.create(:level)
    scheme_with_level
  end

  private def to_scheme_with_gate_level_helper(*empty_args, level : Bool, **options, &block)
    self
  end

  private def to_scheme_with_gate_level_helper(*empty_args, level : Nil, **options)
    yield self
  end

  private def to_scheme_with_gate_level_helper(*empty_args, level : Bool | Nil, **options, &block)
    {{ raise "Ambiguity error: depth is and is not provided by #{@type}" }}
  end

  private def to_scheme_with_gate_level_helper(*empty_args, **options)
    yield self
  end
end
