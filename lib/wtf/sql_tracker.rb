module WTF
  module SqlTracker
    class << self
      attr_reader :trackable

      def start_tracking(sql)
        if @trackable.nil?
          prepare_hook
          @trackable = {}
        end
        @trackable[sql] = true
      end

      def prepare_hook
        ActiveRecord::ConnectionAdapters::AbstractAdapter.module_eval %{
          module TrackingSQL
            def log(sql, *args, &block)
              WTF::SQLTracker.on_sql(sql)
              super(sql, *args, &block)
            end
          end
          prepend TrackingSQL
        }
      end

      def on_sql(sql)
        if trackable[sql]
          WTF::Dumper.new(:sql, sql, *caller.take(30), :line)
        end
      end
    end
  end
end
