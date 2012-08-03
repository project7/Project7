class Map_Battle

  attr_accessor  :action_list
  attr_accessor  :cur_actor
  attr_accessor  :order_rem
  attr_accessor  :movearea
  attr_accessor  :wayarea
  attr_accessor  :effectarea
  attr_accessor  :enablearea

  def initialize(end_req="$team_set.size<=1")
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
  end
  
  def next_actor
    temp = @action_list[@action_list.index(@cur_actor)+1]
    @cur_actor= temp ? temp :  @action_list[0]
    @cur_actor.ap = @cur_actor.maxap
    @movearea.dispose if @movearea
    @effectarea.dispose if @effectarea
    @enablearea.dispose if @enablearea
    @wayarea.dispose if @wayarea
    set_view_pos(@cur_actor.x,@cur_actor.y)
  end
  
  def get_first_actor
    @cur_actor = @action_list[0]
    SceneManager.scene.spriteset.tips[0].bitmap = Fuc::TIPS_POINT
  end
  
  def update
    case @scene_id
    when 0
      update_action
    when 1
      update_select_target
    end
    update_cal
    update_viewpos
  end
  
  def update_select_target
    if Mouse.down?(1)
      tpos = Fuc.getpos_by_screenpos(Mouse.pos)
      if @enablearea.include?(*tpos)
        $team_set.each do |i|
          body = i.event_id == 0 ? $game_player : i.event
          if @effectarea.include?(body.x,body.y) && (i.team&@cur_actor.team).size<=0
            action(1,tpos)
            end_target_select
            break
          end
        end
      end
    elsif Mouse.down?(2)
      end_target_select
    end
  end
  
  def end_target_select
    Mouse.set_cursor(Mouse::CursorFile)
    @effectarea.dispose if @effectarea
    @enablearea.dispose if @enablearea
    create_maparea
    SceneManager.scene.spriteset.fillup[0].visible = true
    @scene_id = 0
  end

  def update_action
    return if $game_map.interpreter.running?
    @mousexy = Fuc.getpos_by_screenpos(Mouse.pos)
    @actor = @cur_actor.event
    # 四方向按键
    if @actor.movable? && CInput.dir4 > 0
      action(0,CInput.dir4)
      @actor.auto_move_path=[]
      @wayarea.dispose if @wayarea
      return
    end
    # A
    if CInput.trigger?($vkey[:Attack])
      Mouse.set_cursor(Mouse::AttackCursor)
      if @cur_actor.atk_area
        @actor.auto_move_path=[]
        @movearea.dispose if @movearea
        @wayarea.dispose if @wayarea
        create_effectarea
        create_enablearea
        SceneManager.scene.spriteset.fillup[0].visible = false
        set_view_pos(@cur_actor.x,@cur_actor.y)
        @scene_id = 1
      end
      return
    end
    # 鼠标
    if Mouse.down?(1) && !@actor.cantmove
      $team_set.each do |i|
        body = i.event_id == 0 ? $game_player : i.event
        if body.x == @mousexy[0] && body.y == @mousexy[1]
          $sel_body = body
          return
        end
      end
      $sel_body = nil
      x_dis = @actor.x-@mousexy[0]
      y_dis = @actor.y-@mousexy[1]
      if x_dis.abs+y_dis.abs == 1 && @actor.movable?
        dir = Fuc::DIR_LIST[x_dis][y_dis]
        if @actor.direction == dir && !@actor.passable?(@actor.x, @actor.y, dir)
          @actor.check_action_event
        else
          @actor.move_straight(dir)
        end
      elsif x_dis.abs+y_dis.abs > 1
        create_wayarea
      end
      return
    end
    if Mouse.press?(2)
      Mouse.set_cursor(Mouse::EmptyCursor)
      @actor.cantmove = true
      @wayarea.dispose if @wayarea
      SceneManager.scene.spriteset.fillup[0].visible = false
      @click_pos ||= Mouse.pos
      dis_x = (Mouse.pos[0]-@click_pos[0]).to_f/32
      dis_y = (Mouse.pos[1]-@click_pos[1]).to_f/32
      $game_map.set_display_pos($game_map.parallax_x+dis_x,$game_map.parallax_y+dis_y)
      Mouse.set_pos(*@click_pos)
    elsif Mouse.up?(2)
      Mouse.set_cursor(Mouse::CursorFile)
      @actor.cantmove = false
      SceneManager.scene.spriteset.fillup[0].visible = true
      Mouse.set_pos(*@click_pos)
      set_view_pos(@cur_actor.x,@cur_actor.y)
      @click_pos = nil
    end
  end
  
  def create_effectarea
    @effectarea.dispose if @effectarea
    @effectarea = Effect_Area.new([0,0],@cur_actor.atk_area,true,Fuc::EFFECT_AREA_C[0],Fuc::EFFECT_AREA_C[1])
    ssx = $game_map.adjust_x(@mousexy[0]+@effectarea.offset_x) * 32
    ssy = $game_map.adjust_y(@mousexy[1]+@effectarea.offset_y) * 32
    SceneManager.scene.spriteset.fillup[3].bitmap = @effectarea.bitmap
    SceneManager.scene.spriteset.fillup[3].x = ssx
    SceneManager.scene.spriteset.fillup[3].y = ssy
  end
  
  def create_enablearea
    @enablearea.dispose if @enablearea
    @enablearea = Effect_Area.new([@cur_actor.x,@cur_actor.y],[[@cur_actor.atk_dis_min,@cur_actor.atk_dis_max,true]],true,Fuc::ENABLE_AREA_C[0],Fuc::ENABLE_AREA_C[1])
    SceneManager.scene.spriteset.fillup[4].bitmap = @enablearea.bitmap
    SceneManager.scene.spriteset.fillup[4].x = @enablearea.screen_x
    SceneManager.scene.spriteset.fillup[4].y = @enablearea.screen_y
  end
  
  def create_maparea
    @movearea.dispose if @movearea
    @movearea = Effect_Area.new([@cur_actor.x,@cur_actor.y],[[@cur_actor.maxstep]])
    SceneManager.scene.spriteset.fillup[1].bitmap = @movearea.bitmap
    SceneManager.scene.spriteset.fillup[1].x = @movearea.screen_x
    SceneManager.scene.spriteset.fillup[1].y = @movearea.screen_y
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
    @wayarea = Effect_Area.new([@cur_actor.x,@cur_actor.y],realway,false,*Fuc::WAY_AREA_C)
    SceneManager.scene.spriteset.fillup[2].bitmap = @wayarea.bitmap
    SceneManager.scene.spriteset.fillup[2].x = @wayarea.screen_x
    SceneManager.scene.spriteset.fillup[2].y = @wayarea.screen_y
  end
  
  def update_cal
    unless @cur_actor.ap == 0
      if @last_ax != @cur_actor.x || @last_ay != @cur_actor.y
        @cur_actor.cost_ap_for(0)
        @last_ax = @cur_actor.x
        @last_ay = @cur_actor.y
        set_view_pos(@cur_actor.x,@cur_actor.y)
      elsif @cur_actor.x != @area_x || @cur_actor.y != @area_y
        create_maparea
      end
    else
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
  
  def action(id,para)
    @order_rem << [id,para]
    @actor = @cur_actor.event
    case id
    when 0#移动
      @actor.move_straight(para)
    when 1#攻击
      
    when 2
    when 3
    end
  end
  
end