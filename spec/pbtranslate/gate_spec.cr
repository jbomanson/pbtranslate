require "../spec_helper"

describe PBTranslate::Gate do
  it "is implements #inspect" do
    one = Distance.new(1)
    two = Distance.new(2)
    Gate.passthrough_at(one).inspect.should eq("Passthrough(1)")
    Gate.comparator_between(one, two).inspect.should eq("Comparator(1, 2)")
    Gate.and_of(tuple: {one, two}).inspect.should eq("And(1, 2)")
    Gate.or_as(one).inspect.should eq("Or(1)")
  end
end
