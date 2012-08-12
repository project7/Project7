class Array
  def included?(arr)
    arr.each do |i|
      if self.include?(i)
        return true
      end
    end
    return false
  end
end
=begin
module Audio
  class << Audio
    
    alias bgm_v bgm_play
    def bgm_play(filename,value=100,pitch=100)
      bgm_v(filename,value*$syseting[:bgm_value]/100,pitch)
    end

  end
end
=end