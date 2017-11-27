# A wrapper over a `Distance` value that is used as an argument to
# `#visit_region` calls in order to signal that any gates within the region
# ought to be shifted by that value in terms of wire positions.
struct PBTranslate::Offset
  getter value : Distance

  def initialize(@value : Distance)
  end
end
