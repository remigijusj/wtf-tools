module WTF
  class Dumper
    OPTIONS = [
      :time, :nl, :no,                       # prefix
      :pp, :yaml, :json, :text, :line, :csv, # format
      :bare,                                 # modify
      :page, :file, :raise, :redis, :log,    # output
    ].freeze

    attr_reader :options

    def initialize(*args)
      @options = {}
      while OPTIONS.include?(args.last)
        @options[args.pop] = true
      end

      data = prefix(args) << format(args)
      output(data)
    end

    private

    def prefix(args)
      data = ''
      return data if options[:no]
      data << "\n" if options[:nl]
      data << "[%s] " % Time.now if options[:time]
      data << if args[0].is_a?(Symbol)
        args.shift.to_s.upcase
      else
        pattern = %r{([^/]+?)(?:\.rb)?:(\d+):in `(.*)'$}  # '
        "WTF (%s/%s:%s)" % caller[3].match(pattern).values_at(1,3,2)
      end
      data << ': '
    end

    def format(args)
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
        args[0].map(&:to_csv).join
      else
        cleanup(args.inspect, options[:bare])
      end
    end

    def output(data)
      case
      when options[:page]
        (Thread.current[:wtf] ||= []) << data
      when options[:file]
        time = Time.now.strftime('%m%d_%H%M%S')
        file = "#{WTF.files_path}/wtf_#{time}_#{rand(10000)}.txt"
        File.write(file, data)
      when options[:raise]
        raise StandardError, data
      when options[:redis]
        WTF.options[:redis].rpush('wtf', data)
        WTF.options[:redis].expire('wtf', 30*60)
      when options[:log]
        Rails.logger.info(data)
      when WTF.options[:default]
        WTF.options[:default].info(data)
      else
        puts data
      end
    end

    def cleanup(str, bare = false)
      # remove array parentheses
      str.gsub!(/^\[|\]$/,'')
      # ActiveRecord no attributes
      str.gsub!(/#<[A-Z]\w+ id: \d+\K.*?>/, '>') if bare
      str
    end
  end
end
