require "../gate_options"

module PBTranslate::Scheme
  macro delegate_and_declare_gate_options(other, *args)
    def gate_options(**extra)
      {{other.id}}.gate_options(**extra, {{args.map { |key| "#{key}: true" }.join(", ").id}}) { |o| yield o }
    end

    def gate_options(**extra)
      gate_options(**extra, &.itself)
    end
  end

  macro declare_gate_options(*args)
    def gate_options(**extra)
      yield ::PBTranslate::GateOptions.new(**extra, {{args.map { |key| "#{key}: true" }.join(", ").id}})
    end

    def gate_options(**extra)
      gate_options(**extra, &.itself)
    end
  end

  macro declare_void_gate_options
    def gate_options(*args, **options) : NoReturn
      yield raise ImpossibleError.new
      raise ImpossibleError.new
    end

    def gate_options(**extra)
      gate_options(**extra, &.itself)
    end
  end
end
