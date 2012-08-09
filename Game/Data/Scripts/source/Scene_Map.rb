﻿#encoding:utf-8
#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　地图画面
#==============================================================================

class Scene_Map < Scene_Base

  attr_accessor :spriteset
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    SceneManager.clear
    $game_player.straighten
    $game_map.refresh
    $game_message.visible = false
    create_spriteset
    create_all_windows
    @menu_calling = false
  end
  #--------------------------------------------------------------------------
  # ● 执行进入场景时的渐变
  #--------------------------------------------------------------------------
  def perform_transition
    if Graphics.brightness == 0
      Graphics.transition(0)
      fadein(fadein_speed)
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取渐变速度
  #--------------------------------------------------------------------------
  def transition_speed
    return 15
  end
  #--------------------------------------------------------------------------
  # ● 结束前处理
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    pre_battle_scene if SceneManager.scene_is?(Scene_Battle)
    pre_title_scene  if SceneManager.scene_is?(Scene_Title)
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  def terminate
    super
    SceneManager.snapshot_for_background
    dispose_spriteset
    perform_battle_transition if SceneManager.scene_is?(Scene_Battle)
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    $game_map.update(true)
    $game_player.update
    $game_timer.update
    @spriteset.update
    update_ui
    update_scene if scene_change_ok?
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update_ui
    if !$game_message.busy? && !$game_message.visible
      if mouse_in_itemrect?
        @spriteset.tipsvar[1][0] = false
        tempa = item_mouse_index
        if tempa
          @spriteset.tipsvar[2][0] = true
          @spriteset.tipsvar[2][1] = tempa
        else
          @spriteset.tipsvar[2][0] = false
        end
      else
        @spriteset.tipsvar[1][0] = true
      end
      if mouse_in_skillrect?
        @spriteset.tipsvar[16] = true
        tempb = skill_mouse_index
        if tempb
          @spriteset.tipsvar[17][0] = true
          @spriteset.tipsvar[17][1] = tempb
        else
          @spriteset.tipsvar[17][0] = false
        end
      else
        @spriteset.tipsvar[16] = false
      end
    else
      @spriteset.tipsvar[1][0] = true
      @spriteset.tipsvar[16] = false
    end
  end
  
  def mouse_in_itemrect?
    tpos = Mouse.pos
    if tpos[0]>=@spriteset.tips[1].x&&tpos[0]<=@spriteset.tips[1].x+205&&tpos[1]>=@spriteset.tips[1].y+4&&tpos[1]<=@spriteset.tips[1].y+57
      return true
    else
      return false
    end
  end
  
  def item_mouse_index
    tpos = Mouse.pos
    [*0..3].each do |i|
      rx = @spriteset.tips[1].x+5+i*41
      ry = @spriteset.tips[1].y+12
      if tpos[0]>=rx&&tpos[0]<=rx+36&&tpos[1]>=ry&&tpos[1]<=ry+36
        return i
      end
    end
    return false
  end
  
  def mouse_in_skillrect?
    tpos = Mouse.pos
    if tpos[0]>=@spriteset.tips[15].x&&tpos[0]<=@spriteset.tips[15].x+136&&tpos[1]>=@spriteset.tips[15].y&&tpos[1]<=@spriteset.tips[15].y+136
      return true
    else
      return false
    end
  end
  
  def skill_mouse_index
    tpos = Mouse.pos
    [*0..5].each do |i|
      rx = @spriteset.tips[15].x+Fuc::UI_SKILL_POS[i][0]
      ry = @spriteset.tips[15].y+Fuc::UI_SKILL_POS[i][1]
      if tpos[0]>=rx&&tpos[0]<=rx+38&&tpos[1]>=ry&&tpos[1]<=ry+38
        return i
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 判定是否可以切换场景
  #--------------------------------------------------------------------------
  def scene_change_ok?
    !$game_message.busy? && !$game_message.visible
  end
  #--------------------------------------------------------------------------
  # ● 更新场景消退时的过渡
  #--------------------------------------------------------------------------
  def update_scene
    check_gameover
    update_transfer_player unless scene_changing?
    update_encounter unless scene_changing?
    update_call_menu unless scene_changing?
    update_call_debug unless scene_changing?
    if $game_switches[1]
      $map_battle.update unless scene_changing?
    else
      move_by_input
      update_mouse_event unless scene_changing?
    end
  end
  #--------------------------------------------------------------------------
  # ● 由方向键移动
  #--------------------------------------------------------------------------
  def move_by_input
    return if $game_map.interpreter.running?
    if $game_player.movable?
      if CInput.dir4 > 0
        $game_player.move_straight(CInput.dir4)
        $game_player.auto_move_path=[]
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新非战斗时鼠标点击事件
  #--------------------------------------------------------------------------
  def update_mouse_event
    if Mouse.click?(1)                                
      if mouse_in_itemrect?
        
      elsif mouse_in_skillrect?
        
      else  #鼠标点击寻路
        x_dis = $game_player.x-Fuc.getpos_by_screenpos(Mouse.pos)[0]
        y_dis = $game_player.y-Fuc.getpos_by_screenpos(Mouse.pos)[1]
        if x_dis.abs+y_dis.abs == 1 && $game_player.movable?
          dir = Fuc::DIR_LIST[x_dis][y_dis]
          if $game_player.direction == dir && !$game_player.passable?($game_player.x, $game_player.y, dir)
            $game_player.check_action_event
          else
            $game_player.move_straight(dir)
          end
        elsif x_dis.abs+y_dis.abs > 1
          Fuc.sm(*Fuc.getpos_by_screenpos(Mouse.pos))
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新画面（消退用）
  #--------------------------------------------------------------------------
  def update_for_fade
    update_basic
    $game_map.update(false)
    @spriteset.update
  end
  #--------------------------------------------------------------------------
  # ● 通用的消退处理
  #--------------------------------------------------------------------------
  def fade_loop(duration)
    duration.times do |i|
      yield 255 * (i + 1) / duration
      update_for_fade
    end
  end
  #--------------------------------------------------------------------------
  # ● 淡入画面
  #--------------------------------------------------------------------------
  def fadein(duration)
    fade_loop(duration) {|v| Graphics.brightness = v }
  end
  #--------------------------------------------------------------------------
  # ● 淡出画面
  #--------------------------------------------------------------------------
  def fadeout(duration)
    fade_loop(duration) {|v| Graphics.brightness = 255 - v }
  end
  #--------------------------------------------------------------------------
  # ● 淡入画面（白）
  #--------------------------------------------------------------------------
  def white_fadein(duration)
    fade_loop(duration) {|v| @viewport.color.set(255, 255, 255, 255 - v) }
  end
  #--------------------------------------------------------------------------
  # ● 淡出画面（白）
  #--------------------------------------------------------------------------
  def white_fadeout(duration)
    fade_loop(duration) {|v| @viewport.color.set(255, 255, 255, v) }
  end
  #--------------------------------------------------------------------------
  # ● 生成精灵组
  #--------------------------------------------------------------------------
  def create_spriteset
    @spriteset = Spriteset_Map.new
  end
  #--------------------------------------------------------------------------
  # ● 释放精灵组
  #--------------------------------------------------------------------------
  def dispose_spriteset
    @spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 生成所有窗口
  #--------------------------------------------------------------------------
  def create_all_windows
    create_message_window
    create_scroll_text_window
    create_location_window
  end
  #--------------------------------------------------------------------------
  # ● 生成信息窗口
  #--------------------------------------------------------------------------
  def create_message_window
    @message_window = Window_Message.new
  end
  #--------------------------------------------------------------------------
  # ● 生成滚动文字窗口
  #--------------------------------------------------------------------------
  def create_scroll_text_window
    @scroll_text_window = Window_ScrollText.new
  end
  #--------------------------------------------------------------------------
  # ● 生成地图名称窗口
  #--------------------------------------------------------------------------
  def create_location_window
    @map_name_window = Window_MapName.new
  end
  #--------------------------------------------------------------------------
  # ● 监听场所移动指令
  #--------------------------------------------------------------------------
  def update_transfer_player
    perform_transfer if $game_player.transfer?
  end
  #--------------------------------------------------------------------------
  # ● 监听遇敌事件
  #--------------------------------------------------------------------------
  def update_encounter
    SceneManager.call(Scene_Battle) if $game_player.encounter
  end
  #--------------------------------------------------------------------------
  # ● 监听取消键的按下。如果菜单可用且地图上没有事件在运行，则打开菜单界面。
  #--------------------------------------------------------------------------
  def update_call_menu
    if $game_system.menu_disabled || $game_map.interpreter.running? || $map_battle
      @menu_calling = false
    else
      @menu_calling ||= CInput.trigger?($vkey[:X]) || Mouse.down?(2)
      call_menu if @menu_calling && !$game_player.moving?
    end
  end
  #--------------------------------------------------------------------------
  # ● 打开菜单画面
  #--------------------------------------------------------------------------
  def call_menu
    Sound.play_ok
    SceneManager.call(Scene_Menu)
    Window_MenuCommand::init_command_position
  end
  #--------------------------------------------------------------------------
  # ● 监听 F9 的按下。如果是游戏测试的情况下，则打开调试界面
  #--------------------------------------------------------------------------
  def update_call_debug
    SceneManager.call(Scene_Debug) if $TEST && CInput.press?($vkey[:Test])
  end
  #--------------------------------------------------------------------------
  # ● 处理场所移动
  #--------------------------------------------------------------------------
  def perform_transfer
    pre_transfer
    $game_player.perform_transfer
    post_transfer
  end
  #--------------------------------------------------------------------------
  # ● 场所移动前的处理
  #--------------------------------------------------------------------------
  def pre_transfer
    @map_name_window.close
    case $game_temp.fade_type
    when 0
      fadeout(fadeout_speed)
    when 1
      white_fadeout(fadeout_speed)
    end
  end
  #--------------------------------------------------------------------------
  # ● 场所移动后的处理
  #--------------------------------------------------------------------------
  def post_transfer
    case $game_temp.fade_type
    when 0
      Graphics.wait(fadein_speed / 2)
      fadein(fadein_speed)
    when 1
      Graphics.wait(fadein_speed / 2)
      white_fadein(fadein_speed)
    end
    @map_name_window.open
  end
  #--------------------------------------------------------------------------
  # ● 切换战斗画面前的处理
  #--------------------------------------------------------------------------
  def pre_battle_scene
    Graphics.update
    Graphics.freeze
    @spriteset.dispose_characters
    BattleManager.save_bgm_and_bgs
    BattleManager.play_battle_bgm
    Sound.play_battle_start
  end
  #--------------------------------------------------------------------------
  # ● 切换到标题画面前的处理
  #--------------------------------------------------------------------------
  def pre_title_scene
    fadeout(fadeout_speed_to_title)
  end
  #--------------------------------------------------------------------------
  # ● 执行战斗前的渐变
  #--------------------------------------------------------------------------
  def perform_battle_transition
    Graphics.transition(60, "Graphics/System/BattleStart", 100)
    Graphics.freeze
  end
  #--------------------------------------------------------------------------
  # ● 获取淡出速度
  #--------------------------------------------------------------------------
  def fadeout_speed
    return 30
  end
  #--------------------------------------------------------------------------
  # ● 获取淡入速度
  #--------------------------------------------------------------------------
  def fadein_speed
    return 30
  end
  #--------------------------------------------------------------------------
  # ● 获取切换到标题画面时的淡出速度
  #--------------------------------------------------------------------------
  def fadeout_speed_to_title
    return 60
  end
end
