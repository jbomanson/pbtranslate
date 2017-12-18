require "../spec_helper"

private struct ArrayMaker
  def call(x)
    [x]
  end
end

describe Object do
  context "#pbtranslate_receive_call_from" do
    it "works when creating specialized arrays" do
      maker = ArrayMaker.new
      element = true ? 1 : ""
      array = element.pbtranslate_receive_call_from(maker)
      array.should eq([1])
      typeof(array).should eq(Array(Int32) | Array(String))
    end
  end
end
