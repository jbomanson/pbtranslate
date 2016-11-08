require "../spec_helper"

include PBTranslator

describe LagArray do
  it "can swap a pair in the middle of an array" do
    a = [:a, :b, :c, :d]
    g = LagArray.new(a)
    g.lag do |d|
      d[1] = d[2]
      d[2] = d[1]
    end
    a.should eq([:a, :c, :b, :d])
  end
end
