require "../visitor/array_weight_propagator"

# An object that rewrites optimization statements using normal rules in ASPIF.
class PBTranslator::Tool::OptimizationRewriter <
  PBTranslator::Tool::ASPIFBroker
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
      r = task_read { yield } && refactor && super(s) { task_write }
      task_reset
      r
    else
      super(s) { yield }
    end
  end

  def visit(c : MinimizeStatement.class, priority : Int) : Bool
    case @task
    when Task::Read
      @priority = priority
      !!yield
    else
      super(c, priority) { yield }
    end
  end

  def visit(n : WeightedLiteralListStart) : Bool
    case @task
    when Task::Read
      !!yield
    else
      super(n) { yield }
    end
  end

  def visit(l : Literal, w : Int) : Bool
    case @task
    when Task::Read
      @input_visitor.add(literal: l, weight: w)
      true
    else
      super(l, w)
    end
  end

  private def task_read
    @task = Task::Read
    !!yield
  end

  private def refactor
    @input_visitor.devour do |literals, weights|
      context = Reader::ASPIF::LogicContext.class_for(literals).new(self)
      Visitor::ArrayWeightPropagator.arrange_visit(
        FORWARD,
        network:        network_of_width(literals.size),
        gate_visitor:   Visitor::ArrayLogic.new(literals, context),
        weight_visitor: FilterVisitor.new(literals, @output_visitor),
        weights:        weights)
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
      visit(MinimizeStatement, @priority) do
        visit(WeightedLiteralListStart.new(literals.size)) do
          literals.each_with_index do |literal, i|
            visit(literal, weights[i])
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
    def initialize(@literals : Array(Literal(Int32)), @collector : WeightCollector)
    end

    def visit(*, wire, weight) : Void
      return if weight == 0
      @collector.add(literal: @literals[wire], weight: weight)
    end
  end

  private struct WeightCollector
    @literals = Array(Literal(Int32)).new
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
