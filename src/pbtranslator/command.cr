require "colorize"
require "option_parser"

# A class for processing command line options.
#
# This is based on `Crystal::Command`.
class PBTranslator::Command
  RANDOM_SEED_DEFAULT = 0

  USAGE = <<-USAGE
    Usage: pbtranslator [command] [options] [--] [input file]

    Command:
        translate                translate a file
        measure                  measure a translation
        help, --help, -h         show this help
        version, --version, -v   show version
    USAGE

  def self.run(options = ARGV)
    new(options).run
  end

  private getter options

  @random_seed_for_random_from_depth = 0

  def initialize(@options : Array(String))
    @use_color = true
  end

  def run
    command = options.first?
    if command
      case
      when "translate".starts_with? command
        options.shift
        translate
      when "measure".starts_with? command
        options.shift
        measure
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
  rescue ex : OptionParser::Exception | Errno
    error ex.message
  rescue ex
    puts ex
    ex.backtrace.each do |frame|
      puts frame
    end
    puts
    error "you've found a bug"
  end

  private def translate
    type = nil
    input_filename = nil
    output_filename = nil
    crop_depth = nil
    weight_step = nil
    scheme_description = nil
    random_seed = RANDOM_SEED_DEFAULT
    crop_depth_unit = nil

    option_parser =
      OptionParser.parse(options) do |opts|
        opts.banner = "Usage: pbtranslator translate [options] [--] [input file]\n\nOptions:"

        opts.on("--network-scheme sorting|random", "Use a sorting network or a random comparator network") do |s|
          scheme_description = s
        end

        opts.on("--type cardinality|optimization|nothing", "Translate cardinality rules, rewrite optimization statements or do nothing") do |t|
          type = t
        end

        opts.on("--crop-depth <d>", "Use first <d> or last -<d> layers of a comparator network. The value <d> can be given as a percentage as well.") do |d|
          if d.ends_with? '%'
            d = d.rchop
            crop_depth_unit = 100
          end
          crop_depth = string_to_i32(d, label: "--crop-depth")
        end

        opts.on("--weight-step <p>", "Place weights on every <p>th layer of a comparator network") do |p|
          weight_step = string_to_i32(p, label: "--weight-step", min: 1)
        end

        opts.on("--random-seed <s>", "Use <s> as a seed for random number generation") do |s|
          random_seed = string_to_i32(s, label: "--random-seed")
        end

        opts.on("-o ", "Output filename") do |o|
          output_filename = o
        end

        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on("--no-color", "Disable colored output") do
          @use_color = false
        end
        opts.unknown_args do |before, after|
          remaining = before + after
          unknown_options, filenames = remaining.partition &.starts_with? "--"
          unless unknown_options.empty?
            error "unknown options: #{unknown_options.join(", ")}"
          end
          case filenames.size
          when 0
          when 1
            input_filename = filenames.first
          else
            error "ambiguous input files: #{filenames.join(", ")}"
          end
        end
      end

    initialize_random_seeds(random_seed)

    scheme = scheme_from_description(scheme_description, crop_depth: crop_depth, crop_depth_unit: crop_depth_unit)

    with_file_or_io(input_filename, "r", STDIN) do |input_io|
      with_file_or_io(output_filename, "w", STDOUT) do |output_io|
        translator_class = translator_class_of(type)
        translator = translator_class.new(input_io, output_io)
        if d = crop_depth
          unless translator.responds_to? :"crop_depth="
            error "the --crop-depth option is not supported with --type #{type}"
          end
          translator.crop_depth = d
        end
        if u = crop_depth_unit
          unless translator.responds_to? :"crop_depth_unit="
            error "the --crop-depth option must be absolute with --type #{type}"
          end
          translator.crop_depth_unit = u
        end
        if translator.responds_to? :"scheme="
          translator.scheme = scheme
        end
        if p = weight_step
          unless translator.responds_to? :"weight_step="
            error "the --weight-step option is not supported with --type #{type}"
          end
          translator.weight_step = p
        end
        if translator.responds_to? :quick_dry_test
          translator.quick_dry_test
        end
        translate(translator)
      end
    end
  end

  private def initialize_random_seeds(random_seed)
    random = Random.new(random_seed)
    @random_seed_for_random_from_depth = random.next_int
  end

  private def scheme_from_description(s : String?, *, crop_depth d, crop_depth_unit u)
    case
    when !s
      Tool::BASE_SCHEME
    when "sorting".starts_with? s
      Tool::BASE_SCHEME
    when "random".starts_with? s
      unless d
        error "the --network-scheme random option works only with --crop-depth"
      end
      if u
        error "the --network-scheme random option works only with an absolute --crop-depth"
      end
      r = Random.new(@random_seed_for_random_from_depth)
      Scheme::RandomFromDepth.new(random: r, depth: Distance.new(d))
    else
      error "unknown argument '#{s}' to --network-scheme"
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

  private def measure
    subject = nil
    output_filename = nil
    parameters = Array(String).new

    option_parser =
      OptionParser.parse(options) do |opts|
        opts.banner = "Usage: pbtranslator measure [options] [--] <parameter>\n\nOptions:"

        opts.on("--subject 'sorting network'", "Measure the size and depth of a sorting network of width <parameter>") do |s|
          subject = s
        end

        opts.on("-o ", "Output filename") do |o|
          output_filename = o
        end

        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on("--no-color", "Disable colored output") do
          @use_color = false
        end
        opts.unknown_args do |before, after|
          parameters = before + after
        end
      end

    unless subject
      error "expected a --subject option"
    end

    unless subject == "sorting network"
      error "subject can only be 'sorting network' at this time, not #{subject}"
    end

    c = parameters.size
    unless c == 1
      error "expected a single mass argument, got #{c}"
    end

    with_file_or_io(output_filename, "w", STDOUT) do |output_io|
      p = Distance.new(parameters.first)
      w = Width.from_value(p)
      s = Tool::BASE_SCHEME
      n = s.network(w)
      size = Network.compute_size(n)
      depth = s.compute_depth(w)
      puts "size: #{size}"
      puts "depth: #{depth}"
    end
  end

  private def string_to_i32(s : String, *, label : String, min bound : Int32 | Nil = nil) : Int32
    unless (i = s.to_i?) && (!bound || bound <= i)
      x =
        case bound
        when 1 then "positive integer"
        when 0 then "nonnegative integer"
        else "signed integer"
        end
      error "#{label} must be a 32 bit #{x}, not \"#{s}\""
    end
    i
  end

  private def error(msg, *, extra = "", exit_code = 1, stderr = STDERR)
    c = @use_color && stderr.tty?
    stderr << "pbtranslator: "
    stderr << "error: ".colorize.toggle(c).red.bold
    stderr << msg
    stderr << "\n"
    stderr << extra
    exit(exit_code)
  end
end
