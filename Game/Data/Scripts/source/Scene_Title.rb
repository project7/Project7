#encoding:utf-8
#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　标题画面
#==============================================================================

class Scene_Title < Scene_Base
  def start
    @viewport = Viewport.new
    @viewport.tone.set(0, 0, 0, 0)
    
    DataManager.setup_new_game
    super
    create_particle
    SceneManager.clear
    Graphics.freeze
    create_background
    play_title_music
    @count = 0
  end
  def update
    super
    @count += 1
    $MIST.update rescue nil
    if @count > 150
      command_new_game
      return
    end
    if CInput.trigger?($vkey[:Check])
      command_continue
      return
    end
  end
  def create_particle
    if $MIST
      $MIST.dispose rescue nil
    end
    $MIST= PTCF.new(1)
    $MIST.set_all(PTCF::MistLight)
  end
  def dispose_particle
    $MIST.dispose
    $MIST = nil
  end
  def adapt_screen
    dispose_particle
    create_particle
  end
  def terminate
    super
    SceneManager.snapshot_for_background
    dispose_background
    #dispose_particle
  end
  #--------------------------------------------------------------------------
  # ● 获取渐变速度
  #--------------------------------------------------------------------------
  def transition_speed
    return 20
  end
  #--------------------------------------------------------------------------
  # ● 生成背景
  #--------------------------------------------------------------------------
  def create_background
    @sprite1 = Sprite.new(@viewport)
    @sprite1.bitmap = Cache.system("mist")
    @sprite2 = Sprite.new(@viewport)
    @sprite2.bitmap = Cache.system("title_logo")
    center_sprite(@sprite1)
    center_sprite(@sprite2)
    
    @sprite3 = Sprite.new(@viewport)
    @sprite3.bitmap = Cache.system("title_load")
    center_load_sprite
  end
  #--------------------------------------------------------------------------
  # ● 释放背景
  #--------------------------------------------------------------------------
  def dispose_background
    @sprite1.bitmap.dispose
    @sprite1.dispose
    @sprite2.bitmap.dispose
    @sprite2.dispose
  end
  #--------------------------------------------------------------------------
  # ● 执行精灵居中
  #--------------------------------------------------------------------------
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
  end
  def center_load_sprite
    @sprite3.ox = @sprite3.bitmap.width / 2
    @sprite3.oy = @sprite3.bitmap.height / 2
    @sprite3.x = Graphics.width / 2
    @sprite3.y = Graphics.height / 2 + 200
  end
  #--------------------------------------------------------------------------
  # ● 指令“开始游戏”
  #--------------------------------------------------------------------------
  def command_new_game
    Thread.new do
      $game_map.autoplay
    end
    openness = 0
    loop do |i|
      openness -= 3
      openness = -255 if openness < -255
      @viewport.tone.set(openness, openness, openness, 0)
      Graphics.update
      $MIST.update
      break if openness == -255
    end
    $NEWGAME = true
    CToy.disable_fullscreen
    CToy.disable_transition
    SceneManager.goto(Scene_Map)
  end
  #--------------------------------------------------------------------------
  # ● 指令“继续游戏”
  #--------------------------------------------------------------------------
  def command_continue
    SceneManager.call(Scene_Load)
  end
  #--------------------------------------------------------------------------
  # ● 指令“退出游戏”
  #--------------------------------------------------------------------------
  def command_shutdown
    SceneManager.exit
  end
  #--------------------------------------------------------------------------
  # ● 播放标题画面音乐
  #--------------------------------------------------------------------------
  def play_title_music
    $data_system.title_bgm.play
    RPG::BGS.stop
    RPG::ME.stop
  end
end
