require "../../spec_helper"

describe "PBTranslate::Network.singleton" do
  it "works" do
    Network
      .singleton("gate", level: Distance.new(0))
      .gates_with_options
      .to_a
      .should eq([{"gate", {level: Distance.new(0)}}])
  end
end
