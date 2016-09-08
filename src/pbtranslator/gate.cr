module PBTranslator

  struct Gate(F, S, T)

    module Restriction

        struct OOPLayer end

        struct And end
        struct Or end
        struct Comparator end

        struct InPlace end
        struct Input end
        struct Output end

    end

    include Restriction

    def self.comparator_between(*wires)
      Gate(Comparator, InPlace, typeof(wires)).new(wires)
    end

    def self.and_of(*, tuple wires)
      Gate(And, Input, typeof(wires)).new(wires)
    end

    def self.and_of(*wires)
      and_of(tuple: wires)
    end

    def self.or_as(*wires)
      Gate(Or, Output, typeof(wires)).new(wires)
    end

    getter wires

    def initialize(@wires : T)
    end

    def shifted_by(amount)
      self.class.new(wires.map &.+ amount)
    end

    forward_missing_to wires

  end

end
