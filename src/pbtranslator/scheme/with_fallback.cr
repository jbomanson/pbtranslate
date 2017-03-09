class PBTranslator::Scheme::WithFallback(A, B)
  include Scheme

  def initialize(@scheme_a : A, @scheme_b : B)
  end

  def network(width : Width)
    (@scheme_a.network? width) || (@scheme_b.network(width))
  end

  def network?(width : Width)
    (@scheme_a.network? width) || (@scheme_b.network?(width))
  end
end
