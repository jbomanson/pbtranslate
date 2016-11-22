require "../gate"
require "../lag_array"

struct PBTranslator::Visitor::ArrayLogic(T)
  include Gate::Restriction

  module Context(T)
    abstract def operate(f : Class, args : Tuple(*T)) : T
    abstract def operate(f : Class, args : Array(T)) : T
  end

  def initialize(
    array : Array(T),
    @context : Context(T) = DefaultContext(T).new)

    @array = LagArray(T).new(array)
    @factory = AccumulatingVisitorFactory(T).new
  end

  def visit(gate : Gate(Comparator, InPlace, _), way : Forward) : Void
    i, j = gate.wires
    a = @array[i]
    b = @array[j]
    @array[i] = @context.operate(Or, {a, b})
    @array[j] = @context.operate(And, {a, b})
  end

  def visit(gate : Gate(Passthrough, _, _), way : Forward) : Void
  end

  def visit(f : OOPLayer.class, way : Way) : Void
    @array.lag do |lagged|
      layer_visitor = Layer.new(lagged, @context, @factory)
      yield layer_visitor
    end
  end

  private struct DefaultContext(T)
    include Context(T)

    {% for pair in [{:Or, :|}, {:And, :&}] %}
      def operate(f : {{pair.first.id}}.class, args) : T
        args.reduce do |memo, value|
          memo {{pair.last.id}} value
        end
      end
    {% end %}
  end

  private struct Layer(A, T)
    def initialize(
      @array : A,
      @context : Context(T),
      @factory : AccumulatingVisitorFactory(T))
    end

    def visit(gate : Gate(F, Output, _), way : Forward) : Void
      index = gate.wires.first
      value =
        @factory.visit(F, @array.to_a, @context) do |output_visitor|
          yield output_visitor
        end
      @array[index] = value
    end
  end

  private struct AccumulatingVisitorFactory(T)
    def initialize
      @storage = Array(T).new
    end

    def visit(f : Class, array : Array(T), context : Context(T))
      AccumulatingVisitor.visit(f, array, context, @storage) do |visitor|
        yield visitor
      end
    end
  end

  private struct AccumulatingVisitor(T)
    def self.visit(
      f : Class,
      array : Array(T),
      context : Context(T),
      storage : Array(T))

      yield new(array, context, storage)
      value = context.operate(f, storage)
      storage.clear
      value
    end

    protected def initialize(
      @array : Array(T),
      @context : Context(T),
      @storage : Array(T))
    end

    def visit(gate : Gate(F, Input, _), way : Forward) : Void
      operands = gate.wires.map { |wire| @array[wire] }
      visit(@context.operate(F, operands))
    end

    def visit(gate : Gate(Passthrough, _, _), way : Forward) : Void
    end

    def visit(t : T) : Void
      @storage << t
    end
  end
end
