require "../gate"
require "../lag_array"

module PBTranslator

  struct Visitor::ArrayLogic(T)
    include Gate::Restriction

    struct OOPLayerVisitor(T)

      struct OrVisitor(T)

        protected getter value

        def initialize(@array : Array(T), @value : T)
        end

        def visit(f : And.class, s : Input.class, wires) : Void
          @value |=
            wires.
            map do |wire|
              @array[wire]
            end.
            reduce do |memo, input|
              memo & input
            end
        end

      end

      def initialize(@lagged : LagArray::Lagged(T), @zero : T)
      end

      def visit(f : Or.class, s : Output.class, wires) : Void
        or_visitor = OrVisitor.new(@lagged.array, @zero)
        yield or_visitor
        index = wires.first
        value = or_visitor.value
        @lagged[index] = value
      end

    end

    def initialize(array : Array(T), @zero : T)
      @array = LagArray(T).new(array)
    end

    def visit(f : Comparator.class, s : InPlace.class, wires) : Void
      i, j = wires
      a = @array[i]
      b = @array[j]
      @array[i] = a & b
      @array[j] = a | b
    end

    def visit(f : OOPLayer.class) : Void
      @array.lag do |lagged|
        layer_visitor = OOPLayerVisitor.new(lagged, @zero)
        yield layer_visitor
      end
    end

  end

end
