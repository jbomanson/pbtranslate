require "./base_scheme"

# An object that rewrites optimization statements using normal rules in ASPIF::Reader.
class PBTranslator::Tool::OptimizationRewriter <
  PBTranslator::ASPIF::Broker
  enum Task
    Pass
    Read
    Write
  end

  property crop_depth
  property crop_depth_unit
  property scheme
  property weight_step

  @task           = Task::Pass
  @priority       = 0
  @input_visitor  = WeightCollector.new
  @output_visitor = WeightCollector.new
  @crop_depth     = nil.as(Int32 | Nil)
  @crop_depth_unit = nil.as(Int32 | Nil)
  @weight_step    = nil.as(Int32 | Nil)
  @scheme         = BASE_SCHEME.as(Scheme::OfAnyWidth)

  def quick_dry_test : Nil
    network_of_width(1, [Int32.new(0)]).host(Visitor::Noop::INSTANCE, FORWARD)
  end

  def visit(s : Statement) : Bool
    case {@task, s}
    when {Task::Pass, Statement::Minimize}
      r = task_read { yield } && refactor && output(s) { task_write }
      task_reset
      r
    else
      output(s) { yield }
    end
  end

  def visit(c : MinimizeStatement.class, priority : Int) : Bool
    case @task
    when Task::Read
      @priority = priority
      !!yield
    else
      output(c, priority) { yield }
    end
  end

  def visit(n : WeightedLiteralListStart) : Bool
    case @task
    when Task::Read
      !!yield
    else
      output(n) { yield }
    end
  end

  def visit(l : Literal, w : Int) : Bool
    case @task
    when Task::Read
      @input_visitor.add(literal: rename(l.value.to_i32), weight: w)
      true
    else
      output(l, w)
    end
  end

  private def task_read
    @task = Task::Read
    !!yield
  end

  private def refactor
    @input_visitor.devour do |literals, weights|
      sort_by_weights(literals, weights)
      context = ASPIF::LogicContext.class_for(literals, Int32).new(self)
      g = Visitor::ArrayLogic.new(literals, context)
      w = FilterVisitor.new(literals, @output_visitor)
      v = Visitor::GateAndWeightVisitorPair.new(gate_visitor: g, weight_visitor: w)
      n = network_of_width(literals.size, weights)
      n.host(v, FORWARD)
    end
    true
  end

  private def sort_by_weights(literals, weights) : Nil
    pairs = literals.zip(weights)
    pairs.sort_by! &.last
    pairs.each_with_index do |(x, y), index|
      literals[index] = x
      weights[index] = y
    end
  end

  private struct TailoredPartiallyWireWeightedScheme(S)
    def self.new(scheme, weight_step)
      new(layer_cache_class_for(scheme).new(scheme), weight_step, overload: nil)
    end

    private def self.layer_cache_class_for(scheme)
      Scheme::LayerCache.class_for(
        scheme,
        Gate.comparator_between(Distance.zero, Distance.zero),
        depth: Distance.zero)
    end

    private def initialize(@scheme : S, @weight_step : Int32, *, overload)
    end

    def network(width : Width, *, weights)
      n = @scheme.network(width)
      y = layer_bit_array(n.network_depth)
      Network::PartiallyWireWeighted.new(network: n, weights: weights, bit_array: y)
    end

    private def layer_bit_array(depth d) : BitArray
      p = @weight_step
      BitArray.new(d.to_i).tap do |y|
        y.each_index { |i| y[i] = (i + 1) % p == 0 }
      end
    end
  end

  private struct WireWeightedScheme(S)
    def initialize(@scheme : S)
    end

    def network(width : Width, *, weights)
      n = @scheme.network(width)
      Network::WireWeighted.new(network: n, weights: weights)
    end
  end

  private def wire_weighted_scheme
    s = @scheme
    ss =
      if d = @crop_depth
        s.pbtranslator_as(Scheme::ParameterizedByDepth) do |x|
          Scheme::DepthSlice.new(
            scheme: x.with_depth,
            range_proc: depth_range_proc(d),
          )
        end
      else
        s
      end
    if p = @weight_step
      TailoredPartiallyWireWeightedScheme.new(ss, p)
    else
      WireWeightedScheme.new(ss)
    end
  end

  private def depth_range_proc(d : Int32)
    if d >= 0
      ->(width: Width, depth: Distance) {
        Distance.new(0)...Distance.new(preprocess_depth(d, depth))
      }
    else
      ->(width: Width, depth: Distance) {
        depth + Distance.new(preprocess_depth(d, depth))...depth
      }
    end
  end

  private def preprocess_depth(want : Int32, got : UInt32)
    (u = @crop_depth_unit) ? got * want / u : want
  end

  private def network_of_width(n, weights w)
    width = Width.from_value(Distance.new(n))
    s = wire_weighted_scheme
    s.network(width, weights: w)
  end

  private def task_write
    @output_visitor.devour do |literals, weights|
      @task = Task::Write
      output(MinimizeStatement, @priority) do
        output(WeightedLiteralListStart.new(literals.size)) do
          literals.each_with_index do |literal, i|
            output(literal)
            output(weights[i])
          end
        end
      end
    end
    true
  end

  private def task_reset : Nil
    @task = Task::Pass
    unless {@input_visitor, @output_visitor}.all? &.empty?
      raise "Nonempty auxiliary visitor"
    end
  end

  private struct FilterVisitor
    def initialize(@literals : Array(Literal(Util::BrokeredId(Int32))), @collector : WeightCollector)
    end

    def visit_weighted_wire(*, wire, weight) : Nil
      return if weight == 0
      @collector.add(literal: @literals[wire], weight: weight)
    end
  end

  private struct WeightCollector
    @literals = Array(Literal(Util::BrokeredId(Int32))).new
    @weights  = Array(Int32).new

    def add(*, literal, weight) : Nil
      @literals << literal
      @weights << weight
    end

    def devour
      r = yield @literals, @weights
      @literals.clear
      @weights.clear
      r
    end

    def empty?
      {@literals, @weights}.all? &.empty?
    end
  end
end
