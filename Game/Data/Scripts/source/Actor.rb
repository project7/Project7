class Actor

  attr_accessor :hp                           # 当前生命值
  attr_accessor :sp                           # 当前法力值
  attr_accessor :ap                           # 当前行动力
  attr_accessor :hatred                       # 当前仇恨值
  attr_accessor :buff                         # 状态
  attr_accessor :skill                        # 技能
  attr_accessor :equip                        # 装备
  attr_accessor :name                         # 名称
  attr_accessor :maxhp                        # 最大生命值
  attr_accessor :maxsp                        # 最大魔法值
  attr_accessor :maxap                        # 最大行动力
  attr_accessor :atk                          # 基础攻击
  attr_accessor :atk_area                     # 攻击范围
  attr_accessor :atk_dis_min                  # 最小攻击距离
  attr_accessor :atk_dis_max                  # 最大攻击距离
  attr_accessor :def                          # 基础防御
  attr_accessor :int                          # 基础法力
  attr_accessor :mdef                         # 基础法抗
  attr_accessor :hp_rec                       # 生命恢复力
  attr_accessor :sp_rec                       # 魔法恢复力
  attr_accessor :per_step_cost_ap             # 每步消耗行动力
  attr_accessor :atk_cost_ap                  # 攻击消耗行动力
  attr_accessor :item_cost_ap                 # 道具消耗行动力
  attr_accessor :hatred_base                  # 基础仇恨值
  attr_accessor :miss_rate                    # 闪避率
  attr_accessor :maxhp_add                    # 额外最大生命值
  attr_accessor :maxsp_add                    # 额外最大魔法值
  attr_accessor :maxap_add                    # 额外最大行动力
  attr_accessor :atk_add                      # 额外攻击
  attr_accessor :def_add                      # 额外防御
  attr_accessor :int_add                      # 额外法力
  attr_accessor :mdef_add                     # 额外法抗
  attr_accessor :hp_rec_add                   # 额外生命恢复
  attr_accessor :sp_rec_add                   # 额外魔法恢复
  attr_accessor :per_step_cost_ap_add         # 额外步数消耗
  attr_accessor :atk_cost_ap_add              # 额外攻击消耗
  attr_accessor :item_cost_ap_add             # 额外道具消耗
  attr_accessor :bingo_rate                   # 致命一击概率
  attr_accessor :bingo_damage                 # 致命一击伤害倍数
  attr_accessor :damage_reduce_rate           # 减免伤害%
  attr_accessor :damage_reduce                # 减免伤害
  attr_accessor :cost_reduce_rate             # 减少消耗%
  attr_accessor :cost_reduce                  # 减少消耗
  attr_accessor :hp_absorb_rate               # 吸血率
  attr_accessor :hp_absorb                    # 吸血值
  attr_accessor :sp_absorb_rate               # 吸魔法率
  attr_accessor :sp_absorb                    # 吸魔法值
  attr_accessor :invincible                   # 无敌
  attr_accessor :ignore_physical              # 物免 
  attr_accessor :ignore_magic                 # 魔免
  attr_accessor :invisible                    # 隐身
  attr_accessor :deinvisible                  # 反隐
  attr_accessor :ignore_dmg_rate              # 避免一切伤害概率
  attr_accessor :dmg_rebound                  # 反弹伤害值
  attr_accessor :dmg_rebound_rate             # 反弹伤害的百分比值
  attr_accessor :event_id                     # 关联事件ID
  attr_accessor :animation                    # 动画
  attr_accessor :team                         # 阵营
  
  def initialize(event_id=0,t_id=[0])
    @event_id = event_id
    @team = t_id
    set_ele
    set_extra
    set_tec
    set_ui
    init_var
  end

  def set_tec
    @name = ""
    @skill = []
    @equip = {"武器"=>[0,0],"防具"=>[1,0]}
  end
  
  def set_ele
    @maxhp = 1
    @maxsp = 1
    @maxap = 1
    @atk = 0
    @atk_area = nil
    @atk_dis_min = 0
    @atk_dis_max = 0
    @def = 0
    @int = 0
    @mdef = 0
    @hp_rec = 0
    @sp_rec = 0
    @per_step_cost_ap = 1
    @atk_cost_ap = 1
    @item_cost_ap = 1
    @hatred_base = 0
    @miss_rate = 0
  end
  
  def set_extra
    @maxhp_add = 0
    @maxsp_add = 0
    @maxap_add = 0
    @atk_add = 0
    @def_add = 0
    @int_add = 0
    @mdef_add = 0
    @hp_rec_add = 0
    @sp_rec_add = 0
    @per_step_cost_ap_add = 0
    @atk_cost_ap_add = 0
    @item_cost_ap_add = 0
    @bingo_rate = 0
    @bingo_damage = 0
    @damage_reduce_rate = 0
    @damage_reduce = 0
    @cost_reduce_rate = 0
    @cost_reduce = 0
    @hp_absorb_rate = 0
    @hp_absorb = 0
    @sp_absorb_rate = 0
    @sp_absorb = 0
    @invincible = false
    @ignore_physical = false
    @ignore_magic = false
    @invisible = false
    @deinvisible = false
    @ignore_dmg_rate = 0
    @dmg_rebound = 0
    @dmg_rebound_rate = 0
  end
  
  def set_ui
    @animation = []
  end

  def init_var
    @hp = @maxhp+@maxhp_add
    @sp = @maxsp+@maxsp_add
    @ap = @maxap+@maxap_add
    @buff = []
    @hatred = @hatred_base
  end
  
  def phy_damage(value)
    return [false,0] if rand(100) <= @miss_rate
    return [false,2] if @ignore_physical
    value -= @def
    value -= @def_add
    value = [value,1].max
    return damage(value)
  end
  
  def mag_damage(value)
    return [false,3] if @ignore_magic
    if value > 0
      value -= @mdef
      value -= @mdef_add
    end
    return damage(value)
  end
  
  def damage(value)
    if value > 0
      value = value * damage_reduce_rate / 100
      value -= damage_reduce
    end
    return god_damage(value)
  end
  
  def god_damage(value)
    return [false,1] if value > 0 && rand(100) < @ignore_dmg_rate
    return [false,4] if value > 0 && @invincible
    @hp -= value
    return [true,value]
  end
  
  def sp_damage(value)
    if value > 0
      value = value * cost_reduce_rate / 100
      value -= cost_reduce
    end
    return [false,0] if @sp < value
    return god_sp_damage(value)
  end
  
  def god_sp_damage(value)
    @sp -= value
    return [true,value]
  end
  
  def ap_cost(value)
    @ap -= value
  end
  
  def cost_ap_for(type)
    per_step_effect
    case type
    when 0
      ap_cost(@per_step_cost_ap+@per_step_cost_ap_add)
    when 1
      ap_cost(@atk_cost_ap+@atk_cost_ap_add)
    when 2
      ap_cost(@item_cost_ap+@item_cost_ap_add)
    end
  end
  
  def per_step_effect
    actor = self
    actor.buff.each do |i|
      eval(i.per_step_effect)
    end
    god_damage(@hp_rec)
    god_sp_damage(@sp_rec)
  end
  
  def x
    if event_id == 0
      return $game_player.x
    else
      return $game_map.events[event_id].x
    end
  end
  
  def y
    if event_id == 0
      return $game_player.y
    else
      return $game_map.events[event_id].y
    end
  end
  
  def maxstep
    return @ap/(@per_step_cost_ap+@per_step_cost_ap_add)
  end
  
  def event
    return @event_id == 0 ? $game_player : $game_map.events[@event_id]
  end
  
  def change_team(val)
    @team = val
  end
  
end