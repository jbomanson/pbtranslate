require "colorize"
require "option_parser"

# A class for processing command line options.
#
# This is based on `Crystal::Command`.
class PBTranslator::Command
  USAGE = <<-USAGE
    Usage: pbtranslator [command] [options] [--] [input file]

    Command:
        translate                translate a file
        help, --help, -h         show this help
        version, --version, -v   show version
    USAGE

  def self.run(options = ARGV)
    new(options).run
  end

  private getter options

  def initialize(@options : Array(String))
    @color = true
  end

  def run
    command = options.first?

    if command
      case
      when "translate".starts_with? command
        options.shift
        translate
      when "help".starts_with?(command), "--help" == command, "-h" == command
        puts USAGE
        exit
      when "version".starts_with?(command), "--version" == command, "-v" == command
        puts PBTranslator::Config.description
        exit
      else
        error "unknown command: #{command}"
      end
    else
      puts USAGE
      exit(1)
    end
  rescue ex : OptionParser::Exception
    error ex.message
  rescue ex
    puts ex
    ex.backtrace.each do |frame|
      puts frame
    end
    puts
    error "you've found a bug in PBTranslator"
  end

  private def translate
    type = nil
    input_filename = nil
    output_filename = nil
    crop_depth = nil

    option_parser =
      OptionParser.parse(options) do |opts|
        opts.banner = "Usage: pbtranslator translate [options] [--] [input file]\n\nOptions:"

        opts.on("--type cardinality|optimization|nothing", "Translate cardinality rules, rewrite optimization statements or do nothing") do |t|
          type = t
        end

        opts.on("--crop-depth <d>", "Use first <d> or last -<d> layers of a sorting network") do |d|
          crop_depth = d
        end

        opts.on("-o ", "Output filename") do |o|
          output_filename = o
        end

        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on("--no-color", "Disable colored output") do
          @color = false
        end
        opts.unknown_args do |before, after|
          filenames = before + after
          case filenames.size
          when 0
          when 1
            input_filename = filenames.first
          else
            s = filenames.join(",")
            error "ambiguous input files: #{s}"
          end
        end
      end

    if f = input_filename
      if File.file?(f)
        error "file #{f} does not exist"
      end
    end

    with_file_or_io(input_filename, "r", STDIN) do |input_io|
      with_file_or_io(output_filename, "w", STDOUT) do |output_io|
        translator_class = translator_class_of(type)
        translator = translator_class.new(input_io, output_io)
        if d = crop_depth
          unless translator.responds_to? :"crop_depth="
            error "the --crop-depth option is not supported with --type #{type}"
          end
          translator.crop_depth = d.to_i
        end
        translate(translator)
      end
    end
  end

  private def translator_class_of(type : String?)
    case
    when !type
      error "missing required option --type"
    when "cardinality".starts_with? type
      Tool::CardinalityTranslator
    when "optimization".starts_with? type
      Tool::OptimizationRewriter
    when "nothing".starts_with? type
      ASPIF::Broker
    else
      if type
        error "unknown argument '#{type}' to --type"
      else
        error "missing required option --type"
      end
    end
  end

  private def translate(translator)
    result = translator.parse
    if result
      # Report a syntax error, but without mentioning "error" twice.
      wo_first = result.split("\n")[1..-1].join("\n")
      error("", extra: wo_first)
    end
  end

  private def with_file_or_io(file : String?, mode : String, io : IO, &block : IO ->)
    if file
      File.open(file, mode, &block)
    else
      block.call(io)
    end
  end

  private def error(msg, *, extra = "", exit_code = 1, stderr = STDERR)
    @color = false if ARGV.includes?("--no-color")
    stderr.print "Error: ".colorize.toggle(@color).red.bold
    stderr.puts msg.colorize.toggle(@color).bright
    stderr.print extra
    exit(exit_code)
  end
end
