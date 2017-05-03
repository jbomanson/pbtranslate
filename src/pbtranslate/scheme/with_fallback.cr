require "../scheme"

class PBTranslate::Scheme::WithFallback(A, B)
  include Scheme

  delegate gate_options, to: (true ? @schemes.first : @schemes.last)

  def initialize(a : A, b : B)
    @schemes = {a, b}
  end

  def network(width : Width)
    (@schemes.first.network? width) || (@schemes.last.network(width))
  end

  def network?(width : Width)
    (@schemes.first.network? width) || (@schemes.last.network?(width))
  end

  def with_gate_depth
    a, b = @schemes
    WithFallback.new(a.with_gate_depth, b.with_gate_depth)
  end
end
