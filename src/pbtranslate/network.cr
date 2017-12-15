require "./gate_options"
require "./network/gates_with_options"
require "./network_or_scheme"
require "./util/restrict"
require "./visitor"
require "./visitor/default_methods"

module PBTranslate::Network
  include NetworkOrScheme

  # Returns a tuple containing a gate and a named tuple of options intended for
  # use in typeof expressions only.
  def gate_with_options_for_typeof
    host_reduce(GateWithOptionsForTypeof.new, nil).not_nil!
  end

  private struct GateWithOptionsForTypeof
    include Visitor
    include Visitor::DefaultMethods

    def visit_gate(gate, memo, **options)
      result = memo || {gate, options}
      check_integrity(result.last)
      result
    end

    # Check to make sure that each gate option is either guaranteed to be
    # present or guaranteed to be absent.
    def check_integrity(options : NamedTuple)
      {% for option in GATE_OPTIONS %}
        Util.restrict_not_nilable_union(options[{{option}}]?)
      {% end %}
    end

    def visit_gate(gate, memo, **options)
      visit_gate(gate, yield(self), **options)
    end
  end

  def host(visitor) : Nil
    host_check_nothing(host_reduce(visitor, Nothing.new))
  end

  private def host_check_nothing(nothing : Nothing) : Nil
  end

  private def host_check_nothing(something : U) forall U
    {{ raise "Expected Nothing, got #{U}" }}
  end

  private record Nothing

  abstract def host_reduce(visitor, memo)
end
