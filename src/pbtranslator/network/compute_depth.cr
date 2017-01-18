module PBTranslator::Network
  # Calls `DepthTracking.compute_depth`.
  def self.compute_depth(*args, **options)
    DepthTracking.compute_depth(*args, **options)
  end
end
