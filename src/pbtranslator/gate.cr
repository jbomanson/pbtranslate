module PBTranslator

  # A gate in a network of wires.
  #
  #     a = PBTranslator::Gate.and of: {1, 2, 3}
  #     b = PBTranslator::Gate.or as: 5
  #     c = PBTranslator::Gate.comparator between: {5, 6}
  struct Gate(F, S, T)

    struct OOPLayer end

    struct And end
    struct Or end
    struct Comparator end

    struct InPlace end
    struct Input end
    struct Output end

    def self.and(*, of input_wires : T)
      Gate(And, Input, T).new(input_wires)
    end

    def self.or(*, as output_wire : I)
      Gate(Or, Input, {I}).new({output_wire})
    end

    def self.comparator(*, between wires : {I, I})
      Gate(Comparator, InPlace, {I, I}).new(wires)
    end

    getter wires

    def initialize(@wires : T)
    end

    def shifted(by amount : I)
      self.class.new(wires.map &.+ amount)
    end

  end

end
