require "../aspif/broker"
require "../aspif/logic_context"
require "./base_scheme"
require "../network/cone"
require "../util/id_broker"
require "../visitor/array_logic"

# An object that translates cardinality rules into normal rules in ASPIF::Reader.
class PBTranslate::Tool::CardinalityTranslator <
    PBTranslate::ASPIF::Broker

  property scheme

  @in_weight_rule = false
  @lower_bound = 0
  @literals = Array(Literal(Util::BrokeredId(Int32))).new
  @weights = Array(Int32).new
  @scheme = BASE_SCHEME.as(Scheme::OfAnyWidth)

  def visit(b : Body, lower_bound : Int) : Bool
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

  def visit(n : WeightedLiteralListStart) : Bool
    unless @in_weight_rule
      super(n) { yield }
    else
      !!yield
    end
  end

  def visit(l : Literal, w : Int) : Bool
    unless @in_weight_rule
      super
    else
      @literals << rename(l.value.to_i32)
      @weights << w.to_i32
      true
    end
  end

  protected def revisit : Bool
    if @weights.all? &.==(1)
      translate_cardinality
      comment_end_of_translation
    else
      output_weight_rule
    end
  end

  protected def translate_cardinality
    # Complete the unfinished rule with ...
    if @lower_bound <= 0
      # ... an empty conjunction.
      output(Body::Normal) do
        output(IntegerListStart.new(0)) do
          # no-op
        end
      end
      output(Newline)
      return true
    else
      # ... a single-literal body.
      glue_literal = Literal.new(fresh_id(Int32))
      output(Body::Normal) do
        output(IntegerListStart.new(1)) do
          output(glue_literal)
        end
      end
      output(Newline)
    end

    a = @literals
    w = a.size

    return true if w < @lower_bound

    context = ASPIF::LogicContext.class_for(a, Int32).new(self)
    visitor = Visitor::ArrayLogic.new(a, context)
    network = network_of_width(w)
    network.host(visitor)

    # Derive the glue literal from the appropriate body literal.
    context.operate(Gate::Restriction::Or, glue_literal, {a[@lower_bound - 1]})

    true # TODO: Consult the context about the return value.
  end

  protected def comment_end_of_translation
    output(Statement::Comment) do
      output(Comment.new("End of translation"))
    end
  end

  protected def output_weight_rule
    output(Body::Weight, @lower_bound) do
      output(WeightedLiteralListStart.new(@literals.size)) do
        @literals.each_with_index do |literal, i|
          output(literal)
          output(@weights[i])
        end
      end
    end
  end

  private def network_of_width(w)
    s = @scheme
    n = s.network(Width.from_value(Distance.new(w)))
    b = @lower_bound - 1
    Network::Cone.new(network: n, width: w, &.==(b))
  end
end
