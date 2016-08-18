module PBTranslator
  # A comparator is a gate representing a sorter of two elements.
  struct Comparator(T)
    getter wires
    @wires : {T, T}
    def initialize(i : T, j : T)
      @wires = {i, j}
    end
    def output_wires
      wires
    end
    def input_wires
      wires
    end
    def shifted(by amount : T)
      self.class.new(*wires.map &.+ amount)
    end
  end
end
