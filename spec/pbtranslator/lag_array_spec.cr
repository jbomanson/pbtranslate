require "../spec_helper"

describe PBTranslator::LagArray do
  it "can swap a pair in the middle of an array" do
    a = [:a, :b, :c, :d]
    g = PBTranslator::LagArray.new(a)
    g.lag do |d|
      d[1] = d[2]
      d[2] = d[1]
    end
    a.should eq([:a, :c, :b, :d])
  end
end
