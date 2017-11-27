require "../network/layer_cache"

# A scheme of networks that cache the gates of networks of a given scheme and
# then present the gates in increasing order of layers.
#
# Note however that the networks themselves are not cached.
# That is, repeated calls to `network` may return different network instances.
class PBTranslate::Scheme::LayerCache(S, G, O)
  include Scheme

  def gate_options(**extra)
    ::PBTranslate::GateOptions.new(**extra, {{@type.type_vars.last.keys.join(", ").id}})
  end

  # Returns a `LayerCache` type with type arguments appropriate for wrapping
  # a *scheme* that provides specified kinds of *gate*s and gate *options*.
  def self.class_for(scheme : S, gate : G, **options : **O) forall S, G, O
    LayerCache(typeof(preprocess(scheme)), G, O)
  end

  protected def self.preprocess(scheme)
    scheme.with_gate_depth
  end

  @scheme : S

  # Creates a scheme of networks that cache the gates of the networks of the
  # given _scheme_.
  def initialize(scheme)
    @scheme = self.class.preprocess(scheme)
  end

  # Generates a network of the given *width* with the same gates that a network
  # from the parameter scheme would produce, but always in the order of layers.
  def network(width : Width)
    Network::LayerCache(G, O).new(network: @scheme.network(width), width: width)
  end
end
