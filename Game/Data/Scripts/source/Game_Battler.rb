#encoding:utf-8
#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　处理战斗者的类。Game_Actor 和 Game_Enemy 类的父类。
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 常量（使用效果）
  #--------------------------------------------------------------------------
  EFFECT_RECOVER_HP     = 11              # 恢复 HP
  EFFECT_RECOVER_MP     = 12              # 恢复 MP
  EFFECT_GAIN_TP        = 13              # 增加 TP
  EFFECT_ADD_STATE      = 21              # 附加状态
  EFFECT_REMOVE_STATE   = 22              # 解除状态
  EFFECT_ADD_BUFF       = 31              # 强化能力
  EFFECT_ADD_DEBUFF     = 32              # 弱化能力
  EFFECT_REMOVE_BUFF    = 33              # 解除能力强化
  EFFECT_REMOVE_DEBUFF  = 34              # 解除能力弱化
  EFFECT_SPECIAL        = 41              # 特殊效果
  EFFECT_GROW           = 42              # 能力提升
  EFFECT_LEARN_SKILL    = 43              # 学会技能
  EFFECT_COMMON_EVENT   = 44              # 公共事件
  #--------------------------------------------------------------------------
  # ● 常量（特殊效果）
  #--------------------------------------------------------------------------
  SPECIAL_EFFECT_ESCAPE = 0               # 撤退
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :battler_name             # 战斗图像文件名
  attr_reader   :battler_hue              # 战斗图像色相
  attr_reader   :action_times             # 行动回数
  attr_reader   :actions                  # 战斗行动（行动方）
  attr_reader   :speed                    # 行动速度
  attr_reader   :result                   # 行动结果（目标方）
  attr_accessor :last_target_index        # 最后目标的索引
  attr_accessor :animation_id             # 动画 ID
  attr_accessor :animation_mirror         # 动画左右反转的标志
  attr_accessor :sprite_effect_type       # 精灵的效果
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    @battler_name = ""
    @battler_hue = 0
    @actions = []
    @speed = 0
    @result = Game_ActionResult.new(self)
    @last_target_index = 0
    @guarding = false
    clear_sprite_effects
    super
  end
  #--------------------------------------------------------------------------
  # ● 清除精灵的效果
  #--------------------------------------------------------------------------
  def clear_sprite_effects
    @animation_id = 0
    @animation_mirror = false
    @sprite_effect_type = nil
  end
  #--------------------------------------------------------------------------
  # ● 清除战斗行动
  #--------------------------------------------------------------------------
  def clear_actions
    @actions.clear
  end
  #--------------------------------------------------------------------------
  # ● 清除状态信息
  #--------------------------------------------------------------------------
  def clear_states
    super
    @result.clear_status_effects
  end
  #--------------------------------------------------------------------------
  # ● 附加状态
  #--------------------------------------------------------------------------
  def add_state(state_id)
    if state_addable?(state_id)
      add_new_state(state_id) unless state?(state_id)
      reset_state_counts(state_id)
      @result.added_states.push(state_id).uniq!
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定状态是否可以附加
  #--------------------------------------------------------------------------
  def state_addable?(state_id)
    alive? && $data_states[state_id] && !state_resist?(state_id) &&
      !state_removed?(state_id) && !state_restrict?(state_id)
  end
  #--------------------------------------------------------------------------
  # ● 判定状态是否已被解除
  #--------------------------------------------------------------------------
  def state_removed?(state_id)
    @result.removed_states.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # ● 判定状态是否受到行动限制影响而无法附加
  #--------------------------------------------------------------------------
  def state_restrict?(state_id)
    $data_states[state_id].remove_by_restriction && restriction > 0
  end
  #--------------------------------------------------------------------------
  # ● 附加新的状态
  #--------------------------------------------------------------------------
  def add_new_state(state_id)
    die if state_id == death_state_id
    @states.push(state_id)
    on_restrict if restriction > 0
    sort_states
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 行动受到限制时的处理
  #--------------------------------------------------------------------------
  def on_restrict
    clear_actions
    states.each do |state|
      remove_state(state.id) if state.remove_by_restriction
    end
  end
  #--------------------------------------------------------------------------
  # ● 重置状态计数（回合数或步数）
  #--------------------------------------------------------------------------
  def reset_state_counts(state_id)
    state = $data_states[state_id]
    variance = 1 + [state.max_turns - state.min_turns, 0].max
    @state_turns[state_id] = state.min_turns + rand(variance)
    @state_steps[state_id] = state.steps_to_remove
  end
  #--------------------------------------------------------------------------
  # ● 解除状态
  #--------------------------------------------------------------------------
  def remove_state(state_id)
    if state?(state_id)
      revive if state_id == death_state_id
      erase_state(state_id)
      refresh
      @result.removed_states.push(state_id).uniq!
    end
  end
  #--------------------------------------------------------------------------
  # ● 死亡
  #--------------------------------------------------------------------------
  def die
    @hp = 0
    clear_states
    clear_buffs
  end
  #--------------------------------------------------------------------------
  # ● 复活
  #--------------------------------------------------------------------------
  def revive
    @hp = 1 if @hp == 0
  end
  #--------------------------------------------------------------------------
  # ● 撤退
  #--------------------------------------------------------------------------
  def escape
    hide if $game_party.in_battle
    clear_actions
    clear_states
    Sound.play_escape
  end
  #--------------------------------------------------------------------------
  # ● 强化能力
  #--------------------------------------------------------------------------
  def add_buff(param_id, turns)
    return unless alive?
    @buffs[param_id] += 1 unless buff_max?(param_id)
    erase_buff(param_id) if debuff?(param_id)
    overwrite_buff_turns(param_id, turns)
    @result.added_buffs.push(param_id).uniq!
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 弱化能力
  #--------------------------------------------------------------------------
  def add_debuff(param_id, turns)
    return unless alive?
    @buffs[param_id] -= 1 unless debuff_max?(param_id)
    erase_buff(param_id) if buff?(param_id)
    overwrite_buff_turns(param_id, turns)
    @result.added_debuffs.push(param_id).uniq!
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 解除能力强化／弱化状态
  #--------------------------------------------------------------------------
  def remove_buff(param_id)
    return unless alive?
    return if @buffs[param_id] == 0
    erase_buff(param_id)
    @buff_turns.delete(param_id)
    @result.removed_buffs.push(param_id).uniq!
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 消除能力强化／弱化
  #--------------------------------------------------------------------------
  def erase_buff(param_id)
    @buffs[param_id] = 0
    @buff_turns[param_id] = 0
  end
  #--------------------------------------------------------------------------
  # ● 判定能力强化状态
  #--------------------------------------------------------------------------
  def buff?(param_id)
    @buffs[param_id] > 0
  end
  #--------------------------------------------------------------------------
  # ● 判定能力弱化状态
  #--------------------------------------------------------------------------
  def debuff?(param_id)
    @buffs[param_id] < 0
  end
  #--------------------------------------------------------------------------
  # ● 判定能力强化是否为最大程度
  #--------------------------------------------------------------------------
  def buff_max?(param_id)
    @buffs[param_id] == 2
  end
  #--------------------------------------------------------------------------
  # ● 判定能力弱化是否为最大程度
  #--------------------------------------------------------------------------
  def debuff_max?(param_id)
    @buffs[param_id] == -2
  end
  #--------------------------------------------------------------------------
  # ● 重新设置能力强化／弱化的回合数
  #    如果新的回合数比较短，保持原值。
  #--------------------------------------------------------------------------
  def overwrite_buff_turns(param_id, turns)
    @buff_turns[param_id] = turns if @buff_turns[param_id].to_i < turns
  end
  #--------------------------------------------------------------------------
  # ● 更新状态的回总数数
  #--------------------------------------------------------------------------
  def update_state_turns
    states.each do |state|
      @state_turns[state.id] -= 1 if @state_turns[state.id] > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新强化／弱化的回总数数
  #--------------------------------------------------------------------------
  def update_buff_turns
    @buff_turns.keys.each do |param_id|
      @buff_turns[param_id] -= 1 if @buff_turns[param_id] > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 解除战斗状态
  #--------------------------------------------------------------------------
  def remove_battle_states
    states.each do |state|
      remove_state(state.id) if state.remove_at_battle_end
    end
  end
  #--------------------------------------------------------------------------
  # ● 解除所有的强化／弱化状态
  #--------------------------------------------------------------------------
  def remove_all_buffs
    @buffs.size.times {|param_id| remove_buff(param_id) }
  end
  #--------------------------------------------------------------------------
  # ● 状态的自动解除
  #     timing : 时机（1:行动结束 2:回合结束）
  #--------------------------------------------------------------------------
  def remove_states_auto(timing)
    states.each do |state|
      if @state_turns[state.id] == 0 && state.auto_removal_timing == timing
        remove_state(state.id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 强化／弱化的自动解除
  #--------------------------------------------------------------------------
  def remove_buffs_auto
    @buffs.size.times do |param_id|
      next if @buffs[param_id] == 0 || @buff_turns[param_id] > 0
      remove_buff(param_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 受到伤害时解除状态
  #--------------------------------------------------------------------------
  def remove_states_by_damage
    states.each do |state|
      if state.remove_by_damage && rand(100) < state.chance_by_damage
        remove_state(state.id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 决定行动回数
  #--------------------------------------------------------------------------
  def make_action_times
    action_plus_set.inject(1) {|r, p| rand < p ? r + 1 : r }
  end
  #--------------------------------------------------------------------------
  # ● 生成战斗行动
  #--------------------------------------------------------------------------
  def make_actions
    clear_actions
    return unless movable?
    @actions = Array.new(make_action_times) { Game_Action.new(self) }
  end
  #--------------------------------------------------------------------------
  # ● 决定行动速度
  #--------------------------------------------------------------------------
  def make_speed
    @speed = @actions.collect {|action| action.speed }.min || 0
  end
  #--------------------------------------------------------------------------
  # ● 获取当前战斗行动
  #--------------------------------------------------------------------------
  def current_action
    @actions[0]
  end
  #--------------------------------------------------------------------------
  # ● 移除当前战斗行动
  #--------------------------------------------------------------------------
  def remove_current_action
    @actions.shift
  end
  #--------------------------------------------------------------------------
  # ● 强制战斗行动
  #--------------------------------------------------------------------------
  def force_action(skill_id, target_index)
    clear_actions
    action = Game_Action.new(self, true)
    action.set_skill(skill_id)
    if target_index == -2
      action.target_index = last_target_index
    elsif target_index == -1
      action.decide_random_target
    else
      action.target_index = target_index
    end
    @actions.push(action)
  end
  #--------------------------------------------------------------------------
  # ● 计算伤害
  #--------------------------------------------------------------------------
  def make_damage_value(user, item)
    value = item.damage.eval(user, self, $game_variables)
    value *= item_element_rate(user, item)
    value *= pdr if item.physical?
    value *= mdr if item.magical?
    value *= rec if item.damage.recover?
    value = apply_critical(value) if @result.critical
    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)
    @result.make_damage(value.to_i, item)
  end
  #--------------------------------------------------------------------------
  # ● 获取技能／物品的属性修正值
  #--------------------------------------------------------------------------
  def item_element_rate(user, item)
    if item.damage.element_id < 0
      user.atk_elements.empty? ? 1.0 : elements_max_rate(user.atk_elements)
    else
      element_rate(item.damage.element_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取属性的最大修正值，返回所有属性中最有效的一个
  #     elements : 属性 ID 数组
  #--------------------------------------------------------------------------
  def elements_max_rate(elements)
    elements.inject([0.0]) {|r, i| r.push(element_rate(i)) }.max
  end
  #--------------------------------------------------------------------------
  # ● 应用关键一击
  #--------------------------------------------------------------------------
  def apply_critical(damage)
    damage * 3
  end
  #--------------------------------------------------------------------------
  # ● 应用离散度
  #--------------------------------------------------------------------------
  def apply_variance(damage, variance)
    amp = [damage.abs * variance / 100, 0].max.to_i
    var = rand(amp + 1) + rand(amp + 1) - amp
    damage >= 0 ? damage + var : damage - var
  end
  #--------------------------------------------------------------------------
  # ● 应用防御修正
  #--------------------------------------------------------------------------
  def apply_guard(damage)
    damage / (damage > 0 && guard? ? 2 * grd : 1)
  end
  #--------------------------------------------------------------------------
  # ● 处理伤害
  #    调用前需要设置好
  #    @result.hp_damage   @result.mp_damage 
  #    @result.hp_drain    @result.mp_drain
  #--------------------------------------------------------------------------
  def execute_damage(user)
    on_damage(@result.hp_damage) if @result.hp_damage > 0
    self.hp -= @result.hp_damage
    self.mp -= @result.mp_damage
    user.hp += @result.hp_drain
    user.mp += @result.mp_drain
  end
  #--------------------------------------------------------------------------
  # ● 技能／使用物品
  #    对使用目标使用完毕后，应用对于使用目标以外的效果。
  #--------------------------------------------------------------------------
  def use_item(item)
    pay_skill_cost(item) if item.is_a?(RPG::Skill)
    consume_item(item)   if item.is_a?(RPG::Item)
    item.effects.each {|effect| item_global_effect_apply(effect) }
  end
  #--------------------------------------------------------------------------
  # ● 消耗物品
  #--------------------------------------------------------------------------
  def consume_item(item)
    $game_party.consume_item(item)
  end
  #--------------------------------------------------------------------------
  # ● 应用对于使用目标以外的效果
  #--------------------------------------------------------------------------
  def item_global_effect_apply(effect)
    if effect.code == EFFECT_COMMON_EVENT
      $game_temp.reserve_common_event(effect.data_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 技能／物品的应用测试
  #    如果使用目标的 HP 或者 MP 全满时，禁止使用恢复道具。
  #--------------------------------------------------------------------------
  def item_test(user, item)
    return false if item.for_dead_friend? != dead?
    return true if $game_party.in_battle
    return true if item.for_opponent?
    return true if item.damage.recover? && item.damage.to_hp? && hp < mhp
    return true if item.damage.recover? && item.damage.to_mp? && mp < mmp
    return true if item_has_any_valid_effects?(user, item)
    return false
  end
  #--------------------------------------------------------------------------
  # ● 判定技能／物品是否有效果
  #--------------------------------------------------------------------------
  def item_has_any_valid_effects?(user, item)
    item.effects.any? {|effect| item_effect_test(user, item, effect) }
  end
  #--------------------------------------------------------------------------
  # ● 计算技能／物品的反击几率
  #--------------------------------------------------------------------------
  def item_cnt(user, item)
    return 0 unless item.physical?          # 攻击类型不是物理攻击
    return 0 unless opposite?(user)         # 队友无法反击
    return cnt                              # 返回反击几率
  end
  #--------------------------------------------------------------------------
  # ● 计算技能／物品的反射几率
  #--------------------------------------------------------------------------
  def item_mrf(user, item)
    return mrf if item.magical?             # 是魔法攻击则返回反射魔法几率
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 计算技能／物品的成功几率
  #--------------------------------------------------------------------------
  def item_hit(user, item)
    rate = item.success_rate * 0.01         # 获取成功几率
    rate *= user.hit if item.physical?      # 物理攻击：计算成功几率的乘积
    return rate                             # 返回计算后的成功几率
  end
  #--------------------------------------------------------------------------
  # ● 计算技能／物品的闪避几率
  #--------------------------------------------------------------------------
  def item_eva(user, item)
    return eva if item.physical?            # 是物理攻击则返回闪避几率
    return mev if item.magical?             # 是魔法攻击则返回闪避魔法几率
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 计算技能／物品的必杀几率
  #--------------------------------------------------------------------------
  def item_cri(user, item)
    item.damage.critical ? user.cri * (1 - cev) : 0
  end
  #--------------------------------------------------------------------------
  # ● 应用普通攻击的效果
  #--------------------------------------------------------------------------
  def attack_apply(attacker)
    item_apply(attacker, $data_skills[attacker.attack_skill_id])
  end
  #--------------------------------------------------------------------------
  # ● 应用技能／物品的效果
  #--------------------------------------------------------------------------
  def item_apply(user, item)
    @result.clear
    @result.used = item_test(user, item)
    @result.missed = (@result.used && rand >= item_hit(user, item))
    @result.evaded = (!@result.missed && rand < item_eva(user, item))
    if @result.hit?
      unless item.damage.none?
        @result.critical = (rand < item_cri(user, item))
        make_damage_value(user, item)
        execute_damage(user)
      end
      item.effects.each {|effect| item_effect_apply(user, item, effect) }
      item_user_effect(user, item)
    end
  end
  #--------------------------------------------------------------------------
  # ● 测试使用效果
  #--------------------------------------------------------------------------
  def item_effect_test(user, item, effect)
    case effect.code
    when EFFECT_RECOVER_HP
      hp < mhp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_RECOVER_MP
      mp < mmp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_ADD_STATE
      !state?(effect.data_id)
    when EFFECT_REMOVE_STATE
      state?(effect.data_id)
    when EFFECT_ADD_BUFF
      !buff_max?(effect.data_id)
    when EFFECT_ADD_DEBUFF
      !debuff_max?(effect.data_id)
    when EFFECT_REMOVE_BUFF
      buff?(effect.data_id)
    when EFFECT_REMOVE_DEBUFF
      debuff?(effect.data_id)
    when EFFECT_LEARN_SKILL
      actor? && !skills.include?($data_skills[effect.data_id])
    else
      true
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用使用效果
  #--------------------------------------------------------------------------
  def item_effect_apply(user, item, effect)
    method_table = {
      EFFECT_RECOVER_HP    => :item_effect_recover_hp,
      EFFECT_RECOVER_MP    => :item_effect_recover_mp,
      EFFECT_GAIN_TP       => :item_effect_gain_tp,
      EFFECT_ADD_STATE     => :item_effect_add_state,
      EFFECT_REMOVE_STATE  => :item_effect_remove_state,
      EFFECT_ADD_BUFF      => :item_effect_add_buff,
      EFFECT_ADD_DEBUFF    => :item_effect_add_debuff,
      EFFECT_REMOVE_BUFF   => :item_effect_remove_buff,
      EFFECT_REMOVE_DEBUFF => :item_effect_remove_debuff,
      EFFECT_SPECIAL       => :item_effect_special,
      EFFECT_GROW          => :item_effect_grow,
      EFFECT_LEARN_SKILL   => :item_effect_learn_skill,
      EFFECT_COMMON_EVENT  => :item_effect_common_event,
    }
    method_name = method_table[effect.code]
    send(method_name, user, item, effect) if method_name
  end
  #--------------------------------------------------------------------------
  # ● 应用“恢复 HP”效果
  #--------------------------------------------------------------------------
  def item_effect_recover_hp(user, item, effect)
    value = (mhp * effect.value1 + effect.value2) * rec
    value *= user.pha if item.is_a?(RPG::Item)
    value = value.to_i
    @result.hp_damage -= value
    @result.success = true
    self.hp += value
  end
  #--------------------------------------------------------------------------
  # ● 应用“恢复 MP”效果
  #--------------------------------------------------------------------------
  def item_effect_recover_mp(user, item, effect)
    value = (mmp * effect.value1 + effect.value2) * rec
    value *= user.pha if item.is_a?(RPG::Item)
    value = value.to_i
    @result.mp_damage -= value
    @result.success = true if value != 0
    self.mp += value
  end
  #--------------------------------------------------------------------------
  # ● 应用“增加 TP”效果
  #--------------------------------------------------------------------------
  def item_effect_gain_tp(user, item, effect)
    value = effect.value1.to_i
    @result.tp_damage -= value
    @result.success = true if value != 0
    self.tp += value
  end
  #--------------------------------------------------------------------------
  # ● 应用“附加状态”效果
  #--------------------------------------------------------------------------
  def item_effect_add_state(user, item, effect)
    if effect.data_id == 0
      item_effect_add_state_attack(user, item, effect)
    else
      item_effect_add_state_normal(user, item, effect)
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用“状态附加”效果：普通攻击
  #--------------------------------------------------------------------------
  def item_effect_add_state_attack(user, item, effect)
    user.atk_states.each do |state_id|
      chance = effect.value1
      chance *= state_rate(state_id)
      chance *= user.atk_states_rate(state_id)
      chance *= luk_effect_rate(user)
      if rand < chance
        add_state(state_id)
        @result.success = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用“状态附加”效果：普通
  #--------------------------------------------------------------------------
  def item_effect_add_state_normal(user, item, effect)
    chance = effect.value1
    chance *= state_rate(effect.data_id) if opposite?(user)
    chance *= luk_effect_rate(user)      if opposite?(user)
    if rand < chance
      add_state(effect.data_id)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用“状态解除”效果
  #--------------------------------------------------------------------------
  def item_effect_remove_state(user, item, effect)
    chance = effect.value1
    if rand < chance
      remove_state(effect.data_id)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用“强化能力”效果
  #--------------------------------------------------------------------------
  def item_effect_add_buff(user, item, effect)
    add_buff(effect.data_id, effect.value1)
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 应用“弱化能力”效果
  #--------------------------------------------------------------------------
  def item_effect_add_debuff(user, item, effect)
    chance = debuff_rate(effect.data_id) * luk_effect_rate(user)
    if rand < chance
      add_debuff(effect.data_id, effect.value1)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用“解除能力强化”效果
  #--------------------------------------------------------------------------
  def item_effect_remove_buff(user, item, effect)
    remove_buff(effect.data_id) if @buffs[effect.data_id] > 0
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 应用“解除能力弱化”效果
  #--------------------------------------------------------------------------
  def item_effect_remove_debuff(user, item, effect)
    remove_buff(effect.data_id) if @buffs[effect.data_id] < 0
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 应用“特殊效果”效果
  #--------------------------------------------------------------------------
  def item_effect_special(user, item, effect)
    case effect.data_id
    when SPECIAL_EFFECT_ESCAPE
      escape
    end
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 应用“能力提升”效果
  #--------------------------------------------------------------------------
  def item_effect_grow(user, item, effect)
    add_param(effect.data_id, effect.value1.to_i)
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 应用“学会技能”效果
  #--------------------------------------------------------------------------
  def item_effect_learn_skill(user, item, effect)
    learn_skill(effect.data_id) if actor?
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 应用“公共事件”效果
  #--------------------------------------------------------------------------
  def item_effect_common_event(user, item, effect)
  end
  #--------------------------------------------------------------------------
  # ● 对技能／物品使用者的效果
  #--------------------------------------------------------------------------
  def item_user_effect(user, item)
    user.tp += item.tp_gain * user.tcr
  end
  #--------------------------------------------------------------------------
  # ● 获取幸运影响程度
  #--------------------------------------------------------------------------
  def luk_effect_rate(user)
    [1.0 + (user.luk - luk) * 0.001, 0.0].max
  end
  #--------------------------------------------------------------------------
  # ● 判定是否敌对关系
  #--------------------------------------------------------------------------
  def opposite?(battler)
    actor? != battler.actor?
  end
  #--------------------------------------------------------------------------
  # ● 在地图上受到伤害时的效果
  #--------------------------------------------------------------------------
  def perform_map_damage_effect
  end
  #--------------------------------------------------------------------------
  # ● 初始化目标 TP 
  #--------------------------------------------------------------------------
  def init_tp
    self.tp = rand * 25
  end
  #--------------------------------------------------------------------------
  # ● 清除 TP 
  #--------------------------------------------------------------------------
  def clear_tp
    self.tp = 0
  end
  #--------------------------------------------------------------------------
  # ● 受到伤害时增加的 TP
  #--------------------------------------------------------------------------
  def charge_tp_by_damage(damage_rate)
    self.tp += 50 * damage_rate * tcr
  end
  #--------------------------------------------------------------------------
  # ● HP 自动恢复
  #--------------------------------------------------------------------------
  def regenerate_hp
    damage = -(mhp * hrg).to_i
    perform_map_damage_effect if $game_party.in_battle && damage > 0
    @result.hp_damage = [damage, max_slip_damage].min
    self.hp -= @result.hp_damage
  end
  #--------------------------------------------------------------------------
  # ● 获取连续伤害最大值
  #--------------------------------------------------------------------------
  def max_slip_damage
    $data_system.opt_slip_death ? hp : [hp - 1, 0].max
  end
  #--------------------------------------------------------------------------
  # ● MP 自动恢复
  #--------------------------------------------------------------------------
  def regenerate_mp
    @result.mp_damage = -(mmp * mrg).to_i
    self.mp -= @result.mp_damage
  end
  #--------------------------------------------------------------------------
  # ● TP 自动恢复
  #--------------------------------------------------------------------------
  def regenerate_tp
    self.tp += 100 * trg
  end
  #--------------------------------------------------------------------------
  # ● 全部自动恢复
  #--------------------------------------------------------------------------
  def regenerate_all
    if alive?
      regenerate_hp
      regenerate_mp
      regenerate_tp
    end
  end
  #--------------------------------------------------------------------------
  # ● 战斗开始处理
  #--------------------------------------------------------------------------
  def on_battle_start
    init_tp unless preserve_tp?
  end
  #--------------------------------------------------------------------------
  # ● 战斗行动结束时的处理
  #--------------------------------------------------------------------------
  def on_action_end
    @result.clear
    remove_states_auto(1)
    remove_buffs_auto
  end
  #--------------------------------------------------------------------------
  # ● 回合结束处理
  #--------------------------------------------------------------------------
  def on_turn_end
    @result.clear
    regenerate_all
    update_state_turns
    update_buff_turns
    remove_states_auto(2)
  end
  #--------------------------------------------------------------------------
  # ● 战斗结束处理
  #--------------------------------------------------------------------------
  def on_battle_end
    @result.clear
    remove_battle_states
    remove_all_buffs
    clear_actions
    clear_tp unless preserve_tp?
    appear
  end
  #--------------------------------------------------------------------------
  # ● 被伤害时的处理
  #--------------------------------------------------------------------------
  def on_damage(value)
    remove_states_by_damage
    charge_tp_by_damage(value.to_f / mhp)
  end
end
