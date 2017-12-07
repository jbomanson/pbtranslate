require "./flexible_combine_from_pw2_combine"
require "../network/compute_gate_count"
require "../network/divide_and_conquer"
require "../scheme"

# A recursive command and conquer network scheme that uses dynamic programming
# to determine good network structure, while relying on given schemes for base
# cases and combination operations to build networks.
# Conquer actions are implemented using either a scheme of type *Q* or this
# scheme recursively.
# Combination actions are implemented using a scheme of type *M*.
#
# For any given input width, this scheme will find a good way to split the
# input into two parts that are conquered separately and then combined.
# Conquering is based on the given base case scheme or recursion.
# Combination is delegated to the given combine scheme.
#
# The base case scheme must provide a *network?* method with a single `Width`
# argument and the combine scheme must provide a *network* method with a pair
# of `Width` arguments.
class PBTranslate::Scheme::FlexibleDivideAndConquerDynamicProgramming(M, Q)
  include Scheme

  # A limit on the ratio of sizes of parts that are considered when splitting.
  # Lower values lead to lower computation time at the risk of missing some
  # good ways of arranging network structure.
  IMBALANCE_LIMIT = Distance.new(3)

  # :nodoc:
  record Details, point : Distance, cost : Area

  delegate gate_options, to: (true ? @base_scheme : @combine_scheme)

  @cache = Array(Details | Nil).new

  # Creates a scheme that depends on the given schemes.
  def self.new(combine_scheme m = FlexibleCombineFromPw2Combine.new, *, base_scheme b = m.to_base_case)
    new(base_scheme: b, combine_scheme: m, overload: nil)
  end

  # :nodoc:
  def initialize(*, @base_scheme : Q, @combine_scheme : M, overload : Nil)
  end

  # Generates a network of the given *width* as described in
  # `FlexibleDivideAndConquerDynamicProgramming`.
  def network(width : Width)
    (@base_scheme.network? width) || recursive_network(width)
  end

  private def recursive_network(width)
    w = width.value
    l = split_point(w)
    Network::DivideAndConquer.new(
      widths: widths(l, w - l),
      conquer_scheme: self,
      combine_scheme: @combine_scheme,
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

  # Returns the cost to conquer and combine `l + r` wires.
  private def evaluate(l, r) : Area
    conquer_cost(l) + conquer_cost(r) + combine_cost(l, r)
  end

  private def conquer_cost(w : Distance) : Area
    n = (@base_scheme.network? Width.from_value(w))
    n ? Network.compute_gate_count(n) : details(w).cost
  end

  private def combine_cost(l : Distance, r : Distance) : Area
    Network.compute_gate_count(@combine_scheme.network(widths(l, r)))
  end

  private def widths(*args)
    args.map { |v| Width.from_value(v) }
  end
end
