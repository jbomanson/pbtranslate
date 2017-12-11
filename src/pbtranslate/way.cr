# An abstract struct with two descendants, `Backward` and `Forward`
# with corresponding instances `BACKWARD` and `FORWARD`.
#
# These structs hold no data.
# They facilitate iteration in parametrized directions.
#
# ### Example
#
#     include PBTranslate
#
#     def join(way : Way)
#       a = [100, 200, 300]
#       String.build do |builder|
#         way.each_in(a) do |n|
#           builder << '('
#           builder << n
#           builder << ')'
#         end
#       end
#     end
#
#     join(FORWARD)   # => "(100)(200)(300)"
#     join(BACKWARD)  # => "(300)(200)(100)"
abstract struct PBTranslate::Way
  # :nodoc:
  def initialize
  end

  # Similar to `Indexable#each_index` for _object_.
  #
  # The order of iteration is determined by the type of _self_.
  def each_index_to(object)
    each_in(0...object.size) { |x| yield x }
  end

  # Similar to `Indexable#each_with_index` for _object_.
  #
  # The order of iteration is determined by the type of _self_.
  def each_with_index_in(object)
    each_index_to(object) { |index| yield object[index], index }
  end

  # Returns `+1` when going forward and `-1` when going backward.
  def sign
    first(+1, -1)
  end

  # Similar to `Int#times` for _n_.
  def times(n)
    each_in(typeof(n).new(0)...n) { |x| yield x }
  end

  # Returns the way forward if this and `way` agree, and backward otherwise.
  def compose(way)
    first(way, way.reverse)
  end

  # A convenience macro for defining argumentless _each_ and *reverse_each*
  # methods for an object that defines *each_in* with a single `Way` argument.
  #
  # ### Example
  #
  #     include PBTranslate
  #
  #     class Triple
  #       VALUES = [100, 200, 300]
  #
  #       Way.define_each
  #
  #       def each_in(way : Way)
  #         way.each_in(VALUES) do |value|
  #           yield value
  #         end
  #       end
  #     end
  #
  #     a = [] of Int32
  #     Triple.new.each { |x| a << x }
  #     a # => [100, 200, 300]
  #     a = [] of Int32
  #     Triple.new.reverse_each { |x| a << x }
  #     a # => [300, 200, 100]
  macro define_each
    def each
      each_in(FORWARD) { |x| yield x }
    end

    def reverse_each
      each_in(BACKWARD) { |x| yield x }
    end
  end

  # A module containing the definitions of the descendants of `Way`.
  #
  # For convenience, this module is included in the PBTranslate module.
  module Module
    module ::PBTranslate
      include Way::Module
    end

    FORWARD  = Forward.new
    BACKWARD = Backward.new

    struct Forward < Way
      # Similar to `Enumerable#each` for _object_.
      def each_in(object)
        object.each
      end

      # Similar to `Enumerable#each` for _object_.
      def each_in(object)
        object.each { |x| yield x }
      end

      # Returns _f_.
      def first(f, b)
        f
      end

      def reverse
        BACKWARD
      end
    end

    struct Backward < Way
      # Similar to `Indexable#reverse_each` for _object_.
      def each_in(object)
        object.reverse_each
      end

      # Similar to `Indexable#reverse_each` for _object_.
      def each_in(object)
        object.reverse_each { |x| yield x }
      end

      # Returns _b_.
      def first(f, b)
        b
      end

      def reverse
        FORWARD
      end
    end
  end
end
