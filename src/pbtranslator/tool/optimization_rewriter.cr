# An object that rewrites optimization statements using normal rules in ASPIF::Reader.
class PBTranslator::Tool::OptimizationRewriter <
  PBTranslator::ASPIF::Broker
  enum Task
    Pass
    Read
    Write
  end

  property crop_depth

  @task           = Task::Pass
  @priority       = 0
  @input_visitor  = WeightCollector.new
  @output_visitor = WeightCollector.new
  @crop_depth     = nil.as(Int32?)

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
      context = ASPIF::LogicContext.class_for(literals, Int32).new(self)
      g = Visitor::ArrayLogic.new(literals, context)
      w = FilterVisitor.new(literals, @output_visitor)
      v = Network::WireWeighted.pair(gate_visitor: g, weight_visitor: w)
      n = network_of_width(literals.size)
      nn = Network::WireWeighted.new(network: n, weights: weights)
      nn.host(v, FORWARD)
    end
    true
  end

  private def network_of_width(n)
    s =
      Scheme::MergeSort::Recursive.new(
        Scheme::OEMerge::INSTANCE
      )
    d = @crop_depth
    ss =
      if d
        if d.not_nil! >= 0
          Scheme::DepthSlice.new(
            scheme: DepthTracking::Scheme.new(s),
            range_proc: ->(width: Width::Pw2(Int32), depth: Int32) {
              0...d.not_nil!
            },
          )
        else
          Scheme::DepthSlice.new(
            scheme: DepthTracking::Scheme.new(s),
            range_proc: ->(width: Width::Pw2(Int32), depth: Int32) {
              depth + d.not_nil!...depth
            },
          )
        end
      else
        s
      end
    sss = Scheme::WidthLimited.new(ss)
    sss.network(Width.from_value(n))
  end

  private def task_write
    @output_visitor.devour do |literals, weights|
      @task = Task::Write
      output(MinimizeStatement, @priority) do
        output(WeightedLiteralListStart.new(literals.size)) do
          literals.each_with_index do |literal, i|
            output(literal, weights[i])
          end
        end
      end
    end
    true
  end

  private def task_reset : Void
    @task = Task::Pass
    unless {@input_visitor, @output_visitor}.all? &.empty?
      raise "Nonempty auxiliary visitor"
    end
  end

  private struct FilterVisitor
    def initialize(@literals : Array(Literal(Util::BrokeredId(Int32))), @collector : WeightCollector)
    end

    def visit_weighted_wire(*, wire, weight) : Void
      return if weight == 0
      @collector.add(literal: @literals[wire], weight: weight)
    end
  end

  private struct WeightCollector
    @literals = Array(Literal(Util::BrokeredId(Int32))).new
    @weights  = Array(Int32).new

    def add(*, literal, weight) : Void
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
