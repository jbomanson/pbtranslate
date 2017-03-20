class PBTranslator::Scheme::LayerCache(S, G, O)
  include GateOptions::Module

  def gate_options(**extra)
    ::PBTranslator::GateOptions.new(**extra, {{@type.type_vars.last.keys.join(", ").id}})
  end

  def self.class_for(scheme : S, gate : G, **options : **O) forall S, G, O
    LayerCache(typeof(preprocess(scheme)), G, O)
  end

  protected def self.preprocess(scheme)
    scheme.with_depth
    # DepthTracking::Scheme.wrap_if_needed(scheme)
  end

  @scheme : S

  def initialize(scheme)
    @scheme = self.class.preprocess(scheme)
  end

  def network(width : Width)
    Network::LayerCache(G, O).new(network: @scheme.network(width), width: width)
  end
end
