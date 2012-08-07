class Equip
  
  attr_accessor :id                                 # ID
  attr_accessor :type                               # 装备类型
  attr_accessor :name                               # 装备名称
  attr_accessor :descr                              # 装备描述
  attr_accessor :icon                               # 装备小图标
  attr_accessor :animation                          # 动画
  attr_accessor :atk_pic                            # 使用者行走图更变
  attr_accessor :atk_cot                            # 使用者行走图帧数
  attr_accessor :use_req                            # 装备使用条件(eval)
  attr_accessor :hurt_area                          # 攻击范围
  attr_accessor :hatred_add                         # 增加仇恨值
  attr_accessor :miss_rate                          # 闪避率
  attr_accessor :buff                               # buff
  attr_accessor :debuff                             # debuff
  attr_accessor :maxhp_add                          # 额外最大生命值
  attr_accessor :maxsp_add                          # 额外最大魔法值
  attr_accessor :maxap_add                          # 额外最大行动力
  attr_accessor :atk_add                            # 额外攻击
  attr_accessor :def_add                            # 额外防御
  attr_accessor :int_add                            # 额外法力
  attr_accessor :mdef_add                           # 额外法抗
  attr_accessor :hp_rec_add                         # 额外生命恢复
  attr_accessor :sp_rec_add                         # 额外魔法恢复
  attr_accessor :per_step_cost_ap_add               # 额外步数消耗
  attr_accessor :atk_cost_ap_add                    # 额外攻击消耗
  attr_accessor :item_cost_ap_add                   # 额外道具消耗
  attr_accessor :bingo_rate                         # 致命一击概率
  attr_accessor :bingo_damage                       # 致命一击伤害倍数
  attr_accessor :damage_reduce_rate                 # 减免伤害%
  attr_accessor :damage_reduce                      # 减免伤害
  attr_accessor :cost_reduce_rate                   # 减少消耗%
  attr_accessor :cost_reduce                        # 减少消耗
  attr_accessor :hp_absorb_rate                     # 吸血率
  attr_accessor :hp_absorb                          # 吸血值
  attr_accessor :sp_absorb_rate                     # 吸魔法率
  attr_accessor :sp_absorb                          # 吸魔法值
  attr_accessor :invisible                          # 隐身
  attr_accessor :deinvisible                        # 反隐
  attr_accessor :ignore_dmg_rate                    # 避免一切伤害概率
  attr_accessor :dmg_rebound                        # 反弹伤害值
  attr_accessor :dmg_rebound_rate                   # 反弹伤害的百分比值
  
  def initialize
    set_ui
    set_ele
    set_extra
  end
  
  def set_ui
    @icon = nil
    @atk_pic = ""
    @atk_cot = 4
    @animation = []
  end
  
  def ele
    @id = 0
    @type = 0
    @name = ""
    @descr = ""
    @use_req = "true"
    @hurt_area = nil
    @hatred_add = 0
    @miss_rate = 0
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
  end
  
  def extra
    @buff = []
    @debuff = []
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
    @invisible = false
    @deinvisible = false
    @ignore_dmg_rate = 0
    @dmg_rebound = 0
    @dmg_rebound_rate = 0
  end
  
end