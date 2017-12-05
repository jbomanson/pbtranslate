require "./with_fallback"

module PBTranslate::Scheme
  # A marker module for some schemes that generate networks of any `Width`, as
  # opposed to only `Width::Pw2`.
  #
  # In addition to the schemes that include this module, there are other
  # schemes that generate such networks.
  # Some of them are included in `Flexible`.
  # The reason that they do not include this module is two fold:
  # * They are generic types of schemes that generate such networks only when
  #   instantiated with certain type arguments.
  # * In Crystal, either all instances of a generic type include a module, or
  #   none of them do.
  module FlexibleMarker
    # Generates a network of the given width.
    abstract def network(width w : Width)
  end

  # An alias for some schemes that generate networks of any `Width`, as
  # opposed to only `Width::Pw2`.
  alias Flexible = FlexibleMarker |
                     OffsetResolution(FlexibleDivideAndConquerDynamicProgramming(Scheme::FlexiblePartialSortHardCoded.class, FlexibleCombineFromPw2Combine(Pw2MergeOddEven))) |
                     WithFallback(Scheme::FlexiblePartialSortHardCoded.class, FlexibleMarker)
end