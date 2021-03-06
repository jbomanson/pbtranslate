require "../scheme"

# :nodoc:
class PBTranslate::Scheme::PartialFlexibleVoid
  include Scheme
  include Scheme::WithArguments(Nil)

  module ::PBTranslate
    # Creates a partial scheme that represents no networks.
    def Scheme.partial_flexible_void : Scheme
      PartialFlexibleVoid.new
    end
  end

  # Returns nil.
  def network?(*args) : Nil
  end
end
