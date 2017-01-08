# An abstract struct with two descendants, `Backward` and `Forward`
# with corresponding instances `BACKWARD` and `FORWARD`.
#
# These structs hold no data.
# They facilitate iteration in parametrized directions.
#
# ### Example
#
#     include PBTranslator
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
abstract struct PBTranslator::Way
  # Iterates over the integers in the given inclusive range,
  # passing each in turn to the given block.
  #
  # The order of iteration is determined by the type of _self_.
  def each_between(lo, hi)
    each_in(lo..hi) { |x| yield x }
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

  # A convenience macro for defining argumentless _each_ and *reverse_each*
  # methods for an object that defines *each_in* with a single `Way` argument.
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
  # For convenience, this module is included in the PBTranslator module.
  module Module
    module ::PBTranslator
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
    end
  end
end
