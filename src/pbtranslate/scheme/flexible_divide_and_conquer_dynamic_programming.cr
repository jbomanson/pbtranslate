require "./flexible_combine_from_pw2_combine"
require "../network/compute_gate"
require "../network/divide_and_conquer"
require "../scheme"

# :nodoc:
class PBTranslate::Scheme::FlexibleDivideAndConquerDynamicProgramming(M, Q)
  include Scheme
  include Scheme::WithArguments(Width::Flexible)
  include Gate::Restriction

  module ::PBTranslate::Scheme
    # Creates a divide and conquer scheme that uses dynamic programming
    # to determine good network structure.
    # Conquer actions are implemented using either the given *base_scheme* or
    # the created scheme recursively.
    # Combination actions are implemented using this scheme.
    #
    # For any given input width, the created scheme will find a good way to
    # split the input into two parts that are conquered separately and then
    # combined.
    # Conquering is based on the given base case scheme or recursion.
    # Combination is delegated to the given combine scheme.
    #
    # The given *base_scheme* must provide a *network?* method with a single
    # `Width` argument and the this scheme must provide a *network* method with
    # a pair of `Width` arguments.
    def to_scheme_flexible_divide_and_conquer_dynamic_programming(base_scheme = to_base_case) : Scheme
      FlexibleDivideAndConquerDynamicProgramming.new(self, base_scheme)
    end
  end

  # Hard coded costs for supported gate functions.
  FUNCTION_NAME_COSTS = {
    Comparator.name  => Area.new(1),
    Passthrough.name => Area.new(0),
  }

  def_scheme_children @combine_scheme, @base_scheme

  # A limit on the ratio of sizes of parts that are considered when splitting.
  # Lower values lead to lower computation time at the risk of missing some
  # good ways of arranging network structure.
  property imbalance_limit = 3.0

  # A limit on the lesser popcount of parts that are considered when splitting.
  # This must be at least 1.
  # Lower values lead to lower computation time at the risk of missing some
  # good ways of arranging network structure.
  property popcount_limit = 64

  # :nodoc:
  property cache : Array(Details | Nil)

  # :nodoc:
  record Details, point : Distance, cost : Area

  @cache = Array(Details | Nil).new

  def initialize(@combine_scheme : M, @base_scheme : Q)
  end

  def network(width : Width)
    (@base_scheme.network? width) || recursive_network(width)
  end

  def tune_generate(io)
    io.puts
    io.puts "def Scheme.tune" +
            "(scheme : #{self.class.name.gsub(":Module", ".class")}) : Nil"
    io.puts "  scheme.cache ="
    io.puts "    ["
    @cache.each do |details|
      io.puts(
        if details
          "      #{details.class}.new" +
          "(#{details.point.inspect}, #{details.cost.inspect}),"
        else
          "      nil,"
        end
      )
    end
    io.puts "    ]"
    io.puts "end"
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
    l = (w + 1) / 2
    best = Details.new(l, evaluate(l, w - l))
    (l + 1).upto(w - 1) do |l|
      r = w - l
      next unless consider?(l, r)
      s = evaluate(l, r)
      next unless s < best.cost
      best = Details.new(l, s)
    end
    best
  end

  # Heuristically determines whether to try to split a number of wires into
  # parts of the given sizes.
  private def consider?(l, r) : Bool
    l < r.to_f * imbalance_limit && {l, r}.map(&.popcount).min <= popcount_limit
  end

  # Returns the cost to conquer and combine `l + r` wires.
  private def evaluate(l, r) : Area
    conquer_cost(l) + conquer_cost(r) + combine_cost(l, r)
  end

  private def conquer_cost(w : Distance) : Area
    n = (@base_scheme.network? Width.from_value(w))
    n ? n.compute_gate_cost(FUNCTION_NAME_COSTS) : details(w).cost
  end

  private def combine_cost(l : Distance, r : Distance) : Area
    @combine_scheme
      .network(widths(l, r))
      .compute_gate_cost(FUNCTION_NAME_COSTS)
  end

  private def widths(*args)
    args.map { |v| Width.from_value(v) }
  end
end
