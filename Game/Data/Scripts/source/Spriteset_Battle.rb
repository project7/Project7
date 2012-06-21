#encoding:utf-8
#==============================================================================
# ■ Spriteset_Battle
#------------------------------------------------------------------------------
# 　处理战斗画面的精灵的类。本类在 Scene_Battle 类的内部使用。
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    create_viewports
    create_battleback1
    create_battleback2
    create_enemies
    create_actors
    create_pictures
    create_timer
    update
  end
  #--------------------------------------------------------------------------
  # ● 生成显示端口
  #--------------------------------------------------------------------------
  def create_viewports
    @viewport1 = Viewport.new
    @viewport2 = Viewport.new
    @viewport3 = Viewport.new
    @viewport2.z = 50
    @viewport3.z = 100
  end
  #--------------------------------------------------------------------------
  # ● 生成战场背景（地面）精灵
  #--------------------------------------------------------------------------
  def create_battleback1
    @back1_sprite = Sprite.new(@viewport1)
    @back1_sprite.bitmap = battleback1_bitmap
    @back1_sprite.z = 0
    center_sprite(@back1_sprite)
  end
  #--------------------------------------------------------------------------
  # ● 生成战场背景（墙壁）精灵
  #--------------------------------------------------------------------------
  def create_battleback2
    @back2_sprite = Sprite.new(@viewport1)
    @back2_sprite.bitmap = battleback2_bitmap
    @back2_sprite.z = 1
    center_sprite(@back2_sprite)
  end
  #--------------------------------------------------------------------------
  # ● 获取战场背景（地面）的位图
  #--------------------------------------------------------------------------
  def battleback1_bitmap
    if battleback1_name
      Cache.battleback1(battleback1_name)
    else
      create_blurry_background_bitmap
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取战场背景（墙壁）的位图
  #--------------------------------------------------------------------------
  def battleback2_bitmap
    if battleback2_name
      Cache.battleback2(battleback2_name)
    else
      Bitmap.new(1, 1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成由地图画面加工而来的战场背景
  #--------------------------------------------------------------------------
  def create_blurry_background_bitmap
    source = SceneManager.background_bitmap
    bitmap = Bitmap.new(640, 480)
    bitmap.stretch_blt(bitmap.rect, source, source.rect)
    bitmap.radial_blur(120, 16)
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 获取战场背景（地面）的文件名
  #--------------------------------------------------------------------------
  def battleback1_name
    if $BTEST
      $data_system.battleback1_name
    elsif $game_map.battleback1_name
      $game_map.battleback1_name
    elsif $game_map.overworld?
      overworld_battleback1_name
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取战场背景（墙壁）的文件名
  #--------------------------------------------------------------------------
  def battleback2_name
    if $BTEST
      $data_system.battleback2_name
    elsif $game_map.battleback2_name
      $game_map.battleback2_name
    elsif $game_map.overworld?
      overworld_battleback2_name
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取战场背景（地面）文件名
  #--------------------------------------------------------------------------
  def overworld_battleback1_name
    $game_player.vehicle ? ship_battleback1_name : normal_battleback1_name
  end
  #--------------------------------------------------------------------------
  # ● 获取战场背景（墙壁）文件名
  #--------------------------------------------------------------------------
  def overworld_battleback2_name
    $game_player.vehicle ? ship_battleback2_name : normal_battleback2_name
  end
  #--------------------------------------------------------------------------
  # ● 获取普通时的战场背景（地面）文件名
  #--------------------------------------------------------------------------
  def normal_battleback1_name
    terrain_battleback1_name(autotile_type(1)) ||
    terrain_battleback1_name(autotile_type(0)) ||
    default_battleback1_name
  end
  #--------------------------------------------------------------------------
  # ● 获取普通时的战场背景（墙壁）文件名
  #--------------------------------------------------------------------------
  def normal_battleback2_name
    terrain_battleback2_name(autotile_type(1)) ||
    terrain_battleback2_name(autotile_type(0)) ||
    default_battleback2_name
  end
  #--------------------------------------------------------------------------
  # ● 获取与地形对应的战场背景（地面）文件名
  #--------------------------------------------------------------------------
  def terrain_battleback1_name(type)
    case type
    when 24,25        # 野外
      "Wasteland"
    when 26,27        # 泥地
      "DirtField"
    when 32,33        # 沙漠
      "Desert"
    when 34           # 岩地
      "Lava1"
    when 35           # 岩地（熔岩）
      "Lava2"
    when 40,41        # 雪原
      "Snowfield"
    when 42           # 云端
      "Clouds"
    when 4,5          # 毒沼
      "PoisonSwamp"
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取与地形对应的战场背景（墙壁）文件名
  #--------------------------------------------------------------------------
  def terrain_battleback2_name(type)
    case type
    when 20,21        # 森林
      "Forest1"
    when 22,30,38     # 山丘
      "Cliff"
    when 24,25,26,27  # 野外、泥地
      "Wasteland"
    when 32,33        # 沙漠
      "Desert"
    when 34,35        # 岩地
      "Lava"
    when 40,41        # 雪原
      "Snowfield"
    when 42           # 云端
      "Clouds"
    when 4,5          # 毒沼
      "PoisonSwamp"
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取默认的战场背景（地面）文件名
  #--------------------------------------------------------------------------
  def default_battleback1_name
    "Grassland"
  end
  #--------------------------------------------------------------------------
  # ● 获取默认的战场背景（墙壁）文件名
  #--------------------------------------------------------------------------
  def default_battleback2_name
    "Grassland"
  end
  #--------------------------------------------------------------------------
  # ● 获取乘船时的战场背景（地面）文件名
  #--------------------------------------------------------------------------
  def ship_battleback1_name
    "Ship"
  end
  #--------------------------------------------------------------------------
  # ● 获取乘船时的战场背景（墙壁）文件名
  #--------------------------------------------------------------------------
  def ship_battleback2_name
    "Ship"
  end
  #--------------------------------------------------------------------------
  # ● 获取角色脚下的自动原件的种类
  #--------------------------------------------------------------------------
  def autotile_type(z)
    $game_map.autotile_type($game_player.x, $game_player.y, z)
  end
  #--------------------------------------------------------------------------
  # ● 精灵居中
  #--------------------------------------------------------------------------
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
  end
  #--------------------------------------------------------------------------
  # ● 敌人精灵生成
  #--------------------------------------------------------------------------
  def create_enemies
    @enemy_sprites = $game_troop.members.reverse.collect do |enemy|
      Sprite_Battler.new(@viewport1, enemy)
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成角色精灵
  #    默认下不显示角色的图像。为了方便使用，敌我双方使用共通的精灵。
  #--------------------------------------------------------------------------
  def create_actors
    @actor_sprites = Array.new(4) { Sprite_Battler.new(@viewport1) }
  end
  #--------------------------------------------------------------------------
  # ● 生成图片精灵
  #    游戏开始时生成空的数组，在需要使用时才添加内容。
  #--------------------------------------------------------------------------
  def create_pictures
    @picture_sprites = []
  end
  #--------------------------------------------------------------------------
  # ● 计时器精灵生成
  #--------------------------------------------------------------------------
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    dispose_battleback1
    dispose_battleback2
    dispose_enemies
    dispose_actors
    dispose_pictures
    dispose_timer
    dispose_viewports
  end
  #--------------------------------------------------------------------------
  # ● 释放战场背景的精灵（地面）
  #--------------------------------------------------------------------------
  def dispose_battleback1
    @back1_sprite.bitmap.dispose
    @back1_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 释放战场背景的精灵（墙壁）
  #--------------------------------------------------------------------------
  def dispose_battleback2
    @back2_sprite.bitmap.dispose
    @back2_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 释放敌人精灵
  #--------------------------------------------------------------------------
  def dispose_enemies
    @enemy_sprites.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 释放角色精灵
  #--------------------------------------------------------------------------
  def dispose_actors
    @actor_sprites.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 释放图片精灵
  #--------------------------------------------------------------------------
  def dispose_pictures
    @picture_sprites.compact.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 释放计时器精灵
  #--------------------------------------------------------------------------
  def dispose_timer
    @timer_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 释放显示端口
  #--------------------------------------------------------------------------
  def dispose_viewports
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    update_battleback1
    update_battleback2
    update_enemies
    update_actors
    update_pictures
    update_timer
    update_viewports
  end
  #--------------------------------------------------------------------------
  # ● 更新战场背景的精灵（地面）
  #--------------------------------------------------------------------------
  def update_battleback1
    @back1_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新战场背景的精灵（墙壁）
  #--------------------------------------------------------------------------
  def update_battleback2
    @back2_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新敌人的精灵
  #--------------------------------------------------------------------------
  def update_enemies
    @enemy_sprites.each {|sprite| sprite.update }
  end
  #--------------------------------------------------------------------------
  # ● 更新角色的精灵
  #--------------------------------------------------------------------------
  def update_actors
    @actor_sprites.each_with_index do |sprite, i|
      sprite.battler = $game_party.members[i]
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新图片精灵
  #--------------------------------------------------------------------------
  def update_pictures
    $game_troop.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport2, pic)
      @picture_sprites[pic.number].update
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新计时器精灵
  #--------------------------------------------------------------------------
  def update_timer
    @timer_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新显示端口
  #--------------------------------------------------------------------------
  def update_viewports
    @viewport1.tone.set($game_troop.screen.tone)
    @viewport1.ox = $game_troop.screen.shake
    @viewport2.color.set($game_troop.screen.flash_color)
    @viewport3.color.set(0, 0, 0, 255 - $game_troop.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人和角色的精灵
  #--------------------------------------------------------------------------
  def battler_sprites
    @enemy_sprites + @actor_sprites
  end
  #--------------------------------------------------------------------------
  # ● 判定是否动画显示中
  #--------------------------------------------------------------------------
  def animation?
    battler_sprites.any? {|sprite| sprite.animation? }
  end
  #--------------------------------------------------------------------------
  # ● 判定效果是否执行中
  #--------------------------------------------------------------------------
  def effect?
    battler_sprites.any? {|sprite| sprite.effect? }
  end
end
