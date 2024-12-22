# Similar to Concurrent::TimerTask but execution can be paused from the task
# and resumed again
# Additional thread can be stopped with #stop_thread only once, then the object
# becomes unusuable (u can easily add start-thread-again functionality if u need)
class PausableTimerTask
  def initialize(execution_interval, start_immediately = false)
    @execution_interval = execution_interval

    @paused = !start_immediately
    @stopped = false

    @m = Mutex.new
    @thread = Thread.new do
      while true
        var_paused = nil
        var_stop = nil
        var_execution_interval = nil

        @m.synchronize do
          var_paused = @paused
          var_stop = @stopped
          var_execution_interval = @execution_interval
        end

        break if var_stop

        if var_paused
          sleep 0.2
        else
          sleep var_execution_interval
          yield self
        end
      end
    end
  end

  def execution_interval=(value)
    @m.synchronize { @execution_interval = value }
  end

  # Start/stop task
  def resume
    @m.synchronize { @paused = false }
  end

  def pause
    @m.synchronize { @paused = true }
  end

  def paused?
    @m.synchronize { @paused }
  end

  # Stop thread (one-time use)
  def stop_thread
    @m.synchronize { @stopped = true }
  end

  def thread_stopped?
    @m.synchronize { @stopped }
  end
end
