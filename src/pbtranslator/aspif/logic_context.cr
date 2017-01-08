require "../../visitor/array_logic"

# An object that specifies how definitions of the outputs of "And" and "Or"
# gates are written in ASPIF::Reader.
#
# The type parameter `T` is the type used with ArrayLogic::Context.
# The type parameter `I` is the integer type used to number literals.
struct PBTranslator::ASPIF::LogicContext(T, I)
  include Visitor::ArrayLogic::Context(T)
  include Gate::Restriction

  def self.class_for(a : Array(T), i : I.class) forall T, I
    LogicContext(T, I)
  end

  def initialize(@aspif_broker : ASPIF::Broker)
  end

  def operate(f, args)
    broker_define_literal do |head_literal|
      operate(f, head_literal, args)
    end
  end

  private def broker_define_literal : T
    Literal.new(@aspif_broker.fresh_id(I)).tap do |head_literal|
      yield head_literal
    end
  end

  def operate(f : And.class, head_literal, body_literals)
    b = @aspif_broker
    b.output(Statement::Rule) do
      b.output(Head::Disjunction) do
        b.output(IntegerListStart.new(1)) do
          b.output(head_literal)
        end
      end
      b.output(Body::Normal) do
        n = body_literals.size
        b.output(IntegerListStart.new(n)) do
          body_literals.each do |literal|
            b.output(literal)
          end
        end
      end
    end
    b.output(Newline)
  end

  def operate(f : Or.class, head_literal, body_literals)
    b = @aspif_broker
    body_literals.each do |literal|
      b = @aspif_broker
      b.output(Statement::Rule) do
        b.output(Head::Disjunction) do
          b.output(IntegerListStart.new(1)) do
            b.output(head_literal)
          end
        end
        b.output(Body::Normal) do
          b.output(IntegerListStart.new(1)) do
            b.output(literal)
          end
        end
      end
      b.output(Newline)
    end
  end
end
