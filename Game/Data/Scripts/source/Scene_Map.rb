#encoding:utf-8
#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　地图画面
#==============================================================================

class Scene_Map < Scene_Base
  
  include Fuc

  attr_accessor :spriteset
  attr_accessor :menu_calling
  attr_accessor :menu_rem
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
    @menu_sprite_sin = Sprite.new
    @menu_sprite_sin.z = 1000
    @menu_sprite_act = Sprite.new
    @menu_sprite_act.z = 1001
    @menu_calling = false
    @menu_called_inedx = 0
    @now_set = [nil]*5
    @menu_rem = nil
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
    @menu_sprite_sin.bitmap.dispose if @menu_sprite_sin.bitmap
    @menu_sprite_sin.dispose if @menu_sprite_sin
    @menu_sprite_act.bitmap.dispose if @menu_sprite_act.bitmap
    @menu_sprite_act.dispose if @menu_sprite_act
    SceneManager.snapshot_for_background
    dispose_spriteset
    perform_battle_transition if SceneManager.scene_is?(Scene_Battle)
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    unless @menu_called_inedx > 0
      $game_map.update(true)
      $game_player.update
      $game_timer.update
      @spriteset.update
      update_ui
      update_scene if scene_change_ok?
    else
      update_system_menu(@menu_called_inedx)
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新UI
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
        @spriteset.tipsvar[19] = true
        tempb = skill_mouse_index
        if tempb
          @spriteset.tipsvar[17][0] = true
          @spriteset.tipsvar[17][1] = tempb
        else
          @spriteset.tipsvar[17][0] = false
        end
      else
        @spriteset.tipsvar[19] = false
      end
    else
      @spriteset.tipsvar[1][0] = true
      @spriteset.tipsvar[19] = false
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
    #update_call_debug unless scene_changing?
    if $game_switches[1]
      $map_battle.update unless scene_changing?
    else
      update_call_menu unless scene_changing?
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
    tkey = CInput.item4
    if tkey
      obj = $sel_body.bag[tkey]
      if obj
        sick = obj[0].enough_to_use(obj[1],true,$sel_body.hp,9999)
        if sick==true
          $sel_body.event.animation_id = obj[0].user_animation
          $sel_body.god_damage(obj[0].hp_cost,true)
          instance_eval(obj[0].spec_effect)
          $sel_body.lose_item(obj[0].id,obj[0].use_cost_num)
          @spriteset.show_tips(obj[0].name)
          return
        else
          @spriteset.show_tips(FAILD_ATTACK_TEXT[14+sick])
        end
      end
    end
    sks = $sel_body.skill
    sks.each_with_index do |i,j|
      next unless i.hotkey
      if CInput.trigger?([i.hotkey])
        obj = i
        if obj
          sick = obj.enough_to_use(9999,$sel_body.hp,9999)
          if sick==true
            $sel_body.event.animation_id = obj.user_animation
            $sel_body.god_damage(obj.hp_cost,true)
            instance_eval(obj.spec_effect)
            @spriteset.show_tips(obj.name)
            return
          else
            @spriteset.show_tips(FAILD_ATTACK_TEXT[14+sick])
          end
        end
      end
    end
    if Mouse.click?(1)
      if mouse_in_itemrect?
        if item_mouse_index
          obj = $sel_body.bag[item_mouse_index]
          if obj
            sick = obj[0].enough_to_use(obj[1],true,$sel_body.hp,9999)
            if sick==true
              $sel_body.event.animation_id = obj[0].user_animation
              $sel_body.god_damage(obj[0].hp_cost,true)
              instance_eval(obj[0].spec_effect)
              $sel_body.lose_item(obj[0].id,obj[0].use_cost_num)
              @spriteset.show_tips(obj[0].name)
              return
            else
              @spriteset.show_tips(FAILD_ATTACK_TEXT[14+sick])
            end
          end
        end
      elsif mouse_in_skillrect?
        if skill_mouse_index
          sks = $sel_body.skill
          obj = sks[skill_mouse_index]
          if obj
            sick = obj.enough_to_use(9999,$sel_body.hp,9999)
            if sick==true
              $sel_body.event.animation_id = obj.user_animation
              $sel_body.god_damage(obj.hp_cost,true)
              instance_eval(obj.spec_effect)
              @spriteset.show_tips(obj.name)
              return
            else
              @spriteset.show_tips(FAILD_ATTACK_TEXT[14+sick])
            end
          end
        end
      elsif @menu_called_inedx==0  #鼠标点击寻路
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
  
  def call_ele_scene
    return if @menu_called_inedx == 1
    create_menu(MENU_ELE)
    @menu_called_inedx = 1
  end
  
  def call_gra_scene
    return if @menu_called_inedx == 2
    create_menu(MENU_GRA)
    @menu_called_inedx = 2
  end
  
  def call_voi_scene
    return if @menu_called_inedx == 3
    create_menu(MENU_VOI)
    @menu_called_inedx = 3
  end
  
  def call_save_scene
    return if @menu_called_inedx == 4
    create_menu(MENU_SAV)
    if ($WebLogin_user rescue nil) == nil
      @menu_sprite_sin.bitmap.blt(MENU_SAV_POS[0][0],MENU_SAV_POS[0][1],Bitmap.new(MENU_SAV_LOG),Rect.new(0,0,166,34))
    else
      @menu_sprite_sin.bitmap.blt(MENU_SAV_POS[0][0],MENU_SAV_POS[0][1],Bitmap.new(MENU_SAV_SL),Rect.new(0,0,166,34))
    end
    @menu_called_inedx = 4
  end
  
  def call_mes_scene
    return if @menu_called_inedx == 5
    create_menu(MENU_MES)
    @menu_called_inedx = 5
  end
  
  def create_menu(res)
    @menu_sprite_sin.bitmap.dispose if @menu_sprite_sin.bitmap
    @menu_sprite_sin.bitmap = Bitmap.new(res)
    @menu_sprite_act.bitmap.dispose if @menu_sprite_act.bitmap
    @menu_sprite_act.bitmap = Bitmap.new(@menu_sprite_sin.bitmap.width,@menu_sprite_sin.bitmap.height)
    @menu_sprite_act.x = @menu_sprite_sin.x = Graphics.width/2-@menu_sprite_sin.bitmap.width/2
    @menu_sprite_act.y = @menu_sprite_sin.y = Graphics.height/2-@menu_sprite_sin.bitmap.height/2
  end
  
  def adapt_screen
    @menu_sprite_act.x = @menu_sprite_sin.x = Graphics.width/2-@menu_sprite_sin.bitmap.width/2
    @menu_sprite_act.y = @menu_sprite_sin.y = Graphics.height/2-@menu_sprite_sin.bitmap.height/2
  end
  
  def call_ret_scene
    @menu_sprite_sin.bitmap.dispose if @menu_sprite_sin.bitmap
    @menu_sprite_act.bitmap.dispose if @menu_sprite_act.bitmap
    resc_skill
    @menu_calling = false
    @menu_called_inedx = 0
  end
  #--------------------------------------------------------------------------
  # ● 更新菜单
  #--------------------------------------------------------------------------
  def update_system_menu(index)
    @spriteset.update_ui_view
    update_ui
    update_mouse_event
    update_call_menu
    case @menu_called_inedx
    when 1
    when 2
      update_menu_gra
    when 3
      update_menu_voi
    when 4
      update_menu_sav
    when 5
    end
  end
  
  def update_menu_gra
    @now_set[1] = [$syseting[:ctrl_screen],$syseting[:show_maparea],$syseting[:show_animation],$syseting[:screen_size]]
    if @menu_rem != @now_set[1]
      @menu_rem = @now_set[1].clone
      @menu_sprite_act.bitmap.clear
      4.times{|i| @menu_sprite_act.bitmap.blt(*MENU_GRA_POS[i],Bitmap.new(MENU_SEL),RECT_SEL) if @menu_rem[i]}
    end
    if Mouse.click?(1)
      tpos = [Mouse.pos[0]-@menu_sprite_act.x,Mouse.pos[1]-@menu_sprite_act.y]
      MENU_GRA_POS.each_with_index do |i,j|
        if tpos[0]>=i[0]&&tpos[0]<=i[0]+26&&tpos[1]>=i[1]&&tpos[1]<=i[1]+26
          case j
          when 0
            $syseting[:ctrl_screen]=!$syseting[:ctrl_screen]
          when 1
            $syseting[:show_maparea]=!$syseting[:show_maparea]
          when 2
            $syseting[:show_animation]=!$syseting[:show_animation]
          when 3
            CToy.on_fullscreen
          end
        end
      end
    end
  end
  
  def update_menu_voi
    @now_set[2] = [$syseting[:bgm_value],$syseting[:se_value],$syseting[:voi_value]]
    if @menu_rem != @now_set[2]
      @menu_rem = @now_set[2].clone
      @menu_sprite_act.bitmap.clear
      4.times{|i| @menu_sprite_act.bitmap.draw_text(*MENU_VOI_POS[i],60,40,@menu_rem[i].to_s+"%",2) if @menu_rem[i]}
    end
    ms = Mouse.scroll
    if ms!=0
      tpos = [Mouse.pos[0]-@menu_sprite_act.x,Mouse.pos[1]-@menu_sprite_act.y]
      MENU_VOI_POS.each_with_index do |i,j|
        if tpos[1]>=i[1]&&tpos[1]<=i[1]+32
          case j
          when 0
            $syseting[:bgm_value]+=5*(ms>0 ? 1 :-1)
            $syseting[:bgm_value]=[[100,$syseting[:bgm_value]].min,0].max
            Audio.sync_vol if Audio.respond_to? :sync_vol
          when 1
            $syseting[:se_value]+=5*(ms>0 ? 1 :-1)
            $syseting[:se_value]=[[100,$syseting[:se_value]].min,0].max
          when 2
            $syseting[:voi_value]+=5*(ms>0 ? 1: -1)
            $syseting[:voi_value]=[[100,$syseting[:voi_value]].min,0].max
          end
        end
      end
    end
  end
  
  def update_menu_sav
    tpos = [Mouse.pos[0]-@menu_sprite_act.x,Mouse.pos[1]-@menu_sprite_act.y]
    if ($WebLogin_user rescue nil) == nil
      @now_set[3] = [tpos.inrect?(MENU_SAV_POS[0]),tpos.inrect?(MENU_SAV_POS[3]),tpos.inrect?(MENU_SAV_POS[4])]
      if @menu_rem != @now_set[3]
        if @menu_rem&&@menu_rem.size == 4
          @menu_sprite_sin.bitmap.dispose
          @menu_sprite_sin.bitmap = Bitmap.new(MENU_SAV)
          @menu_sprite_sin.bitmap.blt(MENU_SAV_POS[0][0],MENU_SAV_POS[0][1],Bitmap.new(MENU_SAV_LOG),Rect.new(0,0,166,34))
        end
        @menu_rem = @now_set[3].clone
        @menu_sprite_act.bitmap.clear
        3.times do |i|
          case i
          when 0
            @menu_sprite_act.bitmap.blt(MENU_SAV_POS[0][0],MENU_SAV_POS[0][1],Bitmap.new(MENU_SAV_SEL[0]),Rect.new(0,0,MENU_SAV_POS[0][2],MENU_SAV_POS[0][3])) if @menu_rem[i]
          when 1
            @menu_sprite_act.bitmap.blt(MENU_SAV_POS[3][0],MENU_SAV_POS[3][1],Bitmap.new(MENU_SAV_SEL[1]),Rect.new(0,0,MENU_SAV_POS[3][2],MENU_SAV_POS[3][3])) if @menu_rem[i]
          when 2
            @menu_sprite_act.bitmap.blt(MENU_SAV_POS[4][0],MENU_SAV_POS[4][1],Bitmap.new(MENU_SAV_SEL[2]),Rect.new(0,0,MENU_SAV_POS[4][2],MENU_SAV_POS[4][3])) if @menu_rem[i]
          end
        end
      end
      iindex = @menu_rem.index(true)
      if Mouse.click?(1) && iindex
        case iindex
        when 0
          jiecao = Jiecao.new
          jiecao.instance_variable_set :@browser, CBrower.new("http://lynngame.sinaapp.com/?action=ingameLogin", 0, 0, Graphics.width, Graphics.height, jiecao)
          loop do
            Graphics.update
            break unless jiecao.instance_variable_get :@browser
          end
          RGSSX.ensure
        when 1
          if DataManager.load_game(0)
            fadeout_all
            $game_system.on_after_load
            SceneManager.goto(Scene_Map)
          else
            @spriteset.show_tips("读取档案失败.")
          end
        when 2
          if DataManager.save_game(0)
            @spriteset.show_tips("存档成功.")
          else
            @spriteset.show_tips("存档失败.")
          end
        end
      end
    else
      @now_set[3] = [tpos.inrect?(MENU_SAV_POS[1]),tpos.inrect?(MENU_SAV_POS[2]),tpos.inrect?(MENU_SAV_POS[3]),tpos.inrect?(MENU_SAV_POS[4])]
      if @menu_rem != @now_set[3]
        if @menu_rem&&@menu_rem.size == 3
          @menu_sprite_sin.bitmap.dispose
          @menu_sprite_sin.bitmap = Bitmap.new(MENU_SAV)
          @menu_sprite_sin.bitmap.blt(MENU_SAV_POS[0][0],MENU_SAV_POS[0][1],Bitmap.new(MENU_SAV_SL),Rect.new(0,0,166,34))
        end
        @menu_rem = @now_set[3].clone
        @menu_sprite_act.bitmap.clear
        4.times do |i|
          case i
          when 0
            @menu_sprite_act.bitmap.blt(MENU_SAV_POS[1][0],MENU_SAV_POS[1][1],Bitmap.new(MENU_SAV_SEL[1]),Rect.new(0,0,MENU_SAV_POS[1][2],MENU_SAV_POS[1][3])) if @menu_rem[i]
          when 1
            @menu_sprite_act.bitmap.blt(MENU_SAV_POS[2][0],MENU_SAV_POS[2][1],Bitmap.new(MENU_SAV_SEL[2]),Rect.new(0,0,MENU_SAV_POS[2][2],MENU_SAV_POS[2][3])) if @menu_rem[i]
          when 2
            @menu_sprite_act.bitmap.blt(MENU_SAV_POS[3][0],MENU_SAV_POS[3][1],Bitmap.new(MENU_SAV_SEL[1]),Rect.new(0,0,MENU_SAV_POS[3][2],MENU_SAV_POS[3][3])) if @menu_rem[i]
          when 3
            @menu_sprite_act.bitmap.blt(MENU_SAV_POS[4][0],MENU_SAV_POS[4][1],Bitmap.new(MENU_SAV_SEL[2]),Rect.new(0,0,MENU_SAV_POS[4][2],MENU_SAV_POS[4][3])) if @menu_rem[i]
          end
        end
      end
      iindex = @menu_rem.index(true)
      if Mouse.click?(1) && iindex
        case iindex
        when 0
          if DataManager.load_web_game(0)
            fadeout_all
            $game_system.on_after_load
            SceneManager.goto(Scene_Map)
          else
            @spriteset.show_tips("读取档案失败.")
          end
        when 1
          if DataManager.save_web_game(0)
            @spriteset.show_tips("存档成功.")
          else
            @spriteset.show_tips("存档失败.")
          end
        when 2
          if DataManager.load_game(0)
            fadeout_all
            $game_system.on_after_load
            SceneManager.goto(Scene_Map)
          else
            @spriteset.show_tips("读取档案失败.")
          end
        when 3
          if DataManager.save_game(0)
            @spriteset.show_tips("存档成功.")
          else
            @spriteset.show_tips("存档失败.")
          end
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
    if $game_system.menu_disabled || $game_map.interpreter.running?
      @menu_calling = false
    else
      if CInput.trigger?($vkey[:X]) || (!$map_battle && Mouse.down?(2))
        @menu_calling =!@menu_calling
        if @menu_calling
          @menu_rem = nil
          change_skill
        else
          call_ret_scene
        end
      end
    end
  end
  
  def change_skill
    $sel_body.change_skill($menu_skill)
  end
  
  def resc_skill
    $sel_body.resc_skill
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
