class Actor

  attr_accessor :id                           # ID
  attr_accessor :hp                           # 当前生命值
  attr_accessor :sp                           # 当前法力值
  attr_accessor :ap                           # 当前行动力
  attr_accessor :hatred                       # 当前仇恨值
  attr_accessor :buff                         # 状态
  attr_accessor :skill                        # 技能
  attr_accessor :equip                        # 装备
  attr_accessor :bag                          # 背包
  attr_accessor :name                         # 名称
  attr_accessor :head                         # 头像
  attr_accessor :atk_pic                      # 攻击行走图(缺省)
  attr_accessor :atk_cot                      # 攻击帧数(缺省)
  attr_accessor :item_pic                     # 使用物品行走图(缺省)
  attr_accessor :item_cot                     # 使用物品帧数(缺省)
  attr_accessor :skill_pic                    # 使用技能行走图(缺省)
  attr_accessor :skill_cot                    # 使用技能帧数(缺省)
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
  attr_accessor :hp_absorb_rate               # 按对方血量百分比吸血
  attr_accessor :hp_absorb                    # 按造成伤害百分比吸血
  attr_accessor :sp_absorb_rate               # 按对方法力百分比抽蓝
  attr_accessor :sp_absorb                    # 按造成伤害百分比抽蓝
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
  attr_accessor :steps                        # 操作数
  attr_accessor :dead                         # 是否死亡
  attr_accessor :ai                           # AI
  attr_accessor :buff_rem                     # BUFF编号
  attr_accessor :bag_rem                      # 物品编号
  attr_accessor :skill_rem                    # 技能编号
  attr_accessor :atk_buff                     # 法球效果
  attr_accessor :fake_skill                   # 技能壳
  attr_accessor :auto_skill                   # 自动技能
  
  def initialize(event_id=0,t_id=[0])
    @event_id = event_id
    @team = t_id
    set_ele
    set_extra
    set_tec
    set_ui
    set_ai
    set_item
    set_rd_value
    init_var
    start_play
  end
  
  def start_play
    cal_skill_rem
    cal_buff_rem
    cal_item_rem
  end

  def set_tec
    @id = 0
    @name = ""
    @skill = []
    @equip = {"武器"=>[0,nil],"防具"=>[1,nil]}
    @atk_pic = nil
    @atk_cot = 4
    @item_pic = nil
    @item_cot = 4
    @skill_pic = nil
    @skill_cot = 4
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
    @atk_buff = []
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
    @head = ""
    @animation = []
  end
  
  def set_ai
    @ai = nil
  end
  
  def set_item
    @bag = []
    @bag_rem = []
  end
  
  def set_rd_value
    @buff_rem = []
    @skill_rem = []
    @steps = 0
    @auto_skill = nil
  end

  def init_var
    @hp = @maxhp+@maxhp_add
    @sp = 0
    @ap = @maxap+@maxap_add
    @buff = []
    @hatred = @hatred_base
    @dead = false
  end
  
  def link(id)
    @event_id=id
    return self
  end
  
  def kc_auto_skill
    @auto_skill = nil
  end
  
  def phy_damage(value)
    return [false,2] if @ignore_physical
    return [false,0] if xrand(100) < @miss_rate
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
      value = 1 if value<=0
    end
    value = 1 if value == 0
    return damage(value)
  end
  
  def rebound_damage(value,re_rate,re)
    value = value*re_rate/100+re
    return mag_damage(value)
  end
  
  def damage(value)
    if value > 0
      value = value * (100-damage_reduce_rate) / 100
      value -= damage_reduce
      value = 1 if value <= 0
    end
    rdvalue = [value/10,1].max
    value = value-rdvalue+xrand(2*rdvalue)
    value = 1 if value == 0
    return god_damage(value)
  end
  
  def god_damage(value,force=false)
    return [false,1] if value > 0 && xrand(100) < @ignore_dmg_rate && !force
    return [false,4] if value > 0 && @invincible && !force
    return [true,0] if self.dead? && !force
    @buff.each{|buff| instance_eval(buff.b_damage_effect)}
    @hp -= value
    @hp = [[@maxhp,@hp].min,0].max
    @buff.each{|buff| instance_eval(buff.a_damage_effect)}
    self.die if self.will_dead?
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
  
  def god_sp_damage(value,force=false)
    return [false,1] if value > 0 && xrand(100) < @ignore_dmg_rate && !force
    return [false,4] if value > 0 && @invincible && !force
    return [true,0] if self.dead? && !force
    @sp -= value
    @sp = [[@maxsp,@sp].min,0].max
    return [true,value]
  end
  
  def ap_cost(value)
    @ap -= value
    @ap = [@ap,0].max
  end
  
  def cost_ap_for(type,para=nil)
    per_step_effect
    @steps+=1
    case type
    when 0
      ap_cost(@per_step_cost_ap+@per_step_cost_ap_add)
    when 1
      ap_cost(@atk_cost_ap+@atk_cost_ap_add)
    when 2
      ap_cost(@item_cost_ap+@item_cost_ap_add)
    when 3
      ap_cost(para)
    end
  end

  def per_step_effect
    if @hp>0
      god_damage(-@hp_rec)
      god_sp_damage(-@sp_rec)
    end
  end
  
  def learn_skill(skill)
    @skill << skill
    @skill.uniq!{|i| i.id}
    cal_skill_rem
  end
  
  def cal_skill_rem
    @skill_rem = []
    nskill = @fake_skill ? @fake_skill : @skill
    nskill.each do |i|
      @skill_rem << i.id
    end
  end
  
  def skill
    return @fake_skill ? @fake_skill : @skill
  end
  
  def rskill
    return @skill
  end
  
  def forget_skill(skill_id)
    @skill.delete_if{|i| i.id==skill_id}
    cal_skill_rem
  end
  
  def change_skill(skill_arr)
    @fake_skill = skill_arr.clone
    cal_skill_rem
  end
  
  def resc_skill
    @fake_skill = nil
    cal_skill_rem
  end
  
  def gain_item(item,num=1)
    @bag.each_with_index do |i,j|
      if i[0].id == item.id
        @bag[j][1] += num
        cal_item_rem
        return
      end
    end
    @bag << [item,num]
    cal_item_rem
  end
  
  def cal_item_rem
    @bag_rem = []
    @bag.each do |i|
      @bag_rem << [i[0].id,i[1]]
    end
  end
  
  def item_num(item)
    @bag.each do |i|
      if i[0].id == item.id
        return i[1]
      end
    end
    return 0
  end
  
  def lose_item(item_id,num=1)
    @bag.each_with_index do |i,j|
      if i[0].id == item_id
        if i[1] > num
          @bag[j][1] -= num
        else
          @bag[j][1] = 0
        end
        break
      end
    end
    @bag.delete_if{|i| i[1]==0}
    cal_item_rem
  end
  
  def add_buff(new_buff)
    @buff.each do |buff| 
      if buff.id==new_buff.id
        buff.refresh(new_buff.user)
        return
      end
    end
    @buff << new_buff
    instance_eval(new_buff.use_effect)
    cal_buff_rem
  end
  
  def kill_buff(buff_id)
    @buff.delete{|i| i.id==buff_id}
    cal_buff_rem
  end
  
  def in_buff(buff_id)
    return @buff.any?{|i| i.id == buff_id}
  end
  
  def dec_buff(buff_id)
    @buff.each do |buff| 
      if buff.id==buff_id
        instance_eval(buff.end_effect)
        break
      end
    end
    @buff.delete_if{|i| i.id==buff_id}
    cal_buff_rem
  end
  
  def cal_buff_rem
    @buff_rem = []
    @buff.each{|i| @buff_rem << i.id}
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
    max_step = get_ap_for_step < 1 ? -1 : @ap/get_ap_for_step
    return max_step
  end
  
  def event
    return @event_id == 0 ? $game_player : $game_map.events[@event_id]
  end
  
  def fighting_power
    return get_atk/10+get_maxhp/100+get_def/10
  end
  
  def change_team(val)
    @team = val
  end
  
  def get_atk
    return @atk+@atk_add
  end
  
  def get_def
    return @def+@def_add
  end
  
  def get_maxhp
    return @maxhp+@maxhp_add
  end
  
  def get_ap_for_step
    return @per_step_cost_ap+@per_step_cost_ap_add
  end
  
  def get_ap_for_atk
    return @atk_cost_ap+@atk_cost_ap_add
  end
  
  def get_ap_for_item
    return @item_cost_ap+@item_cost_ap_add
  end
  
  def absorb_hp_by_rate(hp)
    return god_damage(-hp*@hp_absorb_rate/100)
  end
  
  def absorb_hp(value)
    return god_damage(-value*@hp_absorb/100)
  end
  
  def absorb_sp_by_rate(sp)
    return god_sp_damage(-sp*@sp_absorb_rate/100)
  end
  
  def absorb_sp(value)
    return god_sp_damage(-value*@sp_absorb/100)
  end

  def xrand(value)
    return 0 if value < 1
    return $random_center.rand(value)
  end
  
  def will_dead?
    return @hp<=0 && !@dead
  end
  
  def dead?
    return @dead
  end
  
  def die
    @dead = true
    @hp = 0
    self.event.opacity = 100
    self.event.through = true
    $map_battle.next_actor if $map_battle && $map_battle.cur_actor == self && (!@auto_skill||$map_battle.real_actor==self)
    $map_battle.cal_fighter_num if $map_battle
  end
  
  def relive
    @hp = 1 if @hp <= 0
    @dead = false
    self.event.opacity = 255
    self.event.through = false
  end

end