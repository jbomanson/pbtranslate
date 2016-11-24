require "../network/direct_merge"

# A DirectMerge scheme represents class of networks of bounded depth that
# merge Booleans.
#
# The methods of this scheme are parametrized by the logarithm of the half
# width of the produced networks.
class PBTranslator::Scheme::DirectMerge
  INSTANCE = new

  def network(half_width : Width::Pw2)
    Network::DirectMerge.new(half_width.log2)
  end
end
