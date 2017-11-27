require "../scheme"

# A scheme of networks obtained by first trying to use a partial scheme of type
# *A* to generate a network and then a scheme of type *B* on failure.
class PBTranslate::Scheme::WithFallback(A, B)
  include Scheme

  delegate gate_options, to: (true ? @schemes.first : @schemes.last)

  # Creates a scheme that tries to use partial scheme *a* and then scheme *b*
  # to generate networks.
  def initialize(a : A, b : B)
    @schemes = {a, b}
  end

  # Generates a network of the given *width*.
  def network(width : Width)
    (@schemes.first.network? width) || (@schemes.last.network(width))
  end

  # Generates a network of the given *width* or returns nil if neither
  # of the backing schemes can generate a network of this width.
  def network?(width : Width)
    (@schemes.first.network? width) || (@schemes.last.network?(width))
  end

  # See `Scheme#with_gate_depth`.
  def with_gate_depth
    a, b = @schemes
    WithFallback.new(a.with_gate_depth, b.with_gate_depth)
  end
end
