class FuckEachOther < Skill
  
  def set_ui
    @icon = "波"
    @user_animation = []
    @target_partner_animation = []
    @target_enemy_animation = []
    @target_p_dead_animation = []
    @target_e_dead_animation = []
  end

  def ele
    @id = 1
    @name = "一个波"
    @init_skill = true
    @use_req = "actor.ap => skill.ap_cost&&actor.sp => skill.sp_cost"
    @use_dis_min = 1
    @use_dis_max = 5
    @hotkey = 0x46
    @hurt_enemy = true
    @hurt_partner = false
    @hurt_p_dead = false
    @hurt_e_dead = false
    @hurt_area = [[-1,-1,3,3]]
    @hurt_maxnum = 0
    @sp_cost = 1
    @hp_cost = 0
    @ap_cost = 1
    @hp_damage = 1
    @sp_damage = 0
    @ap_damage = 0
    @buff = [[0,100]]
    @debuff = [[0,100]]
    @descr = "一个波扔过去死一片."
  end
  
end