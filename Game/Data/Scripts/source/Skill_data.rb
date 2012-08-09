class FuckEachOther < Skill
  
  def set_ui
    @icon = "bo"
    @user_animation = []
    @target_partner_animation = []
    @target_enemy_animation = []
    @target_p_dead_animation = []
    @target_e_dead_animation = []
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
    @sp_cost = 0
    @hp_cost = 0
    @ap_cost = 12
    @hp_damage = 30
    @sp_damage = 0
    @ap_damage = 0
    @buff = [["Sick.new",60]]
    @debuff = []
    @descr = "消耗12点行动力.\n对3x3范围内敌人造成30点魔法伤害\n并且有60%概率对敌人附加中毒状态.\n施法距离:1-5"
  end
  
end

class FuckWithOutMoney < Skill
  
  def set_ui
    @icon = "fuckall"
    @user_animation = []
    @target_partner_animation = []
    @target_enemy_animation = []
    @target_p_dead_animation = []
    @target_e_dead_animation = []
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
    @sp_cost = 0
    @hp_cost = 0
    @ap_cost = 18
    @hp_damage = 60
    @sp_damage = 0
    @ap_damage = 0
    @buff = []
    @debuff = []
    @descr = "消耗18点行动力.\n立即对周身5格内敌人造成60点伤害.\n无视魔法免疫."
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