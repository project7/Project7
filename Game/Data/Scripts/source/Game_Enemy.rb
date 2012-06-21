#encoding:utf-8
#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 　管理敌人的类。本类在 Game_Troop 类 ($game_troop) 的内部使用。
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :index                    # 敌群内的索引
  attr_reader   :enemy_id                 # 敌人 ID
  attr_reader   :original_name            # 原名
  attr_accessor :letter                   # 名字后附加的字母
  attr_accessor :plural                   # 复数出现的标志
  attr_accessor :screen_x                 # 战斗画面 X 坐标
  attr_accessor :screen_y                 # 战斗画面 Y 坐标
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(index, enemy_id)
    super()
    @index = index
    @enemy_id = enemy_id
    enemy = $data_enemies[@enemy_id]
    @original_name = enemy.name
    @letter = ""
    @plural = false
    @screen_x = 0
    @screen_y = 0
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = mhp
    @mp = mmp
  end
  #--------------------------------------------------------------------------
  # ● 判定是否敌人
  #--------------------------------------------------------------------------
  def enemy?
    return true
  end
  #--------------------------------------------------------------------------
  # ● 获取队友单位
  #--------------------------------------------------------------------------
  def friends_unit
    $game_troop
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人单位
  #--------------------------------------------------------------------------
  def opponents_unit
    $game_party
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人实例
  #--------------------------------------------------------------------------
  def enemy
    $data_enemies[@enemy_id]
  end
  #--------------------------------------------------------------------------
  # ● 以数组方式获取拥有特性所有实例
  #--------------------------------------------------------------------------
  def feature_objects
    super + [enemy]
  end
  #--------------------------------------------------------------------------
  # ● 获取显示名称
  #--------------------------------------------------------------------------
  def name
    @original_name + (@plural ? letter : "")
  end
  #--------------------------------------------------------------------------
  # ● 获取普通能力的基础值
  #--------------------------------------------------------------------------
  def param_base(param_id)
    enemy.params[param_id]
  end
  #--------------------------------------------------------------------------
  # ● 获取经验值
  #--------------------------------------------------------------------------
  def exp
    enemy.exp
  end
  #--------------------------------------------------------------------------
  # ● 获取金钱
  #--------------------------------------------------------------------------
  def gold
    enemy.gold
  end
  #--------------------------------------------------------------------------
  # ● 生成物品数组
  #--------------------------------------------------------------------------
  def make_drop_items
    enemy.drop_items.inject([]) do |r, di|
      if di.kind > 0 && rand * di.denominator < drop_item_rate
        r.push(item_object(di.kind, di.data_id))
      else
        r
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取物品掉率的倍率
  #--------------------------------------------------------------------------
  def drop_item_rate
    $game_party.drop_item_double? ? 2 : 1
  end
  #--------------------------------------------------------------------------
  # ● 获取物品实例
  #--------------------------------------------------------------------------
  def item_object(kind, data_id)
    return $data_items  [data_id] if kind == 1
    return $data_weapons[data_id] if kind == 2
    return $data_armors [data_id] if kind == 3
    return nil
  end
  #--------------------------------------------------------------------------
  # ● 是否使用精灵
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗画面 Z 坐标
  #--------------------------------------------------------------------------
  def screen_z
    return 100
  end
  #--------------------------------------------------------------------------
  # ● 执行伤害效果
  #--------------------------------------------------------------------------
  def perform_damage_effect
    @sprite_effect_type = :blink
    Sound.play_enemy_damage
  end
  #--------------------------------------------------------------------------
  # ● 执行人物倒下的效果
  #--------------------------------------------------------------------------
  def perform_collapse_effect
    case collapse_type
    when 0
      @sprite_effect_type = :collapse
      Sound.play_enemy_collapse
    when 1
      @sprite_effect_type = :boss_collapse
      Sound.play_boss_collapse1
    when 2
      @sprite_effect_type = :instant_collapse
    end
  end
  #--------------------------------------------------------------------------
  # ● 变身
  #--------------------------------------------------------------------------
  def transform(enemy_id)
    @enemy_id = enemy_id
    if enemy.name != @original_name
      @original_name = enemy.name
      @letter = ""
      @plural = false
    end
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    refresh
    make_actions unless @actions.empty?
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合
  #     action : RPG::Enemy::Action
  #--------------------------------------------------------------------------
  def conditions_met?(action)
    method_table = {
      1 => :conditions_met_turns?,
      2 => :conditions_met_hp?,
      3 => :conditions_met_mp?,
      4 => :conditions_met_state?,
      5 => :conditions_met_party_level?,
      6 => :conditions_met_switch?,
    }
    method_name = method_table[action.condition_type]
    if method_name
      send(method_name, action.condition_param1, action.condition_param2)
    else
      true
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合“回合数”
  #--------------------------------------------------------------------------
  def conditions_met_turns?(param1, param2)
    n = $game_troop.turn_count
    if param2 == 0
      n == param1
    else
      n > 0 && n >= param1 && n % param2 == param1 % param2
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合“HP”
  #--------------------------------------------------------------------------
  def conditions_met_hp?(param1, param2)
    hp_rate >= param1 && hp_rate <= param2
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合“MP”
  #--------------------------------------------------------------------------
  def conditions_met_mp?(param1, param2)
    mp_rate >= param1 && mp_rate <= param2
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合“状态”
  #--------------------------------------------------------------------------
  def conditions_met_state?(param1, param2)
    state?(param1)
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合“队伍等级”
  #--------------------------------------------------------------------------
  def conditions_met_party_level?(param1, param2)
    $game_party.highest_level >= param1
  end
  #--------------------------------------------------------------------------
  # ● 判定行动条件是否符合“开关”
  #--------------------------------------------------------------------------
  def conditions_met_switch?(param1, param2)
    $game_switches[param1]
  end
  #--------------------------------------------------------------------------
  # ● 判定在当前状況下战斗行动是否有效
  #     action : RPG::Enemy::Action
  #--------------------------------------------------------------------------
  def action_valid?(action)
    conditions_met?(action) && usable?($data_skills[action.skill_id])
  end
  #--------------------------------------------------------------------------
  # ● 随机选择战斗行动
  #     action_list : RPG::Enemy::Action 的数组
  #     rating_zero : 作为零值的标准
  #--------------------------------------------------------------------------
  def select_enemy_action(action_list, rating_zero)
    sum = action_list.inject(0) {|r, a| r += a.rating - rating_zero }
    return nil if sum <= 0
    value = rand(sum)
    action_list.each do |action|
      return action if value < action.rating - rating_zero
      value -= action.rating - rating_zero
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成战斗行动
  #--------------------------------------------------------------------------
  def make_actions
    super
    return if @actions.empty?
    action_list = enemy.actions.select {|a| action_valid?(a) }
    return if action_list.empty?
    rating_max = action_list.collect {|a| a.rating }.max
    rating_zero = rating_max - 3
    action_list.reject! {|a| a.rating <= rating_zero }
    @actions.each do |action|
      action.set_enemy_action(select_enemy_action(action_list, rating_zero))
    end
  end
end
