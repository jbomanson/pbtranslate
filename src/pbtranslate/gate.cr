require "./number_types"

struct PBTranslate::Gate(F, S, T)
  module Function
  end

  module Form
  end

  module Restriction
    struct Layer
      getter level : Distance

      def initialize(@level : Distance)
      end
    end

    struct OOPSublayer
    end

    struct Passthrough
      extend Function
    end

    struct And
      extend Function
    end

    struct Or
      extend Function
    end

    struct Comparator
      extend Function
    end

    struct InPlace
      extend Form
    end

    struct Input
      extend Form
    end

    struct Output
      extend Form
    end
  end

  include Restriction

  def self.passthrough_at(*wire : Distance)
    Gate(Passthrough, InPlace, typeof(wire)).new(wire)
  end

  def self.comparator_between(*wires : Distance)
    Gate(Comparator, InPlace, typeof(wires)).new(wires)
  end

  def self.and_of(*, tuple wires)
    Gate(And, Input, typeof(wires)).new(wires)
  end

  def self.and_of(*wires : Distance)
    and_of(tuple: wires)
  end

  def self.or_as(*wires : Distance)
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
