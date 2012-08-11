class FuckEachOther < Skill
  
  def set_ui
    @icon = "bo"
    @user_animation = 0
    @target_partner_animation = 0
    @target_enemy_animation = 0
    @target_p_dead_animation = 0
    @target_e_dead_animation = 0
  end

  def set_ele
    @id = 1
    @name = "剧毒新星(F)"
    @init_skill = true
    @use_req = "true"
    @use_dis_min = 1
    @use_dis_max = 5
    @hotkey = 0x46
    @hurt_enemy = true
    @hurt_partner = false
    @hurt_p_dead = false
    @hurt_e_dead = false
    @hurt_area = [ [[-1,-1,3,3]] ,true]
    @hurt_maxnum = 0
    @sp_cost = 8
    @hp_cost = 0
    @ap_cost = 10
    @hp_damage = 30
    @sp_damage = 0
    @ap_damage = 0
    @buff = [["Sick.new",60]]
    @debuff = []
    @descr = "消耗10点行动力和8点怒气.\n对3x3范围内敌人造成30点魔法伤害\n并且有60%概率对敌人附加中毒状态.\n施法距离:1-5"
  end

end

class FuckWithOutMoney < Skill
  
  def set_ui
    @icon = "fuckall"
    @user_animation = 1
    @target_partner_animation = 0
    @target_enemy_animation = 0
    @target_p_dead_animation = 0
    @target_e_dead_animation = 0
  end

  def set_ele
    @id = 2
    @name = "大爆炸(B)"
    @init_skill = true
    @use_req = "true"
    @use_dis_min = 0
    @use_dis_max = 0
    @hotkey = 0x42
    @hurt_enemy = true
    @hurt_partner = false
    @hurt_p_dead = false
    @hurt_e_dead = false
    @hurt_area = [ [[5]] ,true]
    @hurt_maxnum = 0
    @sp_cost = 12
    @hp_cost = 0
    @ap_cost = 14
    @hp_damage = 160
    @sp_damage = 0
    @ap_damage = 0
    @buff = [["Weak.new",50]]
    @debuff = []
    @descr = "消耗14点行动力和12点怒气.\n立即对周身5格内敌人造成60点伤害.\n50%的概率附加撕裂状态.\n无视魔法免疫."
  end
  
  def set_extra
    @spec_effect = ""
    @sp_cost_rate = 0
    @hp_cost_rate = 0
    @ap_cost_rate = 0
    @level = 0
    @hp_damage_add = "skill.level*100"
    @sp_damage_add = "skill.level*50"
    @ap_damage_add = "0"
    @ignore_mag_det = true
  end
  
end

class Relive < Skill
  
  def set_ui
    @icon = "relive"
    @user_animation = 0
    @target_partner_animation = 0
    @target_enemy_animation = 0
    @target_p_dead_animation = 0
    @target_e_dead_animation = 0
  end

  def set_ele
    @id = 3
    @name = "操纵死尸(R)"
    @init_skill = true
    @use_req = "true"
    @use_dis_min = 1
    @use_dis_max = 4
    @hotkey = 0x52
    @hurt_enemy = false
    @hurt_partner = false
    @hurt_p_dead = true
    @hurt_e_dead = true
    @hurt_area = [ [[0]] ,true]
    @hurt_maxnum = 1
    @sp_cost = 0
    @hp_cost = 100
    @ap_cost = 1
    @hp_damage = 60
    @sp_damage = 0
    @ap_damage = 0
    @buff = [["Ctrled.new",100]]
    @debuff = []
    @descr = "消耗1点行动力和100点生命力.\n复活并操控一具尸体为你作战.\n死尸在持续时间内不会死亡.\n死尸所受的伤害由施法者承担.\n持续2回合.\n施法距离:1-4."
  end
  
  def set_extra
    @spec_effect = "i.relive;i.hp=i.maxhp;i.ai=nil;i.team=@cur_actor.team"
    @sp_cost_rate = 0
    @hp_cost_rate = 0
    @ap_cost_rate = 0
    @level = 0
    @hp_damage_add = "skill.level*100"
    @sp_damage_add = "skill.level*50"
    @ap_damage_add = "0"
    @ignore_mag_det = false
  end
  
end