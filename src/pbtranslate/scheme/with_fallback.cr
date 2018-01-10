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

  def_scheme_children @schemes
  delegate_scheme_details_to @schemes[0], @schemes[1]

  def initialize(a : A, b : B)
    @schemes = {a, b}
  end

  def network(width : Width)
    (@schemes.first.network? width) || (@schemes.last.network(width))
  end

  def network?(width : Width)
    (@schemes.first.network? width) || (@schemes.last.network?(width))
  end

  # See `Scheme#to_scheme_with_gate_level`.
  def to_scheme_with_gate_level
    a, b = @schemes
    a.to_scheme_with_gate_level.to_scheme_with_fallback(b.to_scheme_with_gate_level)
  end
end
