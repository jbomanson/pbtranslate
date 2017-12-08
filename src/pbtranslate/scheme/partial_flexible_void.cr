require "../scheme"

# :nodoc:
class PBTranslate::Scheme::PartialFlexibleVoid
  include Scheme

  module ::PBTranslate
    # Creates a partial scheme that represents no networks.
    def Scheme.partial_flexible_void : Scheme
      PartialFlexibleVoid.new
    end
  end

  declare_void_gate_options

  # Returns nil.
  def network?(*args, **options) : Nil
  end
end