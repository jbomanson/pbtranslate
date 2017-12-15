require "./flexible_combine"
require "../network/empty"
require "../network/width_slice"
require "../scheme"

# :nodoc:
struct PBTranslate::Scheme::FlexibleCombineFromPw2Combine(S)
  include Scheme
  include FlexibleCombine

  module ::PBTranslate::Scheme::Pw2Combine
    # Creates a version of this scheme that generates networks to combine pairs
    # of sequences of flexible lengths into single sequences, as opposed to
    # only pairs of equal length sequences of length that is a power of two.
    #
    # The generated networks are obtained by ignoring generating sufficiently
    # large base networks and ignoring any excess wires at low and high
    # positions.
    # The depths of the resulting networks are generally the same as those of the
    # base networks.
    def to_scheme_flexible_combine : FlexibleCombine
      FlexibleCombineFromPw2Combine.new(self)
    end
  end

  delegate gate_options, to: @combine_scheme

  def initialize(@combine_scheme : S = Pw2MergeOddEven)
  end

  def network(widths : {Width, Width})
    l, r = lr = widths.map &.value
    middle = Math.pw2ceil(lr.map { |x| Math.pw2ceil(x) }.sum) >> 1
    Network::WidthSlice.new(
      network: @combine_scheme.network(Width.from_pw2(middle)),
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

    delegate_scheme_details_to @scheme
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
