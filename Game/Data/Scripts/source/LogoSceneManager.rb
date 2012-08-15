module LogoSceneManager
  SCENES = [
    LogoScene_Mist,
    LogoScene_Moe9th,
    LogoScene_66RPG
  ]
end
class << LogoSceneManager
  include LogoSceneManager
  
  attr_accessor :scene
  
  def run
    $SKIPLOGO = true
    SCENES.each do |i|
      @scene = i.new
      @scene.main
    end
  end
end

#LogoSceneManager.run unless $SKIPLOGO