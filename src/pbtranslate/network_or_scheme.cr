require "./util/type_to_value.cr"

# Either a `Network` or a `Scheme`.
#
# Both are ultimately used to obtain `Gate`s.
module PBTranslate::NetworkOrScheme
  # Returns a potentially uninitialized sample gate and a named tuple of options
  # intended for use in typeof expressions.
  #
  # See `Network#gate_with_options_for_typeof`.
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
end
