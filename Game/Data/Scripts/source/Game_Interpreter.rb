#encoding:utf-8
#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　事件指令的解释器。
#   本类在 Game_Map、Game_Troop、Game_Event 类的内部使用。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :map_id             # 地图 ID
  attr_reader   :event_id           # 事件 ID（仅指普通事件）
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #     depth : 堆置深度
  #--------------------------------------------------------------------------
  def initialize(depth = 0)
    @depth = depth
    check_overflow
    clear
  end
  #--------------------------------------------------------------------------
  # ● 检查堆置是否过深
  #    普通情况下深度不允许超过 100 。
  #    更深的堆置可能会导致递归事件无限循环，所以直接引发退出错误。
  #--------------------------------------------------------------------------
  def check_overflow
    if @depth >= 100
      msgbox(Vocab::EventOverflow)
      exit
    end
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    @map_id = 0
    @event_id = 0
    @list = nil                       # 执行内容
    @index = 0                        # 索引
    @branch = {}                      # 分歧数据
    @fiber = nil                      # 纤程
  end
  #--------------------------------------------------------------------------
  # ● 设置事件
  #--------------------------------------------------------------------------
  def setup(list, event_id = 0)
    clear
    @map_id = $game_map.map_id
    @event_id = event_id
    @list = list
    create_fiber
  end
  #--------------------------------------------------------------------------
  # ● 生成纤程
  #--------------------------------------------------------------------------
  def create_fiber
    @fiber = Fiber.new { run } if @list
  end
  #--------------------------------------------------------------------------
  # ● 储存实例
  #    对纤程进行 Marshal 的自定义方法。
  #    此方法将事件的执行位置也一并保存起来。
  #--------------------------------------------------------------------------
  def marshal_dump
    [@depth, @map_id, @event_id, @list, @index + 1, @branch]
  end
  #--------------------------------------------------------------------------
  # ● 读取实例
  #     obj : marshal_dump 中储存的实例（数组）
  #    恢复多个数据（@depth、@map_id 等）的状态，必要时重新创建纤程。
  #--------------------------------------------------------------------------
  def marshal_load(obj)
    @depth, @map_id, @event_id, @list, @index, @branch = obj
    create_fiber
  end
  #--------------------------------------------------------------------------
  # ● 判定当前地图是否和事件启动时的地图相同
  #--------------------------------------------------------------------------
  def same_map?
    @map_id == $game_map.map_id
  end
  #--------------------------------------------------------------------------
  # ● 检测／设置预定调用的公共事件
  #--------------------------------------------------------------------------
  def setup_reserved_common_event
    if $game_temp.common_event_reserved?
      setup($game_temp.reserved_common_event.list)
      $game_temp.clear_common_event
      true
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ● 执行
  #--------------------------------------------------------------------------
  def run
    wait_for_message
    while @list[@index] do
      execute_command
      @index += 1
    end
    Fiber.yield
    @fiber = nil
  end
  #--------------------------------------------------------------------------
  # ● 判定是否执行中
  #--------------------------------------------------------------------------
  def running?
    @fiber != nil
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    @fiber.resume if @fiber
  end
  #--------------------------------------------------------------------------
  # ● 迭代角色（ID）
  #     param : 大于 1 则返回 ID 指定的角色、0 则迭代全体角色
  #     注意：此方法和 iterate_actor_index(param) 的参数设置有所不同
  #--------------------------------------------------------------------------
  def iterate_actor_id(param)
    if param == 0
      $game_party.members.each {|actor| yield actor }
    else
      actor = $game_actors[param]
      yield actor if actor
    end
  end
  #--------------------------------------------------------------------------
  # ● 迭代队员（可变）
  #     param1 : 0 则固定、1 则变量指定
  #     param2 : 角色 ID 或变量 ID 
  #--------------------------------------------------------------------------
  def iterate_actor_var(param1, param2)
    if param1 == 0
      iterate_actor_id(param2) {|actor| yield actor }
    else
      iterate_actor_id($game_variables[param2]) {|actor| yield actor }
    end
  end
  #--------------------------------------------------------------------------
  # ● 迭代队员（索引）
  #     param : 0 则返回索引指定的队员、 -1 则迭代全体队员
  #--------------------------------------------------------------------------
  def iterate_actor_index(param)
    if param < 0
      $game_party.members.each {|actor| yield actor }
    else
      actor = $game_party.members[param]
      yield actor if actor
    end
  end
  #--------------------------------------------------------------------------
  # ● 迭代敌人（索引）
  #     param : 0 则返回索引指定的敌人、 -1 则迭代全体敌人
  #--------------------------------------------------------------------------
  def iterate_enemy_index(param)
    if param < 0
      $game_troop.members.each {|enemy| yield enemy }
    else
      enemy = $game_troop.members[param]
      yield enemy if enemy
    end
  end
  #--------------------------------------------------------------------------
  # ● 迭代战斗者（敌群全体、队伍全体考虑）
  #     param1 : 0 则敌人、1 则角色
  #     param2 : 敌人的索引 或 角色的 ID
  #--------------------------------------------------------------------------
  def iterate_battler(param1, param2)
    if $game_party.in_battle
      if param1 == 0
        iterate_enemy_index(param2) {|enemy| yield enemy }
      else
        iterate_actor_id(param2) {|actor| yield actor }
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取画面系指令的对象
  #--------------------------------------------------------------------------
  def screen
    $game_party.in_battle ? $game_troop.screen : $game_map.screen
  end
  #--------------------------------------------------------------------------
  # ● 执行事件指令
  #--------------------------------------------------------------------------
  def execute_command
    command = @list[@index]
    @params = command.parameters
    @indent = command.indent
    method_name = "command_#{command.code}"
    send(method_name) if respond_to?(method_name)
  end
  #--------------------------------------------------------------------------
  # ● 跳过指令
  #    如果下一句事件指令的缩进比当前深的话，跳过当前指令。
  #--------------------------------------------------------------------------
  def command_skip
    @index += 1 while @list[@index + 1].indent > @indent
  end
  #--------------------------------------------------------------------------
  # ● 获取下一句事件指令的代码
  #--------------------------------------------------------------------------
  def next_event_code
    @list[@index + 1].code
  end
  #--------------------------------------------------------------------------
  # ● 获取事件
  #     param : -1 则玩家、0 则本事件、其他 则是指定的事件ID 
  #--------------------------------------------------------------------------
  def get_character(param)
    if $game_party.in_battle
      nil
    elsif param < 0
      $game_player
    else
      events = same_map? ? $game_map.events : {}
      events[param > 0 ? param : @event_id]
    end
  end
  #--------------------------------------------------------------------------
  # ● 计算操作的数值
  #     operation    : 操作行为（0:增加 1:减少）
  #     operand_type : 操作类型（0:常量 1:变量）
  #     operand      : 操作数值（数值 或 变量 的 ID）
  #--------------------------------------------------------------------------
  def operate_value(operation, operand_type, operand)
    value = operand_type == 0 ? operand : $game_variables[operand]
    operation == 0 ? value : -value
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def wait(duration)
    duration.times { Fiber.yield }
  end
  #--------------------------------------------------------------------------
  # ● 等待显示信息
  #--------------------------------------------------------------------------
  def wait_for_message
    Fiber.yield while $game_message.busy?
  end
  #--------------------------------------------------------------------------
  # ● 显示文字
  #--------------------------------------------------------------------------
  def command_101
    wait_for_message
    $game_message.face_name = @params[0]
    $game_message.face_index = @params[1]
    $game_message.background = @params[2]
    $game_message.position = @params[3]
    while next_event_code == 401       # 文字数据
      @index += 1
      $game_message.add(@list[@index].parameters[0])
    end
    case next_event_code
    when 102  # 显示选项
      @index += 1
      setup_choices(@list[@index].parameters)
    when 103  # 数值输入的处理
      @index += 1
      setup_num_input(@list[@index].parameters)
    when 104  # 物品选择的处理
      @index += 1
      setup_item_choice(@list[@index].parameters)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 显示选项
  #--------------------------------------------------------------------------
  def command_102
    wait_for_message
    setup_choices(@params)
    Fiber.yield while $game_message.choice?
  end
  #--------------------------------------------------------------------------
  # ● 设置选项
  #--------------------------------------------------------------------------
  def setup_choices(params)
    params[0].each {|s| $game_message.choices.push(s) }
    $game_message.choice_cancel_type = params[1]
    $game_message.choice_proc = Proc.new {|n| @branch[@indent] = n }
  end
  #--------------------------------------------------------------------------
  # ● [**] 的时候
  #--------------------------------------------------------------------------
  def command_402
    command_skip if @branch[@indent] != @params[0]
  end
  #--------------------------------------------------------------------------
  # ● 取消的时候
  #--------------------------------------------------------------------------
  def command_403
    command_skip if @branch[@indent] != 4
  end
  #--------------------------------------------------------------------------
  # ● 数值输入的处理
  #--------------------------------------------------------------------------
  def command_103
    wait_for_message
    setup_num_input(@params)
    Fiber.yield while $game_message.num_input?
  end
  #--------------------------------------------------------------------------
  # ● 设置数值输入
  #--------------------------------------------------------------------------
  def setup_num_input(params)
    $game_message.num_input_variable_id = params[0]
    $game_message.num_input_digits_max = params[1]
  end
  #--------------------------------------------------------------------------
  # ● 物品选择的处理
  #--------------------------------------------------------------------------
  def command_104
    wait_for_message
    setup_item_choice(@params)
    Fiber.yield while $game_message.item_choice?
  end
  #--------------------------------------------------------------------------
  # ● 设置物品选择
  #--------------------------------------------------------------------------
  def setup_item_choice(params)
    $game_message.item_choice_variable_id = params[0]
  end
  #--------------------------------------------------------------------------
  # ● 显示滚动文字
  #--------------------------------------------------------------------------
  def command_105
    Fiber.yield while $game_message.visible
    $game_message.scroll_mode = true
    $game_message.scroll_speed = @params[0]
    $game_message.scroll_no_fast = @params[1]
    while next_event_code == 405
      @index += 1
      $game_message.add(@list[@index].parameters[0])
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 添加注释
  #--------------------------------------------------------------------------
  def command_108
    @comments = [@params[0]]
    while next_event_code == 408
      @index += 1
      @comments.push(@list[@index].parameters[0])
    end
  end
  #--------------------------------------------------------------------------
  # ● 条件分歧
  #--------------------------------------------------------------------------
  def command_111
    result = false
    case @params[0]
    when 0  # 开关
      result = ($game_switches[@params[1]] == (@params[2] == 0))
    when 1  # 变量
      value1 = $game_variables[@params[1]]
      if @params[2] == 0
        value2 = @params[3]
      else
        value2 = $game_variables[@params[3]]
      end
      case @params[4]
      when 0  # 等于
        result = (value1 == value2)
      when 1  # 以上
        result = (value1 >= value2)
      when 2  # 以下
        result = (value1 <= value2)
      when 3  # 大于
        result = (value1 > value2)
      when 4  # 小于
        result = (value1 < value2)
      when 5  # 不等于
        result = (value1 != value2)
      end
    when 2  # 独立开关
      if @event_id > 0
        key = [@map_id, @event_id, @params[1]]
        result = ($game_self_switches[key] == (@params[2] == 0))
      end
    when 3  # 计时器
      if $game_timer.working?
        if @params[2] == 0
          result = ($game_timer.sec >= @params[1])
        else
          result = ($game_timer.sec <= @params[1])
        end
      end
    when 4  # 角色
      actor = $game_actors[@params[1]]
      if actor
        case @params[2]
        when 0  # 在队伍时
          result = ($game_party.members.include?(actor))
        when 1  # 名字
          result = (actor.name == @params[3])
        when 2  # 职业
          result = (actor.class_id == @params[3])
        when 3  # 技能
          result = (actor.skill_learn?($data_skills[@params[3]]))
        when 4  # 武器
          result = (actor.weapons.include?($data_weapons[@params[3]]))
        when 5  # 护甲
          result = (actor.armors.include?($data_armors[@params[3]]))
        when 6  # 状态
          result = (actor.state?(@params[3]))
        end
      end
    when 5  # 敌人
      enemy = $game_troop.members[@params[1]]
      if enemy
        case @params[2]
        when 0  # 出现
          result = (enemy.alive?)
        when 1  # 状态
          result = (enemy.state?(@params[3]))
        end
      end
    when 6  # 事件
      character = get_character(@params[1])
      if character
        result = (character.direction == @params[2])
      end
    when 7  # 金钱
      case @params[2]
      when 0  # 以上
        result = ($game_party.gold >= @params[1])
      when 1  # 以下
        result = ($game_party.gold <= @params[1])
      when 2  # 低于
        result = ($game_party.gold < @params[1])
      end
    when 8   # 物品
      result = $game_party.has_item?($data_items[@params[1]])
    when 9   # 武器
      result = $game_party.has_item?($data_weapons[@params[1]], @params[2])
    when 10  # 护甲
      result = $game_party.has_item?($data_armors[@params[1]], @params[2])
    when 11  # 按下按钮
      result = Input.press?(@params[1])
    when 12  # 脚本
      result = eval(@params[1])
    when 13  # 载具
      result = ($game_player.vehicle == $game_map.vehicles[@params[1]])
    end
    @branch[@indent] = result
    command_skip if !@branch[@indent]
  end
  #--------------------------------------------------------------------------
  # ● 除此之外
  #--------------------------------------------------------------------------
  def command_411
    command_skip if @branch[@indent]
  end
  #--------------------------------------------------------------------------
  # ● 循环
  #--------------------------------------------------------------------------
  def command_112
  end
  #--------------------------------------------------------------------------
  # ● 重复
  #--------------------------------------------------------------------------
  def command_413
    begin
      @index -= 1
    end until @list[@index].indent == @indent
  end
  #--------------------------------------------------------------------------
  # ● 跳出循环
  #--------------------------------------------------------------------------
  def command_113
    loop do
      @index += 1
      return if @index >= @list.size - 1
      return if @list[@index].code == 413 && @list[@index].indent < @indent
    end
  end
  #--------------------------------------------------------------------------
  # ● 中止事件处理
  #--------------------------------------------------------------------------
  def command_115
    @index = @list.size
  end
  #--------------------------------------------------------------------------
  # ● 公共事件
  #--------------------------------------------------------------------------
  def command_117
    common_event = $data_common_events[@params[0]]
    if common_event
      child = Game_Interpreter.new(@depth + 1)
      child.setup(common_event.list, same_map? ? @event_id : 0)
      child.run
    end
  end
  #--------------------------------------------------------------------------
  # ● 添加标签
  #--------------------------------------------------------------------------
  def command_118
  end
  #--------------------------------------------------------------------------
  # ● 转至标签
  #--------------------------------------------------------------------------
  def command_119
    label_name = @params[0]
    @list.size.times do |i|
      if @list[i].code == 118 && @list[i].parameters[0] == label_name
        @index = i
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 操作开关
  #--------------------------------------------------------------------------
  def command_121
    (@params[0]..@params[1]).each do |i|
      $game_switches[i] = (@params[2] == 0)
    end
  end
  #--------------------------------------------------------------------------
  # ● 变量操作
  #--------------------------------------------------------------------------
  def command_122
    value = 0
    case @params[3]  # 操作方式
    when 0  # 常量
      value = @params[4]
    when 1  # 变量
      value = $game_variables[@params[4]]
    when 2  # 随机数
      value = @params[4] + rand(@params[5] - @params[4] + 1)
    when 3  # 游戏数据
      value = game_data_operand(@params[4], @params[5], @params[6])
    when 4  # 脚本
      value = eval(@params[4])
    end
    (@params[0]..@params[1]).each do |i|
      operate_variable(i, @params[2], value)
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取变量操作用的游戏数据
  #--------------------------------------------------------------------------
  def game_data_operand(type, param1, param2)
    case type
    when 0  # 物品
      return $game_party.item_number($data_items[param1])
    when 1  # 武器
      return $game_party.item_number($data_weapons[param1])
    when 2  # 护甲
      return $game_party.item_number($data_armors[param1])
    when 3  # 角色
      actor = $game_actors[param1]
      if actor
        case param2
        when 0      # 等级
          return actor.level
        when 1      # 经验值
          return actor.exp
        when 2      # HP
          return actor.hp
        when 3      # MP
          return actor.mp
        when 4..11  # 普通能力值
          return actor.param(param2 - 4)
        end
      end
    when 4  # 敌人
      enemy = $game_troop.members[param1]
      if enemy
        case param2
        when 0      # HP
          return enemy.hp
        when 1      # MP
          return enemy.mp
        when 2..9   # 普通能力值
          return enemy.param(param2 - 2)
        end
      end
    when 5  # 地图人物
      character = get_character(param1)
      if character
        case param2
        when 0  # X 坐标
          return character.x
        when 1  # Y 坐标
          return character.y
        when 2  # 方向
          return character.direction
        when 3  # 画面 X 坐标
          return character.screen_x
        when 4  # 画面 Y 坐标
          return character.screen_y
        end
      end
    when 6  # 队伍
      actor = $game_party.members[param1]
      return actor ? actor.id : 0
    when 7  # 其他
      case param1
      when 0  # 地图 ID
        return $game_map.map_id
      when 1  # 队伍人数
        return $game_party.members.size
      when 2  # 金钱
        return $game_party.gold
      when 3  # 步数
        return $game_party.steps
      when 4  # 游戏时间
        return Graphics.frame_count / Graphics.frame_rate
      when 5  # 计时器
        return $game_timer.sec
      when 6  # 存档回数
        return $game_system.save_count
      when 7  # 战斗回数
        return $game_system.battle_count
      end
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 操作变量
  #--------------------------------------------------------------------------
  def operate_variable(variable_id, operation_type, value)
    begin
      case operation_type
      when 0  # 代入
        $game_variables[variable_id] = value
      when 1  # 加法
        $game_variables[variable_id] += value
      when 2  # 减法
        $game_variables[variable_id] -= value
      when 3  # 乘法
        $game_variables[variable_id] *= value
      when 4  # 除法
        $game_variables[variable_id] /= value
      when 5  # 取余
        $game_variables[variable_id] %= value
      end
    rescue
      $game_variables[variable_id] = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 操作独立开关
  #--------------------------------------------------------------------------
  def command_123
    if @event_id > 0
      key = [@map_id, @event_id, @params[0]]
      $game_self_switches[key] = (@params[1] == 0)
    end
  end
  #--------------------------------------------------------------------------
  # ● 操作计时器
  #--------------------------------------------------------------------------
  def command_124
    if @params[0] == 0  # 开始
      $game_timer.start(@params[1] * Graphics.frame_rate)
    else                # 停止
      $game_timer.stop
    end
  end
  #--------------------------------------------------------------------------
  # ● 增减持有金钱
  #--------------------------------------------------------------------------
  def command_125
    value = operate_value(@params[0], @params[1], @params[2])
    $game_party.gain_gold(value)
  end
  #--------------------------------------------------------------------------
  # ● 增减物品
  #--------------------------------------------------------------------------
  def command_126
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_items[@params[0]], value)
  end
  #--------------------------------------------------------------------------
  # ● 增减武器
  #--------------------------------------------------------------------------
  def command_127
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_weapons[@params[0]], value, @params[4])
  end
  #--------------------------------------------------------------------------
  # ● 增减护甲
  #--------------------------------------------------------------------------
  def command_128
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_armors[@params[0]], value, @params[4])
  end
  #--------------------------------------------------------------------------
  # ● 队伍管理
  #--------------------------------------------------------------------------
  def command_129
    actor = $game_actors[@params[0]]
    if actor
      if @params[1] == 0    # 入队
        if @params[2] == 1  # 初始化
          $game_actors[@params[0]].setup(@params[0])
        end
        $game_party.add_actor(@params[0])
      else                  # 离队
        $game_party.remove_actor(@params[0])
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更改战斗 BGM 
  #--------------------------------------------------------------------------
  def command_132
    $game_system.battle_bgm = @params[0]
  end
  #--------------------------------------------------------------------------
  # ● 更改战斗结束 ME 
  #--------------------------------------------------------------------------
  def command_133
    $game_system.battle_end_me = @params[0]
  end
  #--------------------------------------------------------------------------
  # ● 设置禁用存档
  #--------------------------------------------------------------------------
  def command_134
    $game_system.save_disabled = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # ● 设置禁用菜单
  #--------------------------------------------------------------------------
  def command_135
    $game_system.menu_disabled = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # ● 设置禁用遇敌
  #--------------------------------------------------------------------------
  def command_136
    $game_system.encounter_disabled = (@params[0] == 0)
    $game_player.make_encounter_count
  end
  #--------------------------------------------------------------------------
  # ● 设置禁用整队
  #--------------------------------------------------------------------------
  def command_137
    $game_system.formation_disabled = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # ● 更改窗口色调
  #--------------------------------------------------------------------------
  def command_138
    $game_system.window_tone = @params[0]
  end
  #--------------------------------------------------------------------------
  # ● 场所移动
  #--------------------------------------------------------------------------
  def command_201
    return if $game_party.in_battle
    Fiber.yield while $game_player.transfer? || $game_message.visible
    if @params[0] == 0                      # 直接指定
      map_id = @params[1]
      x = @params[2]
      y = @params[3]
    else                                    # 变量指定
      map_id = $game_variables[@params[1]]
      x = $game_variables[@params[2]]
      y = $game_variables[@params[3]]
    end
    $game_player.reserve_transfer(map_id, x, y, @params[4])
    $game_temp.fade_type = @params[5]
    Fiber.yield while $game_player.transfer?
  end
  #--------------------------------------------------------------------------
  # ● 设置载具位置
  #--------------------------------------------------------------------------
  def command_202
    if @params[1] == 0                      # 直接指定
      map_id = @params[2]
      x = @params[3]
      y = @params[4]
    else                                    # 变量指定
      map_id = $game_variables[@params[2]]
      x = $game_variables[@params[3]]
      y = $game_variables[@params[4]]
    end
    vehicle = $game_map.vehicles[@params[0]]
    vehicle.set_location(map_id, x, y) if vehicle
  end
  #--------------------------------------------------------------------------
  # ● 设置事件的位置
  #--------------------------------------------------------------------------
  def command_203
    character = get_character(@params[0])
    if character
      if @params[1] == 0                      # 直接指定
        character.moveto(@params[2], @params[3])
      elsif @params[1] == 1                   # 变量指定
        new_x = $game_variables[@params[2]]
        new_y = $game_variables[@params[3]]
        character.moveto(new_x, new_y)
      else                                    # 与其他事件交换
        character2 = get_character(@params[2])
        character.swap(character2) if character2
      end
      character.set_direction(@params[4]) if @params[4] > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 地图卷动
  #--------------------------------------------------------------------------
  def command_204
    return if $game_party.in_battle
    Fiber.yield while $game_map.scrolling?
    $game_map.start_scroll(@params[0], @params[1], @params[2])
  end
  #--------------------------------------------------------------------------
  # ● 设置移动路径
  #--------------------------------------------------------------------------
  def command_205
    $game_map.refresh if $game_map.need_refresh
    character = get_character(@params[0])
    if character
      character.force_move_route(@params[1])
      Fiber.yield while character.move_route_forcing if @params[1].wait
    end
  end
  #--------------------------------------------------------------------------
  # ● 载具的乘降
  #--------------------------------------------------------------------------
  def command_206
    $game_player.get_on_off_vehicle
  end
  #--------------------------------------------------------------------------
  # ● 更改透明状态
  #--------------------------------------------------------------------------
  def command_211
    $game_player.transparent = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # ● 显示动画
  #--------------------------------------------------------------------------
  def command_212
    character = get_character(@params[0])
    if character
      character.animation_id = @params[1]
      Fiber.yield while character.animation_id > 0 if @params[2]
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示心情图标
  #--------------------------------------------------------------------------
  def command_213
    character = get_character(@params[0])
    if character
      character.balloon_id = @params[1]
      Fiber.yield while character.balloon_id > 0 if @params[2]
    end
  end
  #--------------------------------------------------------------------------
  # ● 暂时消除事件
  #--------------------------------------------------------------------------
  def command_214
    $game_map.events[@event_id].erase if same_map? && @event_id > 0
  end
  #--------------------------------------------------------------------------
  # ● 更改队列前进
  #--------------------------------------------------------------------------
  def command_216
    $game_player.followers.visible = (@params[0] == 0)
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # ● 集合队伍成员
  #--------------------------------------------------------------------------
  def command_217
    return if $game_party.in_battle
    $game_player.followers.gather
    Fiber.yield until $game_player.followers.gather?
  end
  #--------------------------------------------------------------------------
  # ● 淡出画面
  #--------------------------------------------------------------------------
  def command_221
    Fiber.yield while $game_message.visible
    screen.start_fadeout(30)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # ● 淡入画面
  #--------------------------------------------------------------------------
  def command_222
    Fiber.yield while $game_message.visible
    screen.start_fadein(30)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # ● 更改画面的色调
  #--------------------------------------------------------------------------
  def command_223
    screen.start_tone_change(@params[0], @params[1])
    wait(@params[1]) if @params[2]
  end
  #--------------------------------------------------------------------------
  # ● 画面闪烁
  #--------------------------------------------------------------------------
  def command_224
    screen.start_flash(@params[0], @params[1])
    wait(@params[1]) if @params[2]
  end
  #--------------------------------------------------------------------------
  # ● 画面震动
  #--------------------------------------------------------------------------
  def command_225
    screen.start_shake(@params[0], @params[1], @params[2])
    wait(@params[1]) if @params[2]
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def command_230
    wait(@params[0])
  end
  #--------------------------------------------------------------------------
  # ● 显示图片
  #--------------------------------------------------------------------------
  def command_231
    if @params[3] == 0    # 直接指定
      x = @params[4]
      y = @params[5]
    else                  # 变量指定
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].show(@params[1], @params[2],
      x, y, @params[6], @params[7], @params[8], @params[9])
  end
  #--------------------------------------------------------------------------
  # ● 移动图片
  #--------------------------------------------------------------------------
  def command_232
    if @params[3] == 0    # 直接指定
      x = @params[4]
      y = @params[5]
    else                  # 变量指定
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].move(@params[2], x, y, @params[6],
      @params[7], @params[8], @params[9], @params[10])
    wait(@params[10]) if @params[11]
  end
  #--------------------------------------------------------------------------
  # ● 旋转图片
  #--------------------------------------------------------------------------
  def command_233
    screen.pictures[@params[0]].rotate(@params[1])
  end
  #--------------------------------------------------------------------------
  # ● 更改图片的色调
  #--------------------------------------------------------------------------
  def command_234
    screen.pictures[@params[0]].start_tone_change(@params[1], @params[2])
    wait(@params[2]) if @params[3]
  end
  #--------------------------------------------------------------------------
  # ● 消除图片
  #--------------------------------------------------------------------------
  def command_235
    screen.pictures[@params[0]].erase
  end
  #--------------------------------------------------------------------------
  # ● 设置天气
  #--------------------------------------------------------------------------
  def command_236
    return if $game_party.in_battle
    screen.change_weather(@params[0], @params[1], @params[2])
    wait(@params[2]) if @params[3]
  end
  #--------------------------------------------------------------------------
  # ● 播放 BGM 
  #--------------------------------------------------------------------------
  def command_241
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # ● 淡出 BGM 
  #--------------------------------------------------------------------------
  def command_242
    RPG::BGM.fade(@params[0] * 1000)
  end
  #--------------------------------------------------------------------------
  # ● 记忆 BGM 
  #--------------------------------------------------------------------------
  def command_243
    $game_system.save_bgm
  end
  #--------------------------------------------------------------------------
  # ● 恢复 BGM 
  #--------------------------------------------------------------------------
  def command_244
    $game_system.replay_bgm
  end
  #--------------------------------------------------------------------------
  # ● 播放 BGS 
  #--------------------------------------------------------------------------
  def command_245
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # ● 淡出 BGS 
  #--------------------------------------------------------------------------
  def command_246
    RPG::BGS.fade(@params[0] * 1000)
  end
  #--------------------------------------------------------------------------
  # ● 播放 ME 
  #--------------------------------------------------------------------------
  def command_249
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # ● 播放 SE 
  #--------------------------------------------------------------------------
  def command_250
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # ● 停止 SE 
  #--------------------------------------------------------------------------
  def command_251
    RPG::SE.stop
  end
  #--------------------------------------------------------------------------
  # ● 播放影像
  #--------------------------------------------------------------------------
  def command_261
    Fiber.yield while $game_message.visible
    Fiber.yield
    name = @params[0]
    Graphics.play_movie('Movies/' + name) unless name.empty?
  end
  #--------------------------------------------------------------------------
  # ● 更改地图名称显示
  #--------------------------------------------------------------------------
  def command_281
    $game_map.name_display = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # ● 更改图块组
  #--------------------------------------------------------------------------
  def command_282
    $game_map.change_tileset(@params[0])
  end
  #--------------------------------------------------------------------------
  # ● 更改战场背景
  #--------------------------------------------------------------------------
  def command_283
    $game_map.change_battleback(@params[0], @params[1])
  end
  #--------------------------------------------------------------------------
  # ● 更改远景
  #--------------------------------------------------------------------------
  def command_284
    $game_map.change_parallax(@params[0], @params[1], @params[2],
                              @params[3], @params[4])
  end
  #--------------------------------------------------------------------------
  # ● 获取指定位置的信息
  #--------------------------------------------------------------------------
  def command_285
    if @params[2] == 0      # 直接指定
      x = @params[3]
      y = @params[4]
    else                    # 变量指定
      x = $game_variables[@params[3]]
      y = $game_variables[@params[4]]
    end
    case @params[1]
    when 0      # 地形标志
      value = $game_map.terrain_tag(x, y)
    when 1      # 事件 ID
      value = $game_map.event_id_xy(x, y)
    when 2..4   # 图块 ID
      value = $game_map.tile_id(x, y, @params[1] - 2)
    else        # 区域 ID
      value = $game_map.region_id(x, y)
    end
    $game_variables[@params[0]] = value
  end
  #--------------------------------------------------------------------------
  # ● 战斗的处理
  #--------------------------------------------------------------------------
  def command_301
    return if $game_party.in_battle
    if @params[0] == 0                      # 直接指定
      troop_id = @params[1]
    elsif @params[0] == 1                   # 变量指定
      troop_id = $game_variables[@params[1]]
    else                                    # 地图指定的敌群
      troop_id = $game_player.make_encounter_troop_id
    end
    if $data_troops[troop_id]
      BattleManager.setup(troop_id, @params[2], @params[3])
      BattleManager.event_proc = Proc.new {|n| @branch[@indent] = n }
      $game_player.make_encounter_count
      SceneManager.call(Scene_Battle)
    end
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 胜利的时候
  #--------------------------------------------------------------------------
  def command_601
    command_skip if @branch[@indent] != 0
  end
  #--------------------------------------------------------------------------
  # ● 撤退的时候
  #--------------------------------------------------------------------------
  def command_602
    command_skip if @branch[@indent] != 1
  end
  #--------------------------------------------------------------------------
  # ● 全灭的时候
  #--------------------------------------------------------------------------
  def command_603
    command_skip if @branch[@indent] != 2
  end
  #--------------------------------------------------------------------------
  # ● 商店的处理
  #--------------------------------------------------------------------------
  def command_302
    return if $game_party.in_battle
    goods = [@params]
    while next_event_code == 605
      @index += 1
      goods.push(@list[@index].parameters)
    end
    SceneManager.call(Scene_Shop)
    SceneManager.scene.prepare(goods, @params[4])
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 名字输入的处理
  #--------------------------------------------------------------------------
  def command_303
    return if $game_party.in_battle
    if $data_actors[@params[0]]
      SceneManager.call(Scene_Name)
      SceneManager.scene.prepare(@params[0], @params[1])
      Fiber.yield
    end
  end
  #--------------------------------------------------------------------------
  # ● 增减 HP 
  #--------------------------------------------------------------------------
  def command_311
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      next if actor.dead?
      actor.change_hp(value, @params[5])
      actor.perform_collapse_effect if actor.dead?
    end
    SceneManager.goto(Scene_Gameover) if $game_party.all_dead?
  end
  #--------------------------------------------------------------------------
  # ● 增减 MP 
  #--------------------------------------------------------------------------
  def command_312
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.mp += value
    end
  end
  #--------------------------------------------------------------------------
  # ● 更改状态
  #--------------------------------------------------------------------------
  def command_313
    iterate_actor_var(@params[0], @params[1]) do |actor|
      already_dead = actor.dead?
      if @params[2] == 0
        actor.add_state(@params[3])
      else
        actor.remove_state(@params[3])
      end
      actor.perform_collapse_effect if actor.dead? && !already_dead
    end
  end
  #--------------------------------------------------------------------------
  # ● 完全恢复
  #--------------------------------------------------------------------------
  def command_314
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.recover_all
    end
  end
  #--------------------------------------------------------------------------
  # ● 增减经验值
  #--------------------------------------------------------------------------
  def command_315
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.change_exp(actor.exp + value, @params[5])
    end
  end
  #--------------------------------------------------------------------------
  # ● 增减等级
  #--------------------------------------------------------------------------
  def command_316
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.change_level(actor.level + value, @params[5])
    end
  end
  #--------------------------------------------------------------------------
  # ● 增减能力值
  #--------------------------------------------------------------------------
  def command_317
    value = operate_value(@params[3], @params[4], @params[5])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.add_param(@params[2], value)
    end
  end
  #--------------------------------------------------------------------------
  # ● 增减技能
  #--------------------------------------------------------------------------
  def command_318
    iterate_actor_var(@params[0], @params[1]) do |actor|
      if @params[2] == 0
        actor.learn_skill(@params[3])
      else
        actor.forget_skill(@params[3])
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更换装备
  #--------------------------------------------------------------------------
  def command_319
    actor = $game_actors[@params[0]]
    actor.change_equip_by_id(@params[1], @params[2]) if actor
  end
  #--------------------------------------------------------------------------
  # ● 更改名字
  #--------------------------------------------------------------------------
  def command_320
    actor = $game_actors[@params[0]]
    actor.name = @params[1] if actor
  end
  #--------------------------------------------------------------------------
  # ● 更改职业
  #--------------------------------------------------------------------------
  def command_321
    actor = $game_actors[@params[0]]
    actor.change_class(@params[1]) if actor && $data_classes[@params[1]]
  end
  #--------------------------------------------------------------------------
  # ● 更改角色图像
  #--------------------------------------------------------------------------
  def command_322
    actor = $game_actors[@params[0]]
    if actor
      actor.set_graphic(@params[1], @params[2], @params[3], @params[4])
    end
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # ● 更改载具的图像
  #--------------------------------------------------------------------------
  def command_323
    vehicle = $game_map.vehicles[@params[0]]
    vehicle.set_graphic(@params[1], @params[2]) if vehicle
  end
  #--------------------------------------------------------------------------
  # ● 更改称号
  #--------------------------------------------------------------------------
  def command_324
    actor = $game_actors[@params[0]]
    actor.nickname = @params[1] if actor
  end
  #--------------------------------------------------------------------------
  # ● 增减敌人的 HP 
  #--------------------------------------------------------------------------
  def command_331
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      return if enemy.dead?
      enemy.change_hp(value, @params[4])
      enemy.perform_collapse_effect if enemy.dead?
    end
  end
  #--------------------------------------------------------------------------
  # ● 增减敌人的 MP 
  #--------------------------------------------------------------------------
  def command_332
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.mp += value
    end
  end
  #--------------------------------------------------------------------------
  # ● 更改敌人的状态
  #--------------------------------------------------------------------------
  def command_333
    iterate_enemy_index(@params[0]) do |enemy|
      already_dead = enemy.dead?
      if @params[1] == 0
        enemy.add_state(@params[2])
      else
        enemy.remove_state(@params[2])
      end
      enemy.perform_collapse_effect if enemy.dead? && !already_dead
    end
  end
  #--------------------------------------------------------------------------
  # ● 敌人完全恢复
  #--------------------------------------------------------------------------
  def command_334
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.recover_all
    end
  end
  #--------------------------------------------------------------------------
  # ● 敌人出现
  #--------------------------------------------------------------------------
  def command_335
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.appear
      $game_troop.make_unique_names
    end
  end
  #--------------------------------------------------------------------------
  # ● 敌人变身
  #--------------------------------------------------------------------------
  def command_336
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.transform(@params[1])
      $game_troop.make_unique_names
    end
  end
  #--------------------------------------------------------------------------
  # ● 显示战斗动画
  #--------------------------------------------------------------------------
  def command_337
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.animation_id = @params[1] if enemy.alive?
    end
  end
  #--------------------------------------------------------------------------
  # ● 强制战斗行动
  #--------------------------------------------------------------------------
  def command_339
    iterate_battler(@params[0], @params[1]) do |battler|
      next if battler.death_state?
      battler.force_action(@params[2], @params[3])
      BattleManager.force_action(battler)
      Fiber.yield while BattleManager.action_forced?
    end
  end
  #--------------------------------------------------------------------------
  # ● 中止战斗
  #--------------------------------------------------------------------------
  def command_340
    BattleManager.abort
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 打开菜单画面
  #--------------------------------------------------------------------------
  def command_351
    return if $game_party.in_battle
    SceneManager.call(Scene_Menu)
    Window_MenuCommand::init_command_position
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 打开存档画面
  #--------------------------------------------------------------------------
  def command_352
    return if $game_party.in_battle
    SceneManager.call(Scene_Save)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 游戏结束
  #--------------------------------------------------------------------------
  def command_353
    SceneManager.goto(Scene_Gameover)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 返回标题画面
  #--------------------------------------------------------------------------
  def command_354
    SceneManager.goto(Scene_Title)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 脚本
  #--------------------------------------------------------------------------
  def command_355
    script = @list[@index].parameters[0] + "\n"
    while next_event_code == 655
      @index += 1
      script += @list[@index].parameters[0] + "\n"
    end
    eval(script)
  end
end
