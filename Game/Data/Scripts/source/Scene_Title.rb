﻿#encoding:utf-8
#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　标题画面
#==============================================================================

class Scene_Title < Scene_Base
  def start
    @viewport = Viewport.new
    @viewport.tone.set(0, 0, 0, 0)
    @has_been_saved = DataManager.save_file_exists?
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
    @mist.update
    if @count > 150
      command_new_game
      return
    end
    if @has_been_saved && CInput.trigger?($vkey[:Check])
      command_continue
      return
    end
  end
  def create_particle
    if @mist
      @mist.dispose rescue nil
    end
    @mist= PTCF.new(1,@viewport)
    @mist.set_all(PTCF::MistLight)
  end
  def dispose_particle
    @mist.dispose
    @mist = nil
  end
  def adapt_screen
    @viewport.rect.width = Graphics.width
    @viewport.rect.height = Graphics.height
    dispose_particle
    create_particle
    center_sprite(@sprite1)
    center_sprite(@sprite2)
    center_load_sprite
  end
  def terminate
    super
    @viewport.dispose
    SceneManager.snapshot_for_background
    dispose_background
    dispose_particle
    GC.start
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
    @sprite3.bitmap = @has_been_saved ? Cache.system("title_load") : Bitmap.new(1,1)
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
    @sprite3.bitmap.dispose
    @sprite3.dispose
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
    CToy.disable_fullscreen
    Thread.new do
      $game_map.autoplay
    end
    openness = 255
    loop do |i|
      openness -= 3
      openness = 0 if openness < 0
      @sprite3.opacity = openness
      Graphics.update
      @mist.update
      break if openness == 0
    end
    openness = 0
    loop do |i|
      openness -= 3
      openness = -255 if openness < -255
      @viewport.tone.set(openness, openness, openness, 0)
      Graphics.update
      @mist.update
      break if openness == -255
    end
    $NEWGAME = true
    CToy.disable_transition
    SceneManager.goto(Scene_Map)
  end
  #--------------------------------------------------------------------------
  # ● 指令“继续游戏”
  #--------------------------------------------------------------------------
  def command_continue
    return unless DataManager.load_game(0)
    fadeout_all
    $game_system.on_after_load
    SceneManager.goto(Scene_Map)
    #SceneManager.call(Scene_Load)
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
