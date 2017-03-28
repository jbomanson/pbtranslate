require "../scheme"
require "./flexible_merge"

# A recursive merge sorting network parameterized by a scheme for base cases
# and a scheme for merging.
class PBTranslator::Scheme::BestSplitMergeSort(B, M)
  include Scheme

  IMBALANCE_LIMIT = Distance.new(3)

  record Details, point : Distance, cost : Area

  delegate gate_options, to: (true ? @base_scheme : @merge_scheme)

  @cache = Array(Details | Nil).new

  def self.new(merge_scheme m = FlexibleMerge.new, *, base_scheme b = m.to_base_case)
    new(base_scheme: b, merge_scheme: m, init: nil)
  end

  def initialize(*, @base_scheme : B, @merge_scheme : M, init : Nil)
  end

  def network(width : Width)
    (@base_scheme.network? width) || recursive_network(width)
  end

  private def recursive_network(width)
    w = width.value
    l = split_point(w)
    Network::DivideAndConquer.new(
      widths: widths(l, w - l),
      conquer_scheme: self,
      combine_scheme: @merge_scheme,
    )
  end

  private def split_point(w : Distance) : Distance
    details(w).point
  end

  private def details(w)
    if @base_scheme.network? Width.from_value(w)
      raise "Unintended details(#{w})"
    end
    cache_upto(w) || (@cache[w] ||= minimize(w))
  end

  private def cache_upto(w)
    c = @cache
    c.at(w) do
      c.concat(Iterator.of(nil).first(w - c.size + 1))
      nil
    end
  end

  # Finds the best way to split w wires in two nonempty halves.
  private def minimize(w : Distance) : Details
    if w <= 1
      raise ArgumentError.new("Trying to split a width of #{w}")
    end
    best = Details.new((w + 1) / 2, Area::MAX)
    best.point.upto(w - 1) do |l|
      r = w - l
      break unless l < r * IMBALANCE_LIMIT
      s = evaluate(l, r)
      next unless s < best.cost
      best = Details.new(l, s)
    end
    best
  end

  # Returns the cost of a merge sorter that merges `l + r` wires.
  private def evaluate(l, r) : Area
    sort_cost(l) + sort_cost(r) + merge_cost(l, r)
  end

  private def sort_cost(w : Distance) : Area
    n = (@base_scheme.network? Width.from_value(w))
    n ? Network.compute_gate_count(n) : details(w).cost
  end

  private def merge_cost(l : Distance, r : Distance) : Area
    Network.compute_gate_count(@merge_scheme.network(widths(l, r)))
  end

  private def widths(*args)
    args.map { |v| Width.from_value(v) }
  end
end
