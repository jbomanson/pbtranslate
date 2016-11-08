module PBTranslator
  FORWARD  = Forward.new
  BACKWARD = Backward.new

  abstract struct Way
    macro define_each
      def each
        each_in(FORWARD) { |x| yield x }
      end

      def reverse_each
        each_in(BACKWARD) { |x| yield x }
      end
    end
  end

  struct Forward < Way
    def each_between(lo, hi)
      lo.upto(hi) { |x| yield x }
    end

    def each_in(object)
      object.each { |x| yield x }
    end

    def each_index_to(object)
      each_between(0, object.size - 1) { |x| yield x }
    end
  end

  struct Backward < Way
    def each_between(lo, hi)
      hi.downto(lo) { |x| yield x }
    end

    def each_in(object)
      object.reverse_each { |x| yield x }
    end

    def each_index_to(object)
      each_between(object.size - 1, 0) { |x| yield x }
    end
  end
end
