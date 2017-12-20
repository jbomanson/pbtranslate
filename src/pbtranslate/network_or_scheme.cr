require "./compile_time_set"
require "./util/type_to_value.cr"

# Either a `Network` or a `Scheme`.
#
# Both are ultimately used to obtain `Gate`s.
module PBTranslate::NetworkOrScheme
  # The set of option names used in `visit_gate` calls.
  GATE_OPTIONS = [:drop_true, :level, :output_cone]

  # Returns a potentially uninitialized sample gate and a named tuple of options
  # intended for use in typeof expressions.
  abstract def gate_with_options_for_typeof

  macro included
    macro included
      # Force the compiler to type `gate_with_options_for_typeof` for all non
      # generic networks and schemes here in order to catch problems early.
      \{% if @type.type_vars.empty? %}
        typeof(Util.type_to_value(self).gate_with_options_for_typeof)
      \{% end %}
    end
  end

  # Returns the keys in the gate options of this network or scheme as a
  # `CompileTimeSet`.
  def gate_option_keys : CompileTimeSet
    CompileTimeSet.from_named_tuple_type(
      typeof(gate_with_options_for_typeof.last)
    )
  end
end
