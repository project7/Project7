class FuckEachOther < Skill

  def ele
    @id = 1
    @name = "测试技能"
    @init_skill = true
    @use_req = "actor.ap > skill.ap_cost"
    @use_dis_min = 1
    @use_dis_max = 5
    @hotkey = 0x46
    @hurt_enemy = true
    @hurt_partner = false
    @hurt_p_dead = false
    @hurt_e_dead = false
    @hurt_area = nil
    @hurt_maxnum = 1
    @sp_cost = 1
    @hp_cost = 0
    @ap_cost = 0
    @hp_damage = 1
    @sp_damage = 0
    @ap_damage = 0
    @buff = [[0,100]]
    @debuff = [[0,100]]
    @descr = "一个用于测试的技能."
  end
  
end