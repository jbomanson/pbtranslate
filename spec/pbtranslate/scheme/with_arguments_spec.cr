require "../../spec_helper"

private struct DummyNetwork
  include Network

  def host_reduce(visitor, memo)
    memo
  end
end

private struct DummyNetworkScheme
  include Scheme
  include Scheme::WithArguments(String)

  def network?(string : String)
    if string == "please"
      DummyNetwork.new
    end
  end
end

describe PBTranslate::Scheme::WithArguments do
  it "implements #network_for_typeof" do
    typeof(DummyNetworkScheme.new.network_for_typeof).should eq(DummyNetwork)
  end

  it "returns a network on a defined #network call" do
    DummyNetworkScheme.new.network("please").should be_a(DummyNetwork)
  end

  it "raises on an undefined #network call" do
    expect_raises(UndefinedNetworkError) { DummyNetworkScheme.new.network("") }
  end
end
