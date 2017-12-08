require "../scheme"

# :nodoc:
class PBTranslate::Scheme::WithFallback(A, B)
  include Scheme

  module ::PBTranslate::Scheme
    # Creates a scheme of networks obtained by first trying to use this partial
    # scheme and otherwise the given *backup_scheme*.
    #
    # The returned scheme is flexible if both this and backup_scheme are.
    # Likewise, it is partial if both this and backup_scheme are.
    def to_scheme_with_fallback(backup_scheme : Scheme)
      WithFallback.new(self, backup_scheme)
    end
  end

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

  # See `Scheme#to_scheme_with_gate_depth`.
  def to_scheme_with_gate_depth
    a, b = @schemes
    a.to_scheme_with_gate_depth.to_scheme_with_fallback(b.to_scheme_with_gate_depth)
  end
end
