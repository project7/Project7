module CToy
  def self.disable_transition
    @fuckedtransition = true
  end
  def self.enable_transition
    @fuckedtransition = false
  end
  def self.fucked_transition
    @fuckedtransition
  end
  def self.disable_fullscreen
    @fucked = true
  end
  def self.enable_fullscreen
    @fucked = false
  end
  def self.on_fullscreen
    return if @fucked
    $syseting[:screen_size]=!$syseting[:screen_size]
    $syseting[:screen_size] ? Graphics.resize_screen(800,608) : Graphics.resize_screen(640,480)
    SceneManager.scene.spriteset.adapt_screen rescue nil
    SceneManager.scene.adapt_screen rescue nil
    LogoSceneManager.scene.adapt_screen rescue nil
    $syseting[:screen_size] ? RGSSX.resize_window(800,608) : RGSSX.resize_window(640,480)
  end
  def self.on_f1
    his =  CToy.fps_history
    Graphics.update
    msgbox "当前: #{RGSSX.fps} FPS\n平均: #{his.inject{|k,v|k+=v} / his.size.to_f} FPS\n历史: \n#{his.each_slice(10).map{|sl|sl.join ", "}.join("\n")}"
  end
end

class << Graphics
  alias transition_fuck transition
  def transition(*args)
    return if CToy.fucked_transition
    transition_fuck(*args)
    CToy.enable_fullscreen
  end
  
  alias freeze_fuck freeze
  def freeze(*args)
    return if CToy.fucked_transition
    CToy.disable_fullscreen
    freeze_fuck(*args)
  end
end