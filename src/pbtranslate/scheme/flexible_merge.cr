require "../scheme"
require "../network/empty"
require "../network/width_slice"

struct PBTranslate::Scheme::FlexibleMerge(S)
  include Scheme

  delegate gate_options, to: @merge_scheme

  def initialize(@merge_scheme : S = OddEvenMerge)
  end

  def network(widths : {Width, Width})
    l, r = lr = widths.map &.value
    middle = Math.pw2ceil(lr.map { |x| Math.pw2ceil(x) }.sum) >> 1
    Network::WidthSlice.new(
      network: @merge_scheme.network(Width.from_pw2(middle)),
      begin: middle - l,
      end: middle + r,
    )
  end

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
