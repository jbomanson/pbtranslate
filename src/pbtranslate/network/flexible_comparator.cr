require "../compute_depth"
require "../gate"
require "../network"

module PBTranslate::Network
  # Like the other `flexible_comparator` method but with integers given as
  # Int32 values.
  def self.flexible_comparator(
                               wire_pairs : Enumerable(Tuple(Int32, Int32)),
                               *,
                               width : Int32? = nil)
    flexible_comparator(
      wire_pairs.map &.map { |index| Distance.new(index) },
      width: width.try { |value| Distance.new(value) },
    )
  end

  # Creates a comparator network consisting of the wire pairs in a given
  # `Enumerable`.
  #
  # The network can be specified to have a *width* larger than necessary,
  # if desired.
  # By default, the least large enough width is used.
  def self.flexible_comparator(
                               wire_pairs : Enumerable(Tuple(Distance, Distance)),
                               *,
                               width : Distance? = nil)
    FlexibleComparatorNetwork.new(wire_pairs, width: width)
  end
end

private struct FlexibleComparatorNetwork(T)
  include Gate::Restriction
  include Network

  getter network_width : Distance
  getter wire_pairs : T
  delegate size, to: @wire_pairs

  def initialize(@wire_pairs : T, *, width : Distance? = nil)
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
