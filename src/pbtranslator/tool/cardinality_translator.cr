require "../visitor/array_logic"

# An object that translates cardinality rules into normal rules in ASPIF.
class PBTranslator::Tool::CardinalityTranslator <
    PBTranslator::Tool::ASPIFBroker
    
  @in_weight_rule = false
  @lower_bound = 0
  @literals = Array(Literal(Int32)).new
  @weights = Array(Int32).new
  @delegate_to_super = false

  def visit(b : Body, lower_bound : Int) : Bool
    if @delegate_to_super
      super(b, lower_bound) { yield }
    else
      unless Body::Weight == b
        raise "Strange Body #{b}"
      end
      @in_weight_rule = true
      @lower_bound = lower_bound
      r = !!yield
      if r
        r = revisit
        @in_weight_rule = false
        @literals.clear
        @weights.clear
      end
      r
    end
  end

  def visit(n : WeightedLiteralListStart) : Bool
    if @delegate_to_super || !@in_weight_rule
      super(n) { yield }
    else
      !!yield
    end
  end
  
  def visit(l : Literal, w : Int) : Bool
    if @delegate_to_super || !@in_weight_rule
      super
    else
      @literals << Literal.new(l.value.to_i32)
      @weights << w.to_i32
      true
    end
  end

  protected def revisit : Bool
    @delegate_to_super = true
    r =
      if @weights.all? &.==(1)
        translate_cardinality
        comment_end_of_translation
      else
        output_weight_rule
      end
    @delegate_to_super = false
    r
  end

  protected def translate_cardinality
    check_delegate_to_super

    b = self
    # Complete the unfinished rule with ...
    if @lower_bound <= 0
      # ... an empty conjunction.
      b.visit(Body::Normal) do
        b.visit(IntegerListStart.new(0)) do
          # no-op
        end
      end
      b.visit(Newline)
      return true
    else
      # ... a single-literal body.
      glue_literal = Literal.new(b.fresh_id(Int32))
      b.visit(Body::Normal) do
        b.visit(IntegerListStart.new(1)) do
          b.visit(glue_literal)
        end
      end
      b.visit(Newline)
    end

    a = @literals
    n = a.size

    return true if n < @lower_bound

    context = context_class_for(a).new(self)
    visitor = Visitor::ArrayLogic.new(a, context)
    network_of_width(n).visit(visitor)

    # Derive the glue literal from the appropriate body literal.
    context.operate(Gate::Restriction::Or, glue_literal, {a[@lower_bound - 1]})

    true # TODO: Consult the context about the return value.
  end

  protected def comment_end_of_translation
    visit(Statement::Comment) do
      visit(Comment.new("End of translation"))
    end
  end

  protected def output_weight_rule
    check_delegate_to_super
    visit(Body::Weight, @lower_bound) do
      visit(WeightedLiteralListStart.new(@literals.size)) do
        @literals.each_with_index do |l, i|
          visit(l, @weights[i])
        end
      end
    end
  end

  private def check_delegate_to_super
    raise "Internal error" unless @delegate_to_super
  end

  private def network_of_width(n)
    scheme =
      Scheme::WidthLimited.new(
        Scheme::MergeSort::Recursive.new(
          Scheme::OEMerge::INSTANCE
        )
      )
    scheme.network(n)
  end

  private def context_class_for(a : Array(Literal(I))) forall I
    ASPIF::LogicContext(I)
  end
end
