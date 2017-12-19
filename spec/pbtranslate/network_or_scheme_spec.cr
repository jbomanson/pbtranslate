require "../../spec_helper"
require "../../eval_spec_helper_spec"

describe PBTranslate::NetworkOrScheme do
  context "#gate_option_keys" do
    it "works with a network that has a gate option" do
      NetworkWithLevel.new.gate_option_keys.should eq(
        CompileTimeSet.create(:level)
      )
    end
  end
end

private struct NetworkWithLevel
  include Network

  def host_reduce(visitor, memo)
    visitor.visit_gate("gate", memo, level: Distance.new(0))
  end
end
