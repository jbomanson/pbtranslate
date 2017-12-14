require "../../spec_helper"
require "../../../src/pbtranslate/util/type_to_value"

include PBTranslate::Util

describe "PBTranslate::Util.type_to_value" do
  it "works in trivial typeof expressions" do
    typeof(type_to_value(Int32)).should eq(Int32)
  end

  it "works with union types in typeof expressions" do
    typeof(type_to_value(Int32 | String)).should eq(Int32 | String)
  end

  it "works in typeof expressions with method calls" do
    typeof(type_to_value(Int32).to_s).should eq(String)
  end

  it "catches calls outside of typeof expressions" do
    expect_raises(Error) { type_to_value(Int32) }
  end
end
