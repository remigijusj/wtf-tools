module WTF
  module MethodTracker
    class << self
      def start_tracking(*objects)
        require 'absolute_time'

        objects.each do |object|
          klass = object.is_a?(Module) ? object : object.class
          prepare(klass)
        end
        reset_state
      end

      def prepare(base)
        methods = base.instance_methods(false) + base.private_instance_methods(false)
        compiled = methods.map do |name|
          override_method(base, name)
        end
        base.module_eval %{
          module Tracking
            #{compiled.join}
          end
          prepend Tracking
        }
      end

      def override_method(base, name)
        %{
          def #{name}(*args)
            WTF::MethodTracker.on_start(#{base}, :#{name})
            return_value = super
            WTF::MethodTracker.on_end
            return_value
          end
        }
      end

      attr_accessor :stats, :stack, :last_time, :last_heap

      def reset_state
        self.stats = Hash.new { |h,k| h[k] = { freq: 0, time: 0.0, heap: 0 } }
        self.stack = [[nil, :top]]
        self.last_time = AbsoluteTime.now
        self.last_heap = GC.stat[:heap_length]
      end

      def on_start(*full_name)
        add_stats(full_name)
        stack.push(full_name)
      end

      def on_end
        add_stats
        stack.pop
      end

      def finish
        add_stats
        dump_stats
        reset_state
      end

      def add_stats(at_start = nil)
        stat = stats[stack.last]

        this_time = AbsoluteTime.now
        stat[:time] += this_time - last_time
        self.last_time = this_time

        this_heap = GC.stat[:heap_length]
        stat[:heap] += this_heap - last_heap
        self.last_heap = this_heap

        stats[at_start][:freq] += 1 if at_start
      end

      def dump_stats
        data = stats.map do |key, val|
          [*key, val[:freq].to_i, val[:time].to_f.round(3), (val[:heap].to_f / 64).round(3)]
        end
        data = data.sort_by {|it| it[3] }.reverse
        data.unshift(%w(class method count time heap_mb))

        time = Time.now.strftime('%m%d_%H%M%S')
        file = File.join(WTF.files_path, "track_#{time}_#{rand(10000)}.csv")
        File.write(file, data.map(&:to_csv).join)
      end
    end
  end
end
