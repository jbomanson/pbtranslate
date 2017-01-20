# A network of comparator gates based on a given sequence of wire pairs.
struct PBTranslator::Network::IndexableComparator(T)
  include Gate::Restriction

  getter width : Distance
  getter wire_pairs : T
  delegate size, to: @wire_pairs

  # Constructs a new comparator network based on the given wire pairs.
  #
  # Any _width_ given here is returned by `width`.
  # If no width is specified, it is computed as the maximum wire index plus one.
  def self.new(wire_pairs : Indexable(Tuple(Distance, Distance)), *, width : Distance? = nil)
    new(wire_pairs, width: width, init: nil)
  end

  protected def initialize(@wire_pairs : T, *, width : Distance? = nil, init : Nil)
    @width = width || (@wire_pairs.map(&.max).max + 1)
  end

  # Returns the `Gate` at _index_.
  def gate_at(index) : Gate(Comparator, InPlace, Tuple(Distance, Distance))
    pair_to_gate(@wire_pairs[index])
  end

  def host(visitor, way : Way, at offset = Distance.new(0)) : Nil
    way.each_in(@wire_pairs) do |pair|
      visitor.visit_gate(pair_to_gate(pair).shifted_by(offset))
    end
  end

  private def pair_to_gate(pair)
    Gate.comparator_between(*pair)
  end
end
