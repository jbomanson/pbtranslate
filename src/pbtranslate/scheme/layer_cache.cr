require "../network/layer_cache"

# :nodoc:
class PBTranslate::Scheme::LayerCache(S)
  include Scheme

  module ::PBTranslate::Scheme
    # Creates scheme of networks that cache the gates of the networks of this
    # scheme and then present the gates in increasing order of layers.
    #
    # Note however that the networks themselves are not cached.
    # That is, repeated calls to `network` may return different network
    # instances.
    def to_scheme_layer_cache : Scheme
      LayerCache.new(self)
    end
  end

  delegate_scheme_details_to @scheme

  def gate_options(**extra)
    ::PBTranslate::GateOptions.new({{@type.type_vars.last.keys.join(", ").id}}, **extra)
  end

  # Creates a scheme of networks that cache the gates of the networks of the
  # given _scheme_.
  def self.new(scheme : Scheme)
    new(scheme.to_scheme_with_gate_level, nil)
  end

  private def initialize(@scheme : S, overload : Nil)
  end

  # Generates a network of the given *width* with the same gates that a network
  # from the parameter scheme would produce, but always in the order of layers.
  def network(width : Width)
    Network::LayerCache.new(@scheme.network(width), width)
  end
end
