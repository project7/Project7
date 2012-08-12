class Map_Battle
  
  include Fuc
  
  attr_accessor  :action_list
  attr_accessor  :cur_actor
  attr_accessor  :order_rem
  attr_accessor  :movearea
  attr_accessor  :wayarea
  attr_accessor  :effectarea
  attr_accessor  :enablearea
  attr_accessor  :fighter_num
  attr_accessor  :last_action_state
  attr_accessor  :turn
  attr_accessor  :scene_id
  attr_accessor  :steps
  attr_reader  :mouse_right_down
  
  def initialize(end_req=COMMON_BATTLE_REQ)
    @end_req = end_req
    $random_center = Random.new(rand(1073741823))
    var_init
    cal_var
  end
  
  def var_init              #变量初始化
    @action_list = []       #行动列表  
    @cur_actor = nil        #当前角色
    @order_rem = []         #指令记录，用于回放战斗
    @movearea = nil         #地板砖
    @wayarea = nil          #到达目的地的路径
    @enablearea = nil       #允许攻击的范围
    @effectarea = nil       #效果范围
    @scene_id = 0           #当前刷新的场景id
    @turn = 0               #回合
    @steps = 0              #操作数
    @fighter_num = 0        #参战人数
    @battle_end_flag = false
    @last_action_state = true
    @splink = SceneManager.scene.spriteset
  end
  
  def cal_var               #计算变量
    get_action_list
    get_first_actor
  end
  
  def get_action_list
    @action_list = $team_set.sort_by{|i| i.maxap}.reverse.clone
    @fighter_num = @action_list.size
  end
  
  def next_actor
    temp_actor = @action_list[@action_list.index(@cur_actor)+1]
    if temp_actor
      @cur_actor= temp_actor
    else
      @cur_actor = @action_list[0]
      @turn += 1
    end
    isdead = @cur_actor.dead?
    cal_fighter_num
    turn_begin_cal
    @actor = @cur_actor.event
    unless isdead
      $sel_body = @cur_actor unless @cur_actor.ai
      if @cur_actor.ap >= @cur_actor.maxap
        temp = [@cur_actor.maxap/10,@cur_actor.get_ap_for_step].max
        @cur_actor.ap = @cur_actor.maxap+temp
      else
        @cur_actor.ap = @cur_actor.maxap
      end
      @movearea.dispose if @movearea
      @effectarea.dispose if @effectarea
      @enablearea.dispose if @enablearea
      @wayarea.dispose if @wayarea
      create_maparea
      set_view_pos(@cur_actor.x,@cur_actor.y)
    else
      @cur_actor.ap = 0
      next_actor
    end
  end
  
  def cal_fighter_num
    arra = []
    arrb = []
    @action_list.each do |e|
      if !e.dead?
        if (e.team&$party.members[0].team).size>0
          arra << e
        else
          arrb << e
        end
      end
    end
    @partner_num = arra.size
    @enemy_num = arrb.size
  end
  
  def turn_begin_cal
    actor = @cur_actor
    actor.buff.each do |buff|
      if instance_eval(buff.end_req)
        @cur_actor.dec_buff(buff.id)
      else
        instance_eval(buff.per_turn_start_effect)
      end
    end
  end
  
  def per_steps_cal
    @steps+=1
    actor = @cur_actor
    actor.buff.each do |buff|
      if instance_eval(buff.end_req)
        @cur_actor.dec_buff(buff.id)
      else
        instance_eval(buff.per_step_effect)
      end
    end
  end
  
  def turn_end_cal
    actor = @cur_actor
    actor.buff.each do |buff|
      instance_eval(buff.per_turn_end_effect)
    end
  end
  
  def get_first_actor
    @cur_actor = @action_list[-1]
    next_actor
    @splink.tips[0].bitmap.dispose if @splink.tips[0].bitmap
    @splink.tips[0].bitmap = Bitmap.new(TIPS_POINT)
  end
  
  def update
    @mousexy = Fuc.getpos_by_screenpos(Mouse.pos)
    case @scene_id
    when 0
      if @cur_actor.ai
        update_ai
      else
        update_action
      end
    when 1
      update_select_target
    when 2
      update_select_effect_area
    when 3
      update_select_skill_area
    end
    update_cal
    update_viewpos
  end
  
  def update_select_target
    @splink.tipsvar[1][0] = true
    if CInput.repeat?($vkey[:Down])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([@mousexy[0],@mousexy[1]+1]))
    elsif CInput.repeat?($vkey[:Left])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([@mousexy[0]-1,@mousexy[1]]))
    elsif CInput.repeat?($vkey[:Right])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([@mousexy[0]+1,@mousexy[1]]))
    elsif CInput.repeat?($vkey[:Up])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([@mousexy[0],@mousexy[1]-1]))
    end
    unless @cur_actor.atk_area[1]
      if Fuc.mouse_dir_body(@cur_actor,@mousexy)!=@now_dir
        create_effectarea
      end
    end
    if Mouse.down?(1) || CInput.press?($vkey[:Check])
      tempb = action(1,@mousexy)
      return unless tempb
      if tempb.all?{|i| i[0]==false&&i[1]>1} && tempb.size>0
        @splink.show_tips(FAILD_ATTACK_TEXT[tempb[0][1]])
      else
        end_target_select
      end
    elsif Mouse.down?(2) || CInput.trigger?($vkey[:X])
      end_target_select
    end
  end
  
  def update_select_effect_area
    @splink.tipsvar[1][0] = true
    if CInput.repeat?($vkey[:Down])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([@mousexy[0],@mousexy[1]+1]))
    elsif CInput.repeat?($vkey[:Left])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([@mousexy[0]-1,@mousexy[1]]))
    elsif CInput.repeat?($vkey[:Right])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([@mousexy[0]+1,@mousexy[1]]))
    elsif CInput.repeat?($vkey[:Up])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([@mousexy[0],@mousexy[1]-1]))
    end
    unless @using_obj.hurt_area[1]
      if Fuc.mouse_dir_body(@cur_actor,@mousexy)!=@now_dir
        create_higher_effectarea(@using_obj)
      end
    end
    if Mouse.down?(1) || CInput.press?($vkey[:Check])
      tempb = action(3,[@using_obj,@mousexy])
      return unless tempb
      if tempb.all?{|i| i[0]==false&&i[1]>1} && tempb.size>0
        @splink.show_tips(FAILD_ATTACK_TEXT[tempb[0][1]])
      else
        @splink.show_tips(@using_obj.name)
        end_target_select
      end
    elsif Mouse.down?(2) || CInput.trigger?($vkey[:X])
      end_target_select
    end
  end
  
  def update_select_skill_area
    @splink.tipsvar[1][0] = true
    if CInput.repeat?($vkey[:Down])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([@mousexy[0],@mousexy[1]+1]))
    elsif CInput.repeat?($vkey[:Left])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([@mousexy[0]-1,@mousexy[1]]))
    elsif CInput.repeat?($vkey[:Right])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([@mousexy[0]+1,@mousexy[1]]))
    elsif CInput.repeat?($vkey[:Up])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([@mousexy[0],@mousexy[1]-1]))
    end
    unless @using_obj.hurt_area[1]
      if Fuc.mouse_dir_body(@cur_actor,@mousexy)!=@now_dir
        create_higher_effectarea(@using_obj)
      end
    end
    if Mouse.down?(1) || CInput.press?($vkey[:Check])
      tempb = action(2,[@using_obj,@mousexy])
      return unless tempb
      if tempb.all?{|i| i[0]==false&&i[1]>1} && tempb.size>0
        @splink.show_tips(FAILD_ATTACK_TEXT[tempb[0][1]])
      else
        @splink.show_tips(@using_obj.name)
        end_target_select
      end
    elsif Mouse.down?(2) || CInput.trigger?($vkey[:X])
      end_target_select
    end
  end
  
  def area_can_effect(tpos)
    effect_arr = []
    err_id = nil
    if @enablearea.include?(*tpos)
      $team_set.each do |i|
        body = i.event_id == 0 ? $game_player : i.event
        if @effectarea.include?(body.x,body.y)
          if (i.team&@cur_actor.team).size==0
            if i.dead?
              err_id = 3
            else
              effect_arr << i
            end
          else
            err_id = 1 if err_id != 3
          end
        else
          err_id ||= 0
        end
      end
    else
      err_id ||= 2
    end
    if effect_arr == []
      return err_id
    else
      return effect_arr
    end
  end
  
  def higher_area_can_effect(tec)
    effect_arr = []
    reffect_arr = []
    err_id = nil
    # 过滤目标
    if tec[1]==-1
      reffect_arr = $team_set
    elsif @enablearea.include?(*tec[1])
      reffect_arr = $team_set
    else
      err_id = 2
    end
    reffect_arr.each do |i|
      beat = (i.team&@cur_actor.team).size==0
      dead = i.dead?
      body = i.event_id == 0 ? $game_player : i.event
      if tec[1]==-1 || @effectarea.include?(body.x,body.y)
        if beat
          if tec[0].hurt_enemy || tec[0].hurt_e_dead
            if dead
              if tec[0].hurt_e_dead
                effect_arr << i
              else
                err_id = 6
              end
            elsif tec[0].hurt_e_dead
              err_id = 4 if err_id != 6 || err_id != 7
            else
              effect_arr << i
            end
          else
            err_id = 4 if err_id != 6 || err_id != 7
          end
        else
          if tec[0].hurt_partner || tec[0].hurt_p_dead
            if dead
              if tec[0].hurt_p_dead
                effect_arr << i
              else
                err_id = 7
              end
            elsif tec[0].hurt_p_dead
              err_id = 5 if err_id != 6 || err_id != 7
            else
              effect_arr << i
            end
          else
            err_id = 5 if err_id != 6 || err_id != 7
          end
        end
      else
        err_id ||= 0
      end
    end
    if effect_arr == []
      return err_id
    else
      if tec[0].hurt_maxnum>0
        return effect_arr[0,tec[0].hurt_maxnum].compact
      else
        return effect_arr
      end
    end
  end
  
  def end_target_select
    Mouse.set_cursor(Mouse::CursorFile)
    @effectarea.dispose if @effectarea
    @enablearea.dispose if @enablearea
    create_maparea
    @splink.fillup[0].visible = true
    @scene_id = 0
  end
  
  def ready_for_attack
    Mouse.set_cursor(Mouse::AttackCursor)
    @actor.auto_move_path=[]
    @movearea.dispose if @movearea
    @wayarea.dispose if @wayarea
    create_effectarea
    create_enablearea
    @splink.fillup[0].visible = false
    set_view_pos(@cur_actor.x,@cur_actor.y)
    @scene_id = 1
  end
  
  def ready_for_effect(obj)
    if obj.use_dis_max == 0
      @actor.auto_move_path=[]
      create_higher_effectarea(obj)
      create_higher_enablearea(obj)
      @effectarea.x = @cur_actor.x
      @effectarea.y = @cur_actor.y
      ttt = action(3,[obj,[@cur_actor.x,@cur_actor.y]])
      return unless ttt
      if ttt.all?{|i| i[0]==false&&i[1]>1} && ttt.size>0
        @splink.show_tips(FAILD_ATTACK_TEXT[ttt[0][1]])
      end
      end_target_select
      return
    elsif obj.hurt_maxnum < 0
      action(3,[obj,-1])
      return
    end
    Mouse.set_cursor(Mouse::AttackCursor)
    @actor.auto_move_path=[]
    @movearea.dispose if @movearea
    @wayarea.dispose if @wayarea
    create_higher_effectarea(obj)
    create_higher_enablearea(obj)
    @splink.fillup[0].visible = false
    set_view_pos(@cur_actor.x,@cur_actor.y)
    @scene_id = 2
    @using_obj = obj
  end
  
  def ready_for_skill(obj)
    if obj.use_dis_max == 0
      @actor.auto_move_path=[]
      create_higher_effectarea(obj)
      create_higher_enablearea(obj)
      @effectarea.x = @cur_actor.x
      @effectarea.y = @cur_actor.y
      ttt = action(2,[obj,[@cur_actor.x,@cur_actor.y]])
      return unless ttt
      if ttt.all?{|i| i[0]==false&&i[1]>1} && ttt.size>0
        @splink.show_tips(FAILD_ATTACK_TEXT[ttt[0][1]])
      end
      end_target_select
      return
    elsif obj.hurt_maxnum < 0
      action(2,[obj,-1])
      return
    end
    Mouse.set_cursor(Mouse::AttackCursor)
    @actor.auto_move_path=[]
    @movearea.dispose if @movearea
    @wayarea.dispose if @wayarea
    create_higher_effectarea(obj)
    create_higher_enablearea(obj)
    @splink.fillup[0].visible = false
    set_view_pos(@cur_actor.x,@cur_actor.y)
    @scene_id = 3
    @using_obj = obj
  end
  
  def update_action
    return if $game_map.interpreter.running?
    # 四方向按键
    tinp = CInput.dir4
    if @actor.movable? && tinp > 0
      action(0,tinp)
      @actor.auto_move_path=[]
      @wayarea.dispose if @wayarea
      return
    end
    # A
    if CInput.trigger?($vkey[:Attack]) && @actor.movable? && @cur_actor.atk_area
      $sel_body = @cur_actor
      if @cur_actor.ap>=@cur_actor.get_ap_for_atk
        ready_for_attack
      else
        @splink.show_tips(FAILD_ATTACK_TEXT[19])
      end
      return
    end
    # C
    if CInput.down?($vkey[:C]) && @actor.movable?
      @actor.check_action_event
    end
    # TAB
    if CInput.trigger?($vkey[:Tab])
      mouse_fuck_up
      @actor.auto_move_path=[]
      action(4)
      return
    end
    # 道具(1234)
    tkey = CInput.item4
    if tkey
      obj = $sel_body.bag[tkey]
      if obj && $sel_body == @cur_actor
        sick = obj[0].enough_to_use(obj[1],@cur_actor.ap>=@cur_actor.get_ap_for_item,@cur_actor.hp,@cur_actor.sp)
        if sick==true
          ready_for_effect(obj[0])
          return
        else
          @splink.show_tips(FAILD_ATTACK_TEXT[14+sick])
        end
      end
    end
    # 技能(hotkey)
    $sel_body.skill.each_with_index do |i,j|
      next unless i.hotkey
      if CInput.trigger?([i.hotkey])
        obj = i
        if obj && $sel_body == @cur_actor
          sick = obj.enough_to_use(@cur_actor.ap,@cur_actor.hp,@cur_actor.sp)
          if sick==true
            ready_for_skill(obj)
            return
          else
            @splink.show_tips(FAILD_ATTACK_TEXT[14+sick])
          end
        end
      end
    end
    # 鼠标
    if Mouse.down?(1) && @actor.movable?
      if SceneManager.scene.mouse_in_itemrect?
        obj = $sel_body.bag[@splink.tipsvar[2][1]]
        if obj && $sel_body == @cur_actor && @splink.tipsvar[2][0]
          sick = obj[0].enough_to_use(obj[1],@cur_actor.ap>=@cur_actor.get_ap_for_item,@cur_actor.hp,@cur_actor.sp)
          if sick==true
            ready_for_effect(obj[0])
          else
            @splink.show_tips(FAILD_ATTACK_TEXT[14+sick])
          end
        end
        return
      elsif SceneManager.scene.mouse_in_skillrect?
        iii = SceneManager.scene.skill_mouse_index
        obj = iii ? $sel_body.skill[iii] : nil
        if obj && $sel_body == @cur_actor
          sick = obj.enough_to_use(@cur_actor.ap,@cur_actor.hp,@cur_actor.sp)
          if sick==true
            ready_for_skill(obj)
            return
          else
            @splink.show_tips(FAILD_ATTACK_TEXT[14+sick])
          end
        end
        return
      else
        $team_set.each do |i|
          body = i.event_id == 0 ? $game_player : i.event
          if body.x == @mousexy[0] && body.y == @mousexy[1] && !i.dead?
            $sel_body = i
            @splink.show_value(i.hp*100/i.maxhp,i.event)
            return
          end
        end
        $sel_body = @cur_actor
        x_dis = @actor.x-@mousexy[0]
        y_dis = @actor.y-@mousexy[1]
        if x_dis.abs+y_dis.abs == 1 && @actor.movable?
          dir = DIR_LIST[x_dis][y_dis]
          if @actor.direction == dir && !@actor.passable?(@actor.x, @actor.y, dir)
            @actor.check_action_event
          else
            @wayarea.dispose if @wayarea
            action(0,dir)
          end
        elsif x_dis.abs+y_dis.abs > 1
          create_wayarea if @cur_actor.get_ap_for_step < 1 || @cur_actor.maxstep>=1
        end
      end
      return
    elsif Mouse.down?(2)
      @mouse_right_down = true
      @click_pos = Mouse.pos
      @actor.cantmove = true
      @target_pos = nil
      @splink.tipsvar[1][0] = true
      @wayarea.dispose if @wayarea
      Mouse.set_cursor(Mouse::EmptyCursor)
    elsif Mouse.press?(2) && @mouse_right_down
      dis_x = (Mouse.pos[0]-@click_pos[0]).to_f/32
      dis_y = (Mouse.pos[1]-@click_pos[1]).to_f/32
      $game_map.set_display_pos($game_map.parallax_x+dis_x,$game_map.parallax_y+dis_y)
      Mouse.set_pos(*@click_pos)
    elsif Mouse.up?(2) && @mouse_right_down
      mouse_fuck_up
    end
  end
  
  def mouse_fuck_up
    return unless @mouse_right_down
    @mouse_right_down = false
    Mouse.set_cursor(Mouse::CursorFile)
    @actor.cantmove = false
    @splink.fillup[0].visible = true
    Mouse.set_pos(*@click_pos) if @click_pos
    set_view_pos(@cur_actor.x,@cur_actor.y)
    @click_pos = nil
  end
  
  def update_ai
    if @actor.movable?
      order = @cur_actor.ai.get_action
      action(*order) if order && !@cur_actor.dead?
    end
  end
  
  def create_effectarea(target=nil)
    @effectarea.dispose if @effectarea
    if @cur_actor.atk_area[1]
      @effectarea = Effect_Area.new([0,0],*@cur_actor.atk_area,EFFECT_AREA_C[0],EFFECT_AREA_C[1])
    else
      target ||= @mousexy
      @now_dir = Fuc.mouse_dir_body(@cur_actor,target)
      @effectarea = Effect_Area.new([0,0],Fuc.turn(@cur_actor.atk_area[0].clone,@now_dir),false,EFFECT_AREA_C[0],EFFECT_AREA_C[1])
    end
    @splink.fillup[3].bitmap = @effectarea.bitmap
    ssx = $game_map.adjust_x(@mousexy[0]+@effectarea.offset_x) * 32
    ssy = $game_map.adjust_y(@mousexy[1]+@effectarea.offset_y) * 32
    @splink.fillup[3].x = ssx
    @splink.fillup[3].y = ssy
  end
  
  def create_enablearea
    @enablearea.dispose if @enablearea
    @enablearea = Effect_Area.new([@cur_actor.x,@cur_actor.y],[[@cur_actor.atk_dis_min,@cur_actor.atk_dis_max,true]],true,ENABLE_AREA_C[0],ENABLE_AREA_C[1])
    @splink.fillup[4].bitmap = @enablearea.bitmap
    @splink.fillup[4].x = @enablearea.screen_x
    @splink.fillup[4].y = @enablearea.screen_y
  end
  
  def create_higher_effectarea(obj,target=nil)
    @effectarea.dispose if @effectarea
    if obj.hurt_area[1]
      @effectarea = Effect_Area.new([0,0],*obj.hurt_area,EFFECT_AREA_C[0],EFFECT_AREA_C[1])
    else
      target ||= @mousexy
      @now_dir = Fuc.mouse_dir_body(@cur_actor,target)
      @effectarea = Effect_Area.new([0,0],Fuc.turn(obj.hurt_area[0].clone,@now_dir),false,EFFECT_AREA_C[0],EFFECT_AREA_C[1])
    end
    @splink.fillup[3].bitmap = @effectarea.bitmap
    ssx = $game_map.adjust_x(@mousexy[0]+@effectarea.offset_x) * 32
    ssy = $game_map.adjust_y(@mousexy[1]+@effectarea.offset_y) * 32
    @splink.fillup[3].x = ssx
    @splink.fillup[3].y = ssy
  end
  
  def create_higher_enablearea(obj)
    @enablearea.dispose if @enablearea
    @enablearea = Effect_Area.new([@cur_actor.x,@cur_actor.y],[[obj.use_dis_min,obj.use_dis_max,true]],true,ENABLE_AREA_C[0],ENABLE_AREA_C[1])
    @splink.fillup[4].bitmap = @enablearea.bitmap
    @splink.fillup[4].x = @enablearea.screen_x
    @splink.fillup[4].y = @enablearea.screen_y
  end
  
  def create_maparea
    @movearea.dispose if @movearea
    return if @cur_actor.get_ap_for_step < 1
    @movearea = Effect_Area.new([@cur_actor.x,@cur_actor.y],[[@cur_actor.maxstep]])
    @splink.fillup[1].bitmap = @movearea.bitmap
    @splink.fillup[1].x = @movearea.screen_x
    @splink.fillup[1].y = @movearea.screen_y
    @area_x = @cur_actor.x
    @area_y = @cur_actor.y
  end
  
  def create_wayarea
    way = Fuc.xxoo(*Fuc.getpos_by_screenpos(Mouse.pos),@cur_actor.maxstep,@actor)
    tempx = @actor.x
    tempy= @actor.y
    realway = [[tempx-@actor.x,tempy-@actor.y]]
    way.each do |i|
      case i
      when 2
        tempy+=1
      when 4
        tempx-=1
      when 6
        tempx+=1
      when 8
        tempy-=1
      end
      realway << [tempx-@actor.x,tempy-@actor.y]
    end
    @wayarea.dispose if @wayarea
    @wayarea = Effect_Area.new([@cur_actor.x,@cur_actor.y],realway,false,*WAY_AREA_C)
    @splink.fillup[2].bitmap = @wayarea.bitmap
    @splink.fillup[2].x = @wayarea.screen_x
    @splink.fillup[2].y = @wayarea.screen_y
  end
  
  def update_cal
    if instance_eval(@end_req)
      end_battle
      #elsif @cur_actor.ap <= 0
      #  turn_end_cal
      #  next_actor
    end
  end
  
  def update_viewpos
    if @target_pos
      now_pos = [$game_map.parallax_x,$game_map.parallax_y]
      if (@last_sc_pos[0]-now_pos[0]).abs <= 0.01 && (@last_sc_pos[1]-now_pos[1]).abs <= 0.01
        #$game_map.set_display_pos(*@target_pos)
        @target_pos = nil
      else
        sx = (@target_pos[0].to_f - now_pos[0])/10
        sy = (@target_pos[1].to_f - now_pos[1])/10
        $game_map.set_display_pos(now_pos[0]+sx,now_pos[1]+sy)
        @last_sc_pos = now_pos
      end
    end
  end
  
  def set_view_pos(x,y)
    @target_pos = [x-9.5,y-7]
    @last_sc_pos = [$game_map.parallax_x+1,$game_map.parallax_y+1]
  end
  
  def action(id,para=nil)
    revar = ctrl(id,para)
    if revar.is_a?(Array)
      @last_action_state = revar
      @order_rem << [id,para]
      per_steps_cal
      return revar
    elsif revar
      @last_action_state = true
      @order_rem << [id,para]
      per_steps_cal
      return true
    else
      @last_action_state = false
      return false
    end
  end
  
  def ctrl(id,para)
    actor = @cur_actor.event
    case id
    when 0#移动
      return false if @cur_actor.ap < @cur_actor.get_ap_for_step
      if @actor.move_straight(para)
        @cur_actor.cost_ap_for(0)
        create_maparea
        return true
      else
        return false
      end
    when 1#攻击
      return false if @cur_actor.ap<@cur_actor.get_ap_for_atk
      temp = area_can_effect(para)
      tsx = @cur_actor.x-para[0]
      tsy = @cur_actor.y-para[1]
      if tsx.abs > tsy.abs
        @cur_actor.event.set_direction(tsx > 0 ? 4 : 6)
      elsif tsy != 0
        @cur_actor.event.set_direction(tsy > 0 ? 8 : 2)
      end
      if temp.is_a?(Array)
        tempb = []
        if $random_center.rand(100) < @cur_actor.bingo_rate
          Sound.bingo
          bingo_color = BINGO_COLOR
          bingo_size = 30
        else
          bingo_color = HP_COST_COLOR
          bingo_size = 20
        end
        temp.each do |i|
          tempama = @cur_actor.get_atk
          tempama = tempama*@cur_actor.bingo_damage/100 if bingo_size > 20
          @cur_actor.buff.each{|i| instance_eval(i.atk_effect)}
          dama = i.phy_damage(tempama)
          tempb << dama
          if dama[0]
            if @cur_actor.hp_absorb_rate != 0 || @cur_actor.hp_absorb != 0
              a = @cur_actor.absorb_hp(dama[1])
              b = @cur_actor.absorb_hp_by_rate(i.hp)
              c = -a[1]-b[1]
              @splink.show_text(c.to_s,@cur_actor.event,HP_ADD_COLOR)
            end
            if i.dmg_rebound !=0 || i.dmg_rebound_rate != 0
              a = @cur_actor.rebound_damage(dama[1],i.dmg_rebound_rate,i.dmg_rebound)
              @splink.show_text(a[1].to_s,@cur_actor.event,HP_COST_COLOR) if a[0]
            end
            @splink.show_text(dama[1].to_s,i.event,bingo_color,bingo_size)
            @cur_actor.atk_buff.each do |buff|
              if $random_center.rand(100) < buff[1]
                sm = instance_eval(buff[0]+"("+"@cur_actor"+")")
                i.add_buff(sm)
                @splink.show_text("+"+sm.name,i.event,SP_ADD_COLOR)
              end
            end
            i.sp+=2
          elsif dama[1]<=1
            @splink.show_text(FAILD_ATTACK_TEXT[dama[1]],i.event)
          end
          @splink.show_value(i.hp*100/i.maxhp,i.event)
        end
        @cur_actor.sp+=2
        @cur_actor.cost_ap_for(1)
        @splink.show_value(@cur_actor.hp*100/@cur_actor.maxhp,@cur_actor.event)
        return tempb
      else
        return [[false,5+temp]]
      end
    when 2#技能
      return false if para[0].enough_to_use(@cur_actor.ap,@cur_actor.hp,@cur_actor.sp)!=true
      if (para[0].hurt_nothing && $game_map.can_move(@cur_actor.event,*para[1])) || (para[0].hurt_cant_move && !$game_map.can_move(@cur_actor.event,*para[1]))
        if @enablearea.include?(*para[1])
          instance_eval(para[0].spec_effect)
          tsx = @cur_actor.x-para[1][0]
          tsy = @cur_actor.y-para[1][1]
          if tsx.abs > tsy.abs
            @cur_actor.event.set_direction(tsx > 0 ? 4 : 6)
          elsif tsy != 0
            @cur_actor.event.set_direction(tsy > 0 ? 8 : 2)
          end
          @actor.animation_id = para[0].user_animation
          @cur_actor.cost_ap_for(3,para[0].ap_cost)
          @cur_actor.god_sp_damage(para[0].sp_cost,true)
          @cur_actor.god_damage(para[0].hp_cost,true)
          @splink.show_value(@cur_actor.hp*100/@cur_actor.maxhp,@cur_actor.event)
          return [[true,0]]
        else
          return [[false,7]]
        end
      elsif para[0].hurt_nothing || para[0].hurt_cant_move
        return [[false,13]]
      else
        temp = higher_area_can_effect(para)
      end
      if para[1]!=-1
        tsx = @cur_actor.x-para[1][0]
        tsy = @cur_actor.y-para[1][1]
        if tsx.abs > tsy.abs
          @cur_actor.event.set_direction(tsx > 0 ? 4 : 6)
        elsif tsy != 0
          @cur_actor.event.set_direction(tsy > 0 ? 8 : 2)
        end
      end
      if temp.is_a?(Array)
        tempb = []
        @succ_count = 0
        temp.each do |i|
          tempama = para[0].hp_damage
          if tempama != 0
            color = tempama > 0 ? HP_COST_COLOR : HP_ADD_COLOR
            dama = para[0].ignore_mag_det ? i.damage(tempama) : i.mag_damage(tempama)
            tempb << dama
            if dama[0]
              @succ_count+=1
              @splink.show_text(dama[1].to_s,i.event,color)
            elsif dama[1]<=1
              @succ_count+=1
              @splink.show_text(FAILD_ATTACK_TEXT[dama[1]],i.event)
            end
          end
          tempama = para[0].sp_damage
          if tempama != 0
            color = tempama > 0 ? SP_COST_COLOR : SP_ADD_COLOR
            dama = para[0].ignore_mag_det ? i.damage(tempama) : i.mag_damage(tempama)
            tempb << dama
            if dama[0]
              @succ_count+=1
              @splink.show_text(dama[1].to_s,i.event,color)
            elsif dama[1]<=1
              @succ_count+=1
              @splink.show_text(FAILD_ATTACK_TEXT[dama[1]],i.event)
            end
          end
          tempama = para[0].ap_damage
          if tempama != 0
            color = tempama > 0 ? AP_COST_COLOR : AP_ADD_COLOR
            dama = para[0].ignore_mag_det ? i.damage(tempama) : i.mag_damage(tempama)
            tempb << dama
            if dama[0]
              @succ_count+=1
              @splink.show_text(dama[1].to_s,i.event,color)
            elsif dama[1]<=1
              @succ_count+=1
              @splink.show_text(FAILD_ATTACK_TEXT[dama[1]],i.event)
            end
          end
          if !i.ignore_magic || (i.ignore_magic && para[0].ignore_mag_det)
            i.god_sp_damage(-2,true)
            para[0].debuff.each do |debuff|
              if $random_center.rand(100) < debuff[1]
                @succ_count+=1
                i.dec_buff(debuff[0])
              end
            end
            para[0].buff.each do |buff|
              if $random_center.rand(100) < buff[1]
                @succ_count+=1
                sm = instance_eval(buff[0]+"("+"@cur_actor"+")")
                i.add_buff(sm)
                @splink.show_text("+"+sm.name,i.event,SP_ADD_COLOR)
              end
            end
            if para[0].spec_effect!=""
              @succ_count+=1
              instance_eval(para[0].spec_effect)
            end
          end
          @splink.show_value(i.hp*100/i.maxhp,i.event)
        end
        if @succ_count>0
          @actor.animation_id = para[0].user_animation
          @cur_actor.god_sp_damage(-2,true)
          @cur_actor.cost_ap_for(3,para[0].ap_cost)
          @cur_actor.god_sp_damage(para[0].sp_cost,true)
          @cur_actor.god_damage(para[0].hp_cost,true)
        end
        @splink.show_value(@cur_actor.hp*100/@cur_actor.maxhp,@cur_actor.event)
        return tempb
      else
        return [[false,5+temp]]
      end
    when 3#物品
      return false if para[0].enough_to_use(@cur_actor.item_num(para[0]),@cur_actor.ap>=@cur_actor.get_ap_for_item,@cur_actor.hp,@cur_actor.sp)!=true
      if (para[0].hurt_nothing && $game_map.can_move(@cur_actor.event,*para[1])) || (para[0].hurt_cant_move && !$game_map.can_move(@cur_actor.event,*para[1]))
        if @enablearea.include?(*para[1])
          instance_eval(para[0].spec_effect)
          tsx = @cur_actor.x-para[1][0]
          tsy = @cur_actor.y-para[1][1]
          if tsx.abs > tsy.abs
            @cur_actor.event.set_direction(tsx > 0 ? 4 : 6)
          elsif tsy != 0
            @cur_actor.event.set_direction(tsy > 0 ? 8 : 2)
          end
          @actor.animation_id = para[0].user_animation
          @cur_actor.cost_ap_for(2)
          @cur_actor.god_sp_damage(para[0].sp_cost,true)
          @cur_actor.god_damage(para[0].hp_cost,true)
          @cur_actor.lose_item(para[0].id,para[0].use_cost_num)
          @splink.show_value(@cur_actor.hp*100/@cur_actor.maxhp,@cur_actor.event)
          return [[true,0]]
        else
          return [[false,7]]
        end
      elsif para[0].hurt_nothing || para[0].hurt_cant_move
        return [[false,13]]
      else
        temp = higher_area_can_effect(para)
      end
      if para[1]!=-1
        tsx = @cur_actor.x-para[1][0]
        tsy = @cur_actor.y-para[1][1]
        if tsx.abs > tsy.abs
          @cur_actor.event.set_direction(tsx > 0 ? 4 : 6)
        elsif tsy != 0
          @cur_actor.event.set_direction(tsy > 0 ? 8 : 2)
        end
      end
      if temp.is_a?(Array)
        tempb = []
        @succ_count = 0
        temp.each do |i|
          tempama = para[0].hp_damage
          if tempama != 0
            color = tempama > 0 ? HP_COST_COLOR : HP_ADD_COLOR
            dama = para[0].ignore_mag_det ? i.damage(tempama) : i.mag_damage(tempama)
            tempb << dama
            if dama[0]
              @succ_count+=1
              @splink.show_text(dama[1].to_s,i.event,color)
            elsif dama[1]<=1
              @succ_count+=1
              @splink.show_text(FAILD_ATTACK_TEXT[dama[1]],i.event)
            end
          end
          tempama = para[0].sp_damage
          if tempama != 0
            color = tempama > 0 ? SP_COST_COLOR : SP_ADD_COLOR
            dama = para[0].ignore_mag_det ? i.damage(tempama) : i.mag_damage(tempama)
            tempb << dama
            if dama[0]
              @succ_count+=1
              @splink.show_text(dama[1].to_s,i.event,color)
            elsif dama[1]<=1
              @succ_count+=1
              @splink.show_text(FAILD_ATTACK_TEXT[dama[1]],i.event)
            end
          end
          tempama = para[0].ap_damage
          if tempama != 0
            color = tempama > 0 ? AP_COST_COLOR : AP_ADD_COLOR
            dama = para[0].ignore_mag_det ? i.damage(tempama) : i.mag_damage(tempama)
            tempb << dama
            if dama[0]
              @succ_count+=1
              @splink.show_text(dama[1].to_s,i.event,color)
            elsif dama[1]<=1
              @succ_count+=1
              @splink.show_text(FAILD_ATTACK_TEXT[dama[1]],i.event)
            end
          end
          if !i.ignore_magic || (i.ignore_magic && para[0].ignore_mag_det)
            i.god_sp_damage(-2,true)
            para[0].debuff.each do |debuff|
              if $random_center.rand(100) < debuff[1]
                @succ_count+=1
                i.dec_buff(debuff[0])
              end
            end
            para[0].buff.each do |buff|
              if $random_center.rand(100) < buff[1]
                @succ_count+=1
                sm = instance_eval(buff[0]+"("+"@cur_actor"+")")
                i.add_buff(sm)
                @splink.show_text("+"+sm.name,i.event,SP_ADD_COLOR)
              end
            end
            if para[0].spec_effect!=""
              @succ_count+=1
              instance_eval(para[0].spec_effect)
            end
          end
          @splink.show_value(i.hp*100/i.maxhp,i.event)
        end
        if @succ_count>0
          @actor.animation_id = para[0].user_animation
          @cur_actor.god_sp_damage(-2,true)
          @cur_actor.cost_ap_for(2)
          @cur_actor.god_sp_damage(para[0].sp_cost,true)
          @cur_actor.god_damage(para[0].hp_cost,true)
          @cur_actor.lose_item(para[0].id,para[0].use_cost_num)
        end
        @splink.show_value(@cur_actor.hp*100/@cur_actor.maxhp,@cur_actor.event)
        return tempb
      else
        return [[false,5+temp]]
      end
    when 4#跳过
      turn_end_cal
      @cur_actor.add_buff(Wait_buff.new)
      next_actor
    end
  end
  
  def end_battle
    @battle_end_flag = true
    dispose_all
    $game_switches[1]=false
    $map_battle = nil
    $game_temp.reserve_common_event(1)
  end
  
  def dispose_all
    if @movearea
      @movearea.bitmap.dispose if @movearea.bitmap
      @movearea.dispose
    end
    if @wayarea
      @wayarea.bitmap.dispose if @wayarea.bitmap
      @wayarea.dispose
    end
    if @enablearea
      @enablearea.bitmap.dispose if @enablearea.bitmap
      @enablearea.dispose
    end
    if @effectarea
      @effectarea.bitmap.dispose if @effectarea.bitmap
      @effectarea.dispose
    end
    @splink.tips[0].bitmap.dispose if @splink.tips[0].bitmap
  end
  
  def top_hatred(boy)
    hatred_list = []
    @action_list.each do |i|
      if i!=boy && (i.team&boy.team).size==0 && !i.dead?
        hatred_list << i
      end
    end
    return hatred_list.sort_by{|i| i.hatred}.reverse
  end
  
end