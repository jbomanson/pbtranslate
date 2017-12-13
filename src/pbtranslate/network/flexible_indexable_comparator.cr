require "../compute_depth"
require "../gate"
require "../network"

# A network of comparator gates based on a given sequence of wire pairs.
struct PBTranslate::Network::FlexibleIndexableComparator(T)
  include Gate::Restriction
  include Network

  getter network_width : Distance
  getter wire_pairs : T
  delegate size, to: @wire_pairs

  # Constructs a new comparator network based on the given wire pairs.
  #
  # Any _width_ given here is returned by `network_width`.
  # If no network_width is specified, it is computed as the maximum wire index plus one.
  def self.new(wire_pairs : Indexable(Tuple(Distance, Distance)), *, width : Distance? = nil)
    new(wire_pairs, width: width, overload: nil)
  end

  # A convenience method to construct a new comparator network with all
  # integers given as Int32 values.
  def self.new(wire_pairs : Indexable(Tuple(Int32, Int32)), *, width : Int32? = nil)
    new(
      wire_pairs.map &.map { |index| Distance.new(index) },
      width: width.try { |value| Distance.new(value) },
      overload: nil,
    )
  end

  protected def initialize(@wire_pairs : T, *, width : Distance? = nil, overload : Nil)
    @network_width = width || (@wire_pairs.map(&.max).max + 1)
  end

  def network_read_count : Area
    Area.new(@wire_pairs.size) * 2
  end

  def network_write_count : Area
    network_read_count
  end

  # Returns the `Gate` at _index_.
  def gate_at(index) : Gate(Comparator, InPlace, Tuple(Distance, Distance))
    pair_to_gate(@wire_pairs[index])
  end

  def host_reduce(visitor, memo, at offset = Distance.new(0))
    visitor.way.each_in(@wire_pairs) do |pair|
      memo = visitor.visit_gate(pair_to_gate(pair).shifted_by(offset), memo)
    end
    memo
  end

  private def pair_to_gate(pair)
    Gate.comparator_between(*pair)
  end
end
