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

  def initialize(end_req="@fighter_num<=1")
    @end_req = end_req
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
    temp = {}
    temp_val = []
    $team_set.each do |i|
      temp[i.maxap] ||= []
      temp[i.maxap] << i
      temp_val << i.maxap
    end
    temp_val.uniq.sort.reverse.each do |i|
      @action_list << temp[i]
    end
    @action_list.flatten!
    @fighter_num = @action_list.size
  end
  
  def next_actor
    temp_actor = @action_list[@action_list.index(@cur_actor)+1]
    if temp_actor
      @cur_actor= temp_actor
    else
      @cur_actor = @action_list[0]
    end
    isdead = @cur_actor.dead?
    cal_fighter_num
    @turn += 1
    turn_begin_cal
    @actor = @cur_actor.event
    unless isdead
      $sel_body = @cur_actor
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
    end
  end

  def cal_fighter_num
    @fighter_num = @action_list.find_all{|e| !e.dead?}.size
  end
  
  def turn_begin_cal
    actor = @cur_actor
    actor.buff.each do |buff|
      instance_eval(buff.per_turn_start_effect)
    end
  end
  
  def get_first_actor
    @cur_actor = @action_list[-1]
    next_actor
    @splink.tips[0].bitmap = TIPS_POINT.clone
  end
  
  def update
    case @scene_id
    when 0
      if @cur_actor.ai
        update_ai
      else
        update_action
      end
    when 1
      update_select_target
    end
    update_cal
    update_viewpos
  end
  
  def update_select_target
    @splink.tipsvar[1][0] = true
    tpos = Fuc.getpos_by_screenpos(Mouse.pos)
    if CInput.repeat?($vkey[:Down])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([tpos[0],tpos[1]+1]))
    elsif CInput.repeat?($vkey[:Left])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([tpos[0]-1,tpos[1]]))
    elsif CInput.repeat?($vkey[:Right])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([tpos[0]+1,tpos[1]]))
    elsif CInput.repeat?($vkey[:Up])
      Mouse.set_pos(*Fuc.getpos_by_gamepos([tpos[0],tpos[1]-1]))
    end
    if Mouse.down?(1) || CInput.press?($vkey[:Check])
      tempb = action(1,tpos)
      return unless tempb
      if tempb.all?{|i| i[0]==false&&i[1]>1}
        @splink.show_text(FAILD_ATTACK_TEXT[tempb[0][1]],@cur_actor.event)
      else
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
          if (i.team&@cur_actor.team).size<=0
            if i.dead?
              err_id ||= 3
            else
              effect_arr << i
            end
          else
            err_id ||= 1
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
  
  def end_target_select
    Mouse.set_cursor(Mouse::CursorFile)
    @effectarea.dispose if @effectarea
    @enablearea.dispose if @enablearea
    create_maparea
    @splink.fillup[0].visible = true
    @scene_id = 0
  end

  def update_action
    return if $game_map.interpreter.running?
    @mousexy = Fuc.getpos_by_screenpos(Mouse.pos)
    # 四方向按键
    if @actor.movable? && CInput.dir4 > 0
      action(0,CInput.dir4)
      @actor.auto_move_path=[]
      @wayarea.dispose if @wayarea
      return
    end
    # A
    if CInput.trigger?($vkey[:Attack]) && @cur_actor.ap>=@cur_actor.get_ap_for_atk && @actor.movable?
      Mouse.set_cursor(Mouse::AttackCursor)
      if @cur_actor.atk_area
        @actor.auto_move_path=[]
        @movearea.dispose if @movearea
        @wayarea.dispose if @wayarea
        create_effectarea
        create_enablearea
        @splink.fillup[0].visible = false
        set_view_pos(@cur_actor.x,@cur_actor.y)
        @scene_id = 1
      end
      return
    end
    # TAB
    if CInput.trigger?($vkey[:Tab])
      @actor.auto_move_path=[]
      action(4)
      return
    end
    # 鼠标
    if Mouse.down?(1) && @actor.movable?
      if SceneManager.scene.mouse_in_itemrect?
      
      else
        $team_set.each do |i|
          body = i.event_id == 0 ? $game_player : i.event
          if body.x == @mousexy[0] && body.y == @mousexy[1] && !i.dead?
            $sel_body = i
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
            action(0,dir)
          end
        elsif x_dis.abs+y_dis.abs > 1
          create_wayarea
        end
      end
      return
    end
    if Mouse.press?(2)
      @splink.tipsvar[1][0] = true
      Mouse.set_cursor(Mouse::EmptyCursor)
      @actor.cantmove = true
      @wayarea.dispose if @wayarea
      @splink.fillup[0].visible = false
      @click_pos ||= Mouse.pos
      dis_x = (Mouse.pos[0]-@click_pos[0]).to_f/32
      dis_y = (Mouse.pos[1]-@click_pos[1]).to_f/32
      $game_map.set_display_pos($game_map.parallax_x+dis_x,$game_map.parallax_y+dis_y)
      Mouse.set_pos(*@click_pos)
    elsif Mouse.up?(2) && @click_pos
      Mouse.set_cursor(Mouse::CursorFile)
      @actor.cantmove = false
      @splink.fillup[0].visible = true
      Mouse.set_pos(*@click_pos)
      set_view_pos(@cur_actor.x,@cur_actor.y)
      @click_pos = nil
    end
  end
  
  def update_ai
    if @actor.movable?
      order = @cur_actor.ai.get_action
      action(*order) if order && !@cur_actor.dead?
    end
  end
  
  def create_effectarea
    @effectarea.dispose if @effectarea
    @effectarea = Effect_Area.new([0,0],@cur_actor.atk_area,true,EFFECT_AREA_C[0],EFFECT_AREA_C[1])
    ssx = $game_map.adjust_x(@mousexy[0]+@effectarea.offset_x) * 32
    ssy = $game_map.adjust_y(@mousexy[1]+@effectarea.offset_y) * 32
    @splink.fillup[3].bitmap = @effectarea.bitmap
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
  
  def create_maparea
    @movearea.dispose if @movearea
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
    elsif @cur_actor.ap <= 0
      next_actor
    end
  end
  
  def update_viewpos
    if @target_pos
      now_pos = [$game_map.parallax_x,$game_map.parallax_y]
      if (@last_sc_pos[0]-now_pos[0]).abs <= 0.01 && (@last_sc_pos[1]-now_pos[1]).abs <= 0.01
        $game_map.set_display_pos(*@target_pos)
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
      @last_action_state = !revar.flatten.include?(false)
      @order_rem << [id,para]
      cal_fighter_num
      return revar
    elsif revar
      @last_action_state = true
      @order_rem << [id,para]
      cal_fighter_num
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
      if @actor.move_straight(para)
        @cur_actor.cost_ap_for(0)
        create_maparea
        return true
      else
        return false
      end
    when 1#攻击
      temp = area_can_effect(para)
      if temp.is_a?(Array)
        tempb = []
        temp.each do |i|
          dama = i.phy_damage(@cur_actor.get_atk)
          tempb << dama
          if dama[0]
            if @cur_actor.hp_absorb_rate != 0 || @cur_actor.hp_absorb != 0
              a = @cur_actor.absorb_hp(dama[1])
              b = @cur_actor.absorb_hp_by_rate(i.hp)
              c = -a[1]-b[1]
              @splink.show_text(c.to_s,@cur_actor.event,HP_ADD_COLOR)
            end
            #if @cur_actor.sp_absorb_rate != 0 || @cur_actor.sp_absorb != 0
            #  @cur_actor.absorb_sp(dama[1])
            #  @cur_actor.absorb_sp_by_rate(i.sp)
            #end
            if i.dmg_rebound !=0 || i.dmg_rebound_rate != 0
              a = @cur_actor.rebound_damage(dama[1],i.dmg_rebound_rate,i.dmg_rebound)
              @splink.show_text(a[1].to_s,@cur_actor.event,HP_COST_COLOR) if a[0]
            end
            @splink.show_text(dama[1].to_s,i.event,HP_COST_COLOR)
            i.die if i.will_dead?
          elsif dama[1]<=1
            @splink.show_text(FAILD_ATTACK_TEXT[dama[1]],i.event)
          end
        end
        @cur_actor.cost_ap_for(1)
        return tempb
      else
        return [[false,5+temp]]
      end
    when 2#技能
    when 3#物品
    when 4#跳过
      next_actor
    end
  end
  
  def end_battle
    @battle_end_flag = true
    dispose_all
    $game_switches[1]=false
    $map_battle = nil
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
  
  def top_hatred(team_id)
    body = nil
    max = -1
    @action_list.each do |i|
      if i.hatred > max && (i.team&team_id).size<=0 && !i.dead?
        max = i.hatred
        body = i
      end
    end
    return body
  end
  
end