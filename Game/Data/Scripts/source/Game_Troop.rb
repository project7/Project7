#encoding:utf-8
#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
# 　管理敌群和战斗相关资料的类，也可执行如战斗事件管理之类的功能。
#   本类的实例请参考 $game_troop 。
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● 敌人名字后缀的字表
  #--------------------------------------------------------------------------
  LETTER_TABLE_HALF = [' A',' B',' C',' D',' E',' F',' G',' H',' I',' J',
                       ' K',' L',' M',' N',' O',' P',' Q',' R',' S',' T',
                       ' U',' V',' W',' X',' Y',' Z']
  LETTER_TABLE_FULL = ['Ａ','Ｂ','Ｃ','Ｄ','Ｅ','Ｆ','Ｇ','Ｈ','Ｉ','Ｊ',
                       'Ｋ','Ｌ','Ｍ','Ｎ','Ｏ','Ｐ','Ｑ','Ｒ','Ｓ','Ｔ',
                       'Ｕ','Ｖ','Ｗ','Ｘ','Ｙ','Ｚ']
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :screen                   # 战斗画面的状态
  attr_reader   :interpreter              # 战斗事件用事件解释器
  attr_reader   :event_flags              # 战斗事件执行完成的标志
  attr_reader   :turn_count               # 回合数
  attr_reader   :name_counts              # 敌人名称出现数的记录 HASH
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    super
    @screen = Game_Screen.new
    @interpreter = Game_Interpreter.new
    @event_flags = {}
    clear
  end
  #--------------------------------------------------------------------------
  # ● 获取成员
  #--------------------------------------------------------------------------
  def members
    @enemies
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    @screen.clear
    @interpreter.clear
    @event_flags.clear
    @enemies = []
    @turn_count = 0
    @names_count = {}
  end
  #--------------------------------------------------------------------------
  # ● 获取敌群
  #--------------------------------------------------------------------------
  def troop
    $data_troops[@troop_id]
  end
  #--------------------------------------------------------------------------
  # ● 设置
  #--------------------------------------------------------------------------
  def setup(troop_id)
    clear
    @troop_id = troop_id
    @enemies = []
    troop.members.each do |member|
      next unless $data_enemies[member.enemy_id]
      enemy = Game_Enemy.new(@enemies.size, member.enemy_id)
      enemy.hide if member.hidden
      enemy.screen_x = member.x
      enemy.screen_y = member.y
      @enemies.push(enemy)
    end
    init_screen_tone
    make_unique_names
  end
  #--------------------------------------------------------------------------
  # ● 初始化画面的色调
  #--------------------------------------------------------------------------
  def init_screen_tone
    @screen.start_tone_change($game_map.screen.tone, 0) if $game_map
  end
  #--------------------------------------------------------------------------
  # ● 同名的敌人附加字母后缀
  #--------------------------------------------------------------------------
  def make_unique_names
    members.each do |enemy|
      next unless enemy.alive?
      next unless enemy.letter.empty?
      n = @names_count[enemy.original_name] || 0
      enemy.letter = letter_table[n % letter_table.size]
      @names_count[enemy.original_name] = n + 1
    end
    members.each do |enemy|
      n = @names_count[enemy.original_name] || 0
      enemy.plural = true if n >= 2
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人名字后缀的字表
  #--------------------------------------------------------------------------
  def letter_table
    $game_system.japanese? ? LETTER_TABLE_FULL : LETTER_TABLE_HALF
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    @screen.update
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人名字的数组
  #    战斗开始时的显示用。除去重复的。
  #--------------------------------------------------------------------------
  def enemy_names
    names = []
    members.each do |enemy|
      next unless enemy.alive?
      next if names.include?(enemy.original_name)
      names.push(enemy.original_name)
    end
    names
  end
  #--------------------------------------------------------------------------
  # ● 判定战斗事件（页）条件是否符合
  #--------------------------------------------------------------------------
  def conditions_met?(page)
    c = page.condition
    if !c.turn_ending && !c.turn_valid && !c.enemy_valid &&
       !c.actor_valid && !c.switch_valid
      return false      # 条件未设置…不执行
    end
    if @event_flags[page]
      return false      # 执行完成
    end
    if c.turn_ending    # 回合结束时
      return false unless BattleManager.turn_end?
    end
    if c.turn_valid     # 回合数
      n = @turn_count
      a = c.turn_a
      b = c.turn_b
      return false if (b == 0 && n != a)
      return false if (b > 0 && (n < 1 || n < a || n % b != a % b))
    end
    if c.enemy_valid    # 敌人
      enemy = $game_troop.members[c.enemy_index]
      return false if enemy == nil
      return false if enemy.hp_rate * 100 > c.enemy_hp
    end
    if c.actor_valid    # 角色
      actor = $game_actors[c.actor_id]
      return false if actor == nil 
      return false if actor.hp_rate * 100 > c.actor_hp
    end
    if c.switch_valid   # 开关
      return false if !$game_switches[c.switch_id]
    end
    return true         # 条件符合
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗事件
  #--------------------------------------------------------------------------
  def setup_battle_event
    return if @interpreter.running?
    return if @interpreter.setup_reserved_common_event
    troop.pages.each do |page|
      next unless conditions_met?(page)
      @interpreter.setup(page.list)
      @event_flags[page] = true if page.span <= 1
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加回合
  #--------------------------------------------------------------------------
  def increase_turn
    troop.pages.each {|page| @event_flags[page] = false if page.span == 1 }
    @turn_count += 1
  end
  #--------------------------------------------------------------------------
  # ● 计算经验值的总数
  #--------------------------------------------------------------------------
  def exp_total
    dead_members.inject(0) {|r, enemy| r += enemy.exp }
  end
  #--------------------------------------------------------------------------
  # ● 计算金钱的总数
  #--------------------------------------------------------------------------
  def gold_total
    dead_members.inject(0) {|r, enemy| r += enemy.gold } * gold_rate
  end
  #--------------------------------------------------------------------------
  # ● 获取金钱的倍率
  #--------------------------------------------------------------------------
  def gold_rate
    $game_party.gold_double? ? 2 : 1
  end
  #--------------------------------------------------------------------------
  # ● 生成物品数组
  #--------------------------------------------------------------------------
  def make_drop_items
    dead_members.inject([]) {|r, enemy| r += enemy.make_drop_items }
  end
end
