require "./network/gates_with_options"
require "./visitor"
require "./visitor/default_methods"

module PBTranslate::Network
  # Returns a tuple containing a gate and a named tuple of options intended for
  # use in typeof expressions only.
  def gate_with_options_for_typeof
    host_reduce(GateWithOptionsForTypeof.new, nil).not_nil!
  end

  private struct GateWithOptionsForTypeof
    include Visitor
    include Visitor::DefaultMethods

    def visit_gate(gate, memo, **options)
      memo || {gate, options}
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
