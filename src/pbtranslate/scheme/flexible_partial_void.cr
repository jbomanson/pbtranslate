require "../scheme"

# A partial scheme that represents no networks.
class PBTranslate::Scheme::FlexiblePartialVoid
  include Scheme

  # An instance of this scheme.
  INSTANCE = new

  declare_void_gate_options

  # Returns nil.
  def network?(*args, **options) : Nil
  end
end
