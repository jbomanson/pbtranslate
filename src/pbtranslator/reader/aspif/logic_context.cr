require "../../visitor/array_logic"

# An object that specifies how definitions of the outputs of "And" and "Or"
# gates are written in ASPIF.
#
# The type parameter `I` is the integer type used to number literals.
struct PBTranslator::Reader::ASPIF::LogicContext(I)
  include Visitor::ArrayLogic::Context(Literal(I))
  include Gate::Restriction

  def initialize(@aspif_broker : ASPIFBroker)
  end

  def operate(f, args)
    broker_define_literal do |head_literal|
      operate(f, head_literal, args)
    end
  end

  private def broker_define_literal : Literal(I)
    Literal(I).new(@aspif_broker.fresh_id(I)).tap do |head_literal|
      yield head_literal
    end
  end

  def operate(f : And.class, head_literal, body_literals)
    b = @aspif_broker
    b.visit(Statement::Rule) do
      b.visit(Head::Disjunction) do
        b.visit(IntegerListStart.new(1)) do
          b.visit(head_literal)
        end
      end
      b.visit(Body::Normal) do
        n = body_literals.size
        b.visit(IntegerListStart.new(n)) do
          body_literals.each do |literal|
            b.visit(literal)
          end
        end
      end
    end
    b.visit(Newline)
  end

  def operate(f : Or.class, head_literal, body_literals)
    b = @aspif_broker
    body_literals.each do |literal|
      b = @aspif_broker
      b.visit(Statement::Rule) do
        b.visit(Head::Disjunction) do
          b.visit(IntegerListStart.new(1)) do
            b.visit(head_literal)
          end
        end
        b.visit(Body::Normal) do
          b.visit(IntegerListStart.new(1)) do
            b.visit(literal)
          end
        end
      end
      b.visit(Newline)
    end
  end
end
