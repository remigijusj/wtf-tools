module WTF
  module QueryTracker
    Trackable = Struct.new(:pattern, :options)

    class << self
      attr_reader :trackables

      def start_tracking(pattern, options = {})
        if @trackables.nil?
          prepare_hook
          @trackables = []
        end
        @trackables << Trackable.new(pattern, options)
      end

      def prepare_hook
        ActiveRecord::ConnectionAdapters::AbstractAdapter.module_eval %{
          module TrackingSQL
            def log(sql, *args, &block)
              WTF::QueryTracker.on_sql(sql)
              super(sql, *args, &block)
            end
          end
          prepend TrackingSQL
        }
      end

      def on_sql(sql)
        trackables.each do |it|
          if match(it.pattern, sql)
            WTF::Dumper.new(:sql, sql, *caller.take(it.options[:size] || 30), :line)
          end
        end
      end

      def match(pattern, sql)
        case pattern
        when Regexp
          pattern.match(sql)
        when String
          pattern == sql
        when Proc
          pattern.call(sql)
        end
      end
    end
  end
end
