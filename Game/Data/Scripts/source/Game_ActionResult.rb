#encoding:utf-8
#==============================================================================
# ■ Game_ActionResult
#------------------------------------------------------------------------------
# 　战斗行动结果的管理类。本类在 Game_Battler 类的内部使用。
#==============================================================================

class Game_ActionResult
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :used                     # 使用的标志
  attr_accessor :missed                   # 命中失败的标志
  attr_accessor :evaded                   # 回避成功的标志
  attr_accessor :critical                 # 关键一击的标志
  attr_accessor :success                  # 成功的标志
  attr_accessor :hp_damage                # HP 伤害
  attr_accessor :mp_damage                # MP 伤害
  attr_accessor :tp_damage                # TP 伤害
  attr_accessor :hp_drain                 # HP 吸收
  attr_accessor :mp_drain                 # MP 吸收
  attr_accessor :added_states             # 被附加的状态
  attr_accessor :removed_states           # 被解除的状态
  attr_accessor :added_buffs              # 被附加的能力强化
  attr_accessor :added_debuffs            # 被附加的能力弱化
  attr_accessor :removed_buffs            # 被解除的强化／弱化
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(battler)
    @battler = battler
    clear
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    clear_hit_flags
    clear_damage_values
    clear_status_effects
  end
  #--------------------------------------------------------------------------
  # ● 清除命中的标志
  #--------------------------------------------------------------------------
  def clear_hit_flags
    @used = false
    @missed = false
    @evaded = false
    @critical = false
    @success = false
  end
  #--------------------------------------------------------------------------
  # ● 清除伤害值
  #--------------------------------------------------------------------------
  def clear_damage_values
    @hp_damage = 0
    @mp_damage = 0
    @tp_damage = 0
    @hp_drain = 0
    @mp_drain = 0
  end
  #--------------------------------------------------------------------------
  # ● 生成伤害
  #--------------------------------------------------------------------------
  def make_damage(value, item)
    @critical = false if value == 0
    @hp_damage = value if item.damage.to_hp?
    @mp_damage = value if item.damage.to_mp?
    @mp_damage = [@battler.mp, @mp_damage].min
    @hp_drain = @hp_damage if item.damage.drain?
    @mp_drain = @mp_damage if item.damage.drain?
    @hp_drain = [@battler.hp, @hp_drain].min
    @success = true if item.damage.to_hp? || @mp_damage != 0
  end
  #--------------------------------------------------------------------------
  # ● 清除状态效果
  #--------------------------------------------------------------------------
  def clear_status_effects
    @added_states = []
    @removed_states = []
    @added_buffs = []
    @added_debuffs = []
    @removed_buffs = []
  end
  #--------------------------------------------------------------------------
  # ● 获取被附加的状态的实例数组
  #--------------------------------------------------------------------------
  def added_state_objects
    @added_states.collect {|id| $data_states[id] }
  end
  #--------------------------------------------------------------------------
  # ● 获取被解除的状态的实例数组
  #--------------------------------------------------------------------------
  def removed_state_objects
    @removed_states.collect {|id| $data_states[id] }
  end
  #--------------------------------------------------------------------------
  # ● 判定是否受到任何状态的影响
  #--------------------------------------------------------------------------
  def status_affected?
    !(@added_states.empty? && @removed_states.empty? &&
      @added_buffs.empty? && @added_debuffs.empty? && @removed_buffs.empty?)
  end
  #--------------------------------------------------------------------------
  # ● 判定最后是否命中
  #--------------------------------------------------------------------------
  def hit?
    @used && !@missed && !@evaded
  end
  #--------------------------------------------------------------------------
  # ● 获取 HP 伤害的文字
  #--------------------------------------------------------------------------
  def hp_damage_text
    if @hp_drain > 0
      fmt = @battler.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      sprintf(fmt, @battler.name, Vocab::hp, @hp_drain)
    elsif @hp_damage > 0
      fmt = @battler.actor? ? Vocab::ActorDamage : Vocab::EnemyDamage
      sprintf(fmt, @battler.name, @hp_damage)
    elsif @hp_damage < 0
      fmt = @battler.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      sprintf(fmt, @battler.name, Vocab::hp, -hp_damage)
    else
      fmt = @battler.actor? ? Vocab::ActorNoDamage : Vocab::EnemyNoDamage
      sprintf(fmt, @battler.name)
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取 MP 伤害的文字
  #--------------------------------------------------------------------------
  def mp_damage_text
    if @mp_drain > 0
      fmt = @battler.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      sprintf(fmt, @battler.name, Vocab::mp, @mp_drain)
    elsif @mp_damage > 0
      fmt = @battler.actor? ? Vocab::ActorLoss : Vocab::EnemyLoss
      sprintf(fmt, @battler.name, Vocab::mp, @mp_damage)
    elsif @mp_damage < 0
      fmt = @battler.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      sprintf(fmt, @battler.name, Vocab::mp, -@mp_damage)
    else
      ""
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取 TP 伤害的文字
  #--------------------------------------------------------------------------
  def tp_damage_text
    if @tp_damage > 0
      fmt = @battler.actor? ? Vocab::ActorLoss : Vocab::EnemyLoss
      sprintf(fmt, @battler.name, Vocab::tp, @tp_damage)
    elsif @tp_damage < 0
      fmt = @battler.actor? ? Vocab::ActorGain : Vocab::EnemyGain
      sprintf(fmt, @battler.name, Vocab::tp, -@tp_damage)
    else
      ""
    end
  end
end
