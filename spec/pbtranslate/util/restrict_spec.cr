require "../../spec_helper"
require "../../eval_spec_helper_spec"

include PBTranslate::Util

private RESTRICT_NOT_NILABLE_UNION_NEGATIVE = <<-EOF
  require "../src/pbtranslate/util/restrict"

  include PBTranslate::Util

  restrict_not_nilable_union(true ? 1 : nil)
EOF

describe "PBTranslate::Util.restrict_not_nilable_union" do
  it "accepts non-union types and non-nilable union types" do
    restrict_not_nilable_union(1).should eq(1)
    restrict_not_nilable_union(true ? 1 : "a").should eq(true ? 1 : "a")
    restrict_not_nilable_union(nil).should eq(nil)
  end

  it "catches nilable union types at compile time" do
    SpecHelper.eval(RESTRICT_NOT_NILABLE_UNION_NEGATIVE).should match(
      /\QExpected anything but a nilable union type, got (Int32 | Nil)\E/
    )
  end
end

private RESTRICT_TUPLE_UNIFORM_NEGATIVE = <<-EOF
  require "../src/pbtranslate/util/restrict"

  include PBTranslate::Util

  restrict_tuple_uniform({1, 2, "b"})
EOF

describe "PBTranslate::Util.restrict_tuple_uniform" do
  it "accepts uniform tuple types" do
    restrict_tuple_uniform({1, 2, 3}).should eq({1, 2, 3})
  end

  it "catches non uniform tuple types at compile time" do
    SpecHelper.eval(RESTRICT_TUPLE_UNIFORM_NEGATIVE).should match(
      /\QExpected a tuple type repeating a single type, got\E/
    )
  end
end
