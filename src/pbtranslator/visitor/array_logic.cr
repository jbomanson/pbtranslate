require "../lag_array"

module PBTranslator

  struct Visitor::ArrayLogic(T)

    struct OOPLayerVisitor

      struct OrVisitor(T)

        protected getter value

        def initialize(@array : Array(T), @value : T)
        end

        def visit(and_input : Gate(Gate::And, Gate::Input, T)) : Void
          @value |=
            and_input.
            wires.
            map do |wire|
              @array[wire]
            end.
            reduce do |memo, input|
              memo & input
            end
        end

      end

      def initialize(@lagged : LagArray::Lagged(T))
      end

      def visit(or_output : Gate(Gate::Or, Gate::Output, {I})) : Void
        or_visitor = OrVisitor.new(@lagged.array)
        yield or_visitor
        index = or_output.wires.first
        value = or_visitor.value
        @lagged[index] = value
      end

    end

    def initialize(array : Array(T), @zero : T)
      @array = LagArray(T).new(array)
    end

    def visit(comparator : Gate(Gate::Comparator, Gate::InPlace, {I, I})) : Void
      i, j = comparator.wires
      a = @array[i]
      b = @array[j]
      @array[i] = a & b
      @array[j] = a | b
    end

    def visit(ooplayer : Gate::OOPLayer) : Void
      @array.lag do |lagged|
        layer_visitor = OOPLayerVisitor.new(lagged)
        yield layer_visitor
      end
    end

  end

end
