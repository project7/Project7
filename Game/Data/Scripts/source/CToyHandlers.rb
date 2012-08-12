module CToy
  def self.on_fullscreen
    $syseting[:screen_size]=!$syseting[:screen_size]
    $syseting[:screen_size] ? Graphics.resize_screen(800,600) : Graphics.resize_screen(640,480)
    $syseting[:screen_size] ? RGSSX.resize_window(800,600) : RGSSX.resize_window(640,480)
  end
  def self.on_f1
    msgbox "you pressed f1"
  end
  def self.on_f2
    his =  CToy.fps_history
    msgbox "average: #{his.inject{|k,v|k+=v} / his.size.to_f} FPS\nlast #{his.size} times: #{his.join ", "}"
  end
end