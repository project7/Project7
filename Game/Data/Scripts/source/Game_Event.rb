#encoding:utf-8
#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　处理事件的类。拥有条件判断、事件页的切换、并行处理、执行事件等功能。
#   在 Game_Map 类的内部使用。
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :trigger                  # 启动方式
  attr_reader   :list                     # 执行内容
  attr_reader   :starting                 # 启动中的标志
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #     event : RPG::Event
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    moveto(@event.x, @event.y)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 判定是否跑步状态
  #--------------------------------------------------------------------------
  def dash?
    return false if @move_route_forcing
    return false if $game_map.disable_dash?
    return CInput.press?($vkey[:Run])
  end
  #--------------------------------------------------------------------------
  # ● 判定是否可以移动
  #--------------------------------------------------------------------------
  def movable?
    return false if moving?
    return false if @move_route_forcing
    return false if @vehicle_getting_on || @vehicle_getting_off
    return false if $game_message.busy? || $game_message.visible
    return false if @cantmove
    return true
  end
  #--------------------------------------------------------------------------
  # ● 启动地图事件
  #     triggers : 启动方式的数组
  #     normal   : 优先级“与人物一样”还是其他
  #--------------------------------------------------------------------------
  def start_map_event(x, y, triggers, normal)
    $game_map.events_xy(x, y).each do |event|
      if event.trigger_in?(triggers) && event.normal_priority? == normal
        event.start
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定事件是否由确认键启动
  #--------------------------------------------------------------------------
  def check_action_event
    check_event_trigger_here([0])
    return true if $game_map.setup_starting_event
    check_event_trigger_there([0,1,2])
    $game_map.setup_starting_event
  end
  #--------------------------------------------------------------------------
  # ● 判定同位置事件是否被启动
  #--------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    start_map_event(@x, @y, triggers, false)
  end
  #--------------------------------------------------------------------------
  # ● 判定前方事件是否被启动
  #--------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    x2 = $game_map.round_x_with_direction(@x, @direction)
    y2 = $game_map.round_y_with_direction(@y, @direction)
    start_map_event(x2, y2, triggers, true)
    return if $game_map.any_event_starting?
    return unless $game_map.counter?(x2, y2)
    x3 = $game_map.round_x_with_direction(x2, @direction)
    y3 = $game_map.round_y_with_direction(y2, @direction)
    start_map_event(x3, y3, triggers, true)
  end
  #--------------------------------------------------------------------------
  # ● 初始化公有成员变量
  #--------------------------------------------------------------------------
  def init_public_members
    super
    @trigger = 0
    @list = nil
    @starting = false
  end
  #--------------------------------------------------------------------------
  # ● 初始化私有成员变量
  #--------------------------------------------------------------------------
  def init_private_members
    super
    @move_type = 0                        # 移动类型
    @erased = false                       # 暂时消除的标志
    @page = nil                           # 事件页
  end
  #--------------------------------------------------------------------------
  # ● 判定是否与人物碰撞
  #--------------------------------------------------------------------------
  def collide_with_characters?(x, y)
    super || collide_with_player_characters?(x, y)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否与玩家碰撞（包括跟随角色）
  #--------------------------------------------------------------------------
  def collide_with_player_characters?(x, y)
    normal_priority? && $game_player.collide?(x, y)
  end
  #--------------------------------------------------------------------------
  # ● 锁定（立即停止执行中的事件）
  #--------------------------------------------------------------------------
  def lock
    unless @locked
      @prelock_direction = @direction
      turn_toward_player
      @locked = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 解锁
  #--------------------------------------------------------------------------
  def unlock
    if @locked
      @locked = false
      set_direction(@prelock_direction)
    end
  end
  #--------------------------------------------------------------------------
  # ● 停止时的更新
  #--------------------------------------------------------------------------
  def update_stop
    super
    update_self_movement unless @move_route_forcing
  end
  #--------------------------------------------------------------------------
  # ● 自动移动的更新
  #--------------------------------------------------------------------------
  def update_self_movement
    if near_the_screen? && @stop_count > stop_count_threshold
      case @move_type
      when 1;  move_type_random
      when 2;  move_type_toward_player
      when 3;  move_type_custom
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否在画面的可视区域內
  #     dx : 从画面中央开始计算，左右有多少个图块。
  #     dy : 从画面中央开始计算，上下有多少个图块。
  #--------------------------------------------------------------------------
  def near_the_screen?(dx = 12, dy = 8)
    ax = $game_map.adjust_x(@real_x) - Graphics.width / 2 / 32
    ay = $game_map.adjust_y(@real_y) - Graphics.height / 2 / 32
    ax >= -dx && ax <= dx && ay >= -dy && ay <= dy
  end
  #--------------------------------------------------------------------------
  # ● 计算自动移动时停止计数最低值
  #--------------------------------------------------------------------------
  def stop_count_threshold
    30 * (5 - @move_frequency)
  end
  #--------------------------------------------------------------------------
  # ● 移动类型 : 随机
  #--------------------------------------------------------------------------
  def move_type_random
    case rand(6)
    when 0..1;  move_random
    when 2..4;  move_forward
    when 5;     @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 移动类型 : 接近
  #--------------------------------------------------------------------------
  def move_type_toward_player
    if near_the_player?
      case rand(6)
      when 0..3;  move_toward_player
      when 4;     move_random
      when 5;     move_forward
      end
    else
      move_random
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定事件是否临近玩家
  #--------------------------------------------------------------------------
  def near_the_player?
    sx = distance_x_from($game_player.x).abs
    sy = distance_y_from($game_player.y).abs
    sx + sy < 20
  end
  #--------------------------------------------------------------------------
  # ● 移动类型 : 自定义
  #--------------------------------------------------------------------------
  def move_type_custom
    update_routine_move
  end
  #--------------------------------------------------------------------------
  # ● 清除启动中的标志
  #--------------------------------------------------------------------------
  def clear_starting_flag
    @starting = false
  end
  #--------------------------------------------------------------------------
  # ● 判定执行内容是否为空
  #--------------------------------------------------------------------------
  def empty?
    !@list || @list.size <= 1
  end
  #--------------------------------------------------------------------------
  # ● 判定指定的启动方式是否能启动事件
  #     triggers : 启动方式的数组
  #--------------------------------------------------------------------------
  def trigger_in?(triggers)
    triggers.include?(@trigger)
  end
  #--------------------------------------------------------------------------
  # ● 事件启动
  #--------------------------------------------------------------------------
  def start
    return if empty?
    @starting = true
    lock if trigger_in?([0,1,2])
  end
  #--------------------------------------------------------------------------
  # ● 暂时消除
  #--------------------------------------------------------------------------
  def erase
    @erased = true
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    new_page = @erased ? nil : find_proper_page
    setup_page(new_page) if !new_page || new_page != @page
  end
  #--------------------------------------------------------------------------
  # ● 寻找条件符合的事件页
  #--------------------------------------------------------------------------
  def find_proper_page
    @event.pages.reverse.find {|page| conditions_met?(page) }
  end
  #--------------------------------------------------------------------------
  # ● 判定事件页的条件是否符合
  #--------------------------------------------------------------------------
  def conditions_met?(page)
    c = page.condition
    if c.switch1_valid
      return false unless $game_switches[c.switch1_id]
    end
    if c.switch2_valid
      return false unless $game_switches[c.switch2_id]
    end
    if c.variable_valid
      return false if $game_variables[c.variable_id] < c.variable_value
    end
    if c.self_switch_valid
      key = [@map_id, @event.id, c.self_switch_ch]
      return false if $game_self_switches[key] != true
    end
    if c.item_valid
      item = $data_items[c.item_id]
      return false unless $game_party.has_item?(item)
    end
    if c.actor_valid
      actor = $game_actors[c.actor_id]
      return false unless $game_party.members.include?(actor)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 设置事件页
  #--------------------------------------------------------------------------
  def setup_page(new_page)
    @page = new_page
    if @page
      setup_page_settings
    else
      clear_page_settings
    end
    update_bush_depth
    clear_starting_flag
    check_event_trigger_auto
  end
  #--------------------------------------------------------------------------
  # ● 清除事件页的设置
  #--------------------------------------------------------------------------
  def clear_page_settings
    @tile_id          = 0
    @character_name   = ""
    @character_index  = 0
    @move_type        = 0
    @through          = true
    @trigger          = nil
    @list             = nil
    @interpreter      = nil
  end
  #--------------------------------------------------------------------------
  # ● 设置事件页的设置
  #--------------------------------------------------------------------------
  def setup_page_settings
    @tile_id          = @page.graphic.tile_id
    @character_name   = @page.graphic.character_name
    @character_index  = @page.graphic.character_index
    if @original_direction != @page.graphic.direction
      @direction          = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction  = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern            = @page.graphic.pattern
      @original_pattern   = @pattern
    end
    @move_type          = @page.move_type
    @move_speed         = @page.move_speed
    @move_frequency     = @page.move_frequency
    @move_route         = @page.move_route
    @move_route_index   = 0
    @move_route_forcing = false
    @walk_anime         = @page.walk_anime
    @step_anime         = @page.step_anime
    @direction_fix      = @page.direction_fix
    @through            = @page.through
    @priority_type      = @page.priority_type
    @trigger            = @page.trigger
    @list               = @page.list
    @interpreter = @trigger == 4 ? Game_Interpreter.new : nil
  end
  #--------------------------------------------------------------------------
  # ● 接触事件的启动判定
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    return if $game_map.interpreter.running?
    if @trigger == 2 && $game_player.pos?(x, y)
      start if !jumping? && normal_priority?
    end
  end
  #--------------------------------------------------------------------------
  # ● 自动事件的启动判定
  #--------------------------------------------------------------------------
  def check_event_trigger_auto
    start if @trigger == 3
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    check_event_trigger_auto
    return unless @interpreter
    @interpreter.setup(@list, @event.id) unless @interpreter.running?
    @interpreter.update
  end
end
