module WTF
  class Dumper
    PREFIX_OPTIONS = [:time, :nl, :np].freeze
    FORMAT_OPTIONS = [:pp, :yaml, :json, :text, :line, :csv].freeze
    MODIFY_OPTIONS = [:bare, :name].freeze
    OUTPUT_OPTIONS = [:puts, :error, :file].freeze

    OPTIONS = (PREFIX_OPTIONS + FORMAT_OPTIONS + MODIFY_OPTIONS + OUTPUT_OPTIONS).freeze

    attr_reader :args, :options

    def initialize(*args)
      @args = args
      @options = {}
      while is_option?(args.last)
        @options[args.pop] = true
      end
    end

    def call
      where, names = parse_source(caller[1])
      data = prefix(where) << format(names)
      output(data)
    end

    private

    def is_option?(sym)
      OPTIONS.include?(sym) or WTF.output_options.key?(sym)
    end

    def prefix(where)
      data = ''
      data << "\n" if options[:nl]
      data << "[%s] " % Time.now if options[:time]
      return data if options[:np]
      data << if args.first.is_a?(Symbol)
        args.shift.to_s.upcase
      else
        "WTF (#{where})"
      end
      data << ': '
    end

    def parse_source(item)
      md = item.match(%r{^(.*?([^/]+?)(?:\.rb)?):(\d+):in `(.*)'$})
      where = '%s/%s:%s' % md.values_at(2, 4, 3)
      names = parse_names(read_source(md[1], md[3].to_i)) if options[:name]
      [where, names]
    end

    def read_source(file, line)
      File.open(file).each_line.lazy.take(line).to_a[line-1]
    end

    def parse_names(source)
      return nil unless source
      md = source.match(/(\.wtf\(|WTF\?\(?)(.*?)\s*(?:if |unless |$)/)
      return nil unless md
      names = md[2].split(',').map(&:strip) # naive
      names.unshift('self') if md[1] == '.wtf('
      names
    end

    def format(names)
      return format_with_names(names) if names

      case
      when options[:pp]
        cleanup(args.pretty_inspect, options[:bare])
      when options[:yaml]
        YAML.dump(args)
      when options[:json]
        JSON::pretty_generate(args)
      when options[:text]
        args.map(&:to_s).join("\n")
      when options[:line]
        args.map(&:inspect).join("\n  ")
      when options[:csv]
        args.first.map(&:to_csv).join
      else
        cleanup(args.inspect, options[:bare])
      end
    end

    def format_with_names(names)
      len = names.map(&:length).max
      args.each_with_object('').with_index do |(arg, data), i|
        name = names[i] || '?'
        data << "\n" << "  %-#{len}s => %s" % [name, arg.inspect]
      end
    end

    def cleanup(str, bare = false)
      # remove array parentheses
      str.gsub!(/^\[|\]$/,'')
      # ActiveRecord no attributes
      str.gsub!(/#<[A-Z]\w+ id: \d+\K.*?>/, '>') if bare
      str
    end

    def output(data)
      selected = (OUTPUT_OPTIONS + WTF.output_options.keys).select { |how| options[how] }
      selected << :default if selected.empty?
      proxy = Output.new(data)
      selected.each do |how|
        proxy.call(how)
      end
    end

    class Output
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def call(meth)
        if block = WTF.output_options[meth]
          block.call(data)
        else
          send(meth)
        end
      end

      private

      def puts
        STDOUT.puts(data)
      end
      alias_method :default, :puts

      def file
        time = Time.now.strftime('%m%d_%H%M%S')
        file = File.join(WTF.files_path, "wtf_#{time}_#{rand(10000)}.txt")
        File.write(file, data)
      end

      def error
        raise StandardError, data
      end
    end
  end
end
