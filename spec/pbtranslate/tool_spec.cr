require "../spec_helper"

include PBTranslate

private module Private
  INSTANCE_PATH  = "spec/instance/300.aspif"
  FILTER_PROGRAM = %x(spec/script/find-lpconvert.sh).chomp

  INSTANCE = File.read(Private::INSTANCE_PATH)
end

private def describe_translator_class(translator_class, *args)
  describe translator_class do
    it "produces output accepted by #{Private::FILTER_PROGRAM}" do
      Process.run(Private::FILTER_PROGRAM, output: Process::Redirect::Close) do |process|
        translator_class.new(*args, Private::INSTANCE, process.input).parse
        process.wait
      end.exit_code.should eq(0)
    end
  end
end

describe "Private::FILTER_PROGRAM" do
  it "is found on the system" do
    Private::FILTER_PROGRAM.should_not eq("")
  end
end

describe_translator_class(ASPIF::Broker)
describe_translator_class(Tool::CardinalityTranslator, Tool::BASE_SCHEME)
describe_translator_class(Tool::OptimizationRewriter, Tool::BASE_SCHEME)
