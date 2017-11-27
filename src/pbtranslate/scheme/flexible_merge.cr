require "../scheme"
require "../network/empty"
require "../network/width_slice"

# A scheme of networks that merge pairs of sorted sequences of arbitrary
# lengths and which are based on networks that merge pairs of sorted sequences
# of equal lenghts that are powers of two.
#
# The base networks are obtained from a given scheme of a parameterized type.
# The scheme must provide a *#network* method with a single `Width::Pw2`
# argument standing for the width of each of the halves to be merged.
#
# The resulting networks are obtained by ignoring appropriate numbers of wires
# at low and high positions.
# The depths of the resulting networks are generally the same as those of the
# base networks.
struct PBTranslate::Scheme::FlexibleMerge(S)
  include Scheme

  delegate gate_options, to: @merge_scheme

  # Creates a flexible merge scheme based on the given *merge_scheme*.
  def initialize(@merge_scheme : S = OddEvenMerge)
  end

  # Generates a network that merges pairs of sorted sequences of the given
  # respective *widths*.
  def network(widths : {Width, Width})
    l, r = lr = widths.map &.value
    middle = Math.pw2ceil(lr.map { |x| Math.pw2ceil(x) }.sum) >> 1
    Network::WidthSlice.new(
      network: @merge_scheme.network(Width.from_pw2(middle)),
      begin: middle - l,
      end: middle + r,
    )
  end

  # Returns a partial `Scheme` with a `#network?` method defined for `Width`s
  # of zero, one, and two.
  def to_base_case
    ForTwo.new(self)
  end

  private struct ForTwo(S)
    include Scheme

    delegate gate_options, to: @scheme

    def initialize(@scheme : S)
    end

    def network?(width w : Width)
      one = Width.from_value(Distance.new(1))
      case w.value
      when 0, 1 then Network::Empty::INSTANCE
      when    2 then @scheme.network({one, one})
      end
    end
  end
end
