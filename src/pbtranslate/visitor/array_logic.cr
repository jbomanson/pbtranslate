require "../gate"
require "../lag_array"
require "./default_methods"

# A visitor that operates on an array while visiting in place gates as well as
# gates arranged in layers.
struct PBTranslate::Visitor::ArrayLogic(T)
  include DefaultMethods
  include Gate::Restriction
  include Visitor

  # An interface for objects that perform logic operations on arrays.
  module Context(T)
    abstract def operate(f : Class, args : Enumerable(T)) : T
  end

  def initialize(
                 array : Array(T),
                 @context : Context(T) = DefaultContext(T).new)
    @array = LagArray(T).new(array)
    @accumulator = Accumulator(T).new
  end

  def visit_gate(gate : Gate(Comparator, InPlace, _), memo, *empty_args, output_cone, **options)
    i, j = gate.wires
    a = @array[i]
    b = @array[j]
    if output_cone[0]
      @array[i] = @context.operate(Or, {a, b})
    end
    if output_cone[1]
      @array[j] = @context.operate(And, {a, b})
    end
    memo
  end

  def visit_gate(gate : Gate(Comparator, InPlace, _), memo, **options)
    visit_gate(gate, memo, **options, output_cone: gate.wires.map { true })
  end

  def visit_gate(gate : Gate(Passthrough, _, _), memo, **options)
    memo
  end

  def visit_region(f : OOPSublayer.class) : Nil
    @array.lag do |lagged|
      layer_visitor = LayerVisitor.new(lagged, @context, @accumulator)
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

  # A visitor that operates on an array while visiting gates in a layer.
  #
  # The gates are expected to be split into input and output parts.
  private struct LayerVisitor(A, T)
    def initialize(
                   @array : A,
                   @context : Context(T),
                   @accumulator : Accumulator(T))
    end

    def visit_gate(gate : Gate(F, Output, _), memo, **options) forall F
      index = gate.wires.first.to_i
      value =
        @accumulator.accumulate(F, @array.to_a, @context) do |output_visitor|
          yield output_visitor
        end
      @array[index] = value
      memo
    end
  end

  # A reusable object for applying array operations on gate outputs.
  #
  # The user may expect a single internal array to be reused between operations
  # for performance reasons.
  private struct Accumulator(T)
    def initialize
      @storage = Array(T).new
    end

    # Yields a visitor, computes the values of gates given to it and returns the
    # result of operating on the values in _context_.
    def accumulate(f : Class, array : Array(T), context : Context(T)) : T
      s = @storage
      yield StoringOperatingVisitor.new(array, context, s)
      t = context.operate(f, s)
      s.clear
      t
    end
  end

  # A visitor of gates that applies the gate functions to inputs corresponding
  # to the gate input wires in a given context.
  private struct StoringOperatingVisitor(T)
    def initialize(
                   @array : Array(T),
                   @context : Context(T),
                   @storage : Array(T))
    end

    def visit_gate(gate : Gate(F, Input, _), memo, **options) forall F
      operands = gate.wires.map { |wire| @array[wire] }
      store(@context.operate(F, operands))
      memo
    end

    def visit_gate(gate : Gate(Passthrough, _, _), memo, **options)
      memo
    end

    private def store(t : T) : Nil
      @storage << t
    end
  end
end
