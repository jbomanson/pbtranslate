module PBTranslator

  module Gate::Restriction

      struct OOPLayer end

      struct Plain end
      struct And end
      struct Or end
      struct Comparator end

      struct InPlace end
      struct Input end
      struct Output end

  end

  module Gate
    extend self
    include Restriction

    def shift(f, s, wires, by amount)
      {f, s, shift(wires, by: amount)}
    end

    def shift(wires, by amount)
      wires.map &.+ amount
    end

  end

end
