require "../spec_helper"

include PBTranslate

private INSTANCE_PATH  = "spec/instance/300.aspif"
private FILTER_PROGRAM = %x(spec/script/find-lpconvert.sh).chomp

private INSTANCE = File.read(INSTANCE_PATH)

private def describe_translator_class(translator_class)
  describe translator_class do
    it "produces output accepted by #{FILTER_PROGRAM}" do
      Process.run(FILTER_PROGRAM, output: Process::Redirect::Close) do |process|
        translator_class.new(INSTANCE, process.input).parse
        process.wait
      end.exit_code.should eq(0)
    end
  end
end

describe "FILTER_PROGRAM" do
  it "is found on the system" do
    FILTER_PROGRAM.should_not eq("")
  end
end

describe_translator_class(ASPIF::Broker)
describe_translator_class(Tool::CardinalityTranslator)
describe_translator_class(Tool::OptimizationRewriter)
