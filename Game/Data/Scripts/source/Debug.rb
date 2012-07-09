
module Debug
  def self.stop_trace
    set_trace_func(nil)
  end
  def self.start_trace
    set_trace_func(lambda{|*x|p x})
  end
end
