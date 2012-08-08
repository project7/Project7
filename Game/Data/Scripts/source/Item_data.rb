class GodWater < Item
  
  def set_ui
    @icon = "神仙水"
    @user_animation = []
    @target_partner_animation = []
    @target_enemy_animation = []
    @target_p_dead_animation = []
    @target_e_dead_animation = []
  end
  
  def set_ele
    @id = 1
    @use_cost_num = 1
    @can_use = true
    @name = "神仙水"
    @use_req = "true"
    @use_dis_min = 0
    @use_dis_max = 5
    @hurt_enemy = true
    @hurt_partner = true
    @hurt_p_dead = false
    @hurt_e_dead = false
    @hurt_area = [ [[2]] ,true]
    @hurt_maxnum = 0
    @sp_cost = 1
    @hp_cost = 0
    @ap_cost = 0
    @hp_damage = 666
    @sp_damage = 0
    @ap_damage = 0
    @buff = []
    @debuff = []
    @descr = "一瓶神仙水.\n传说拥有生死人,肉白骨的功效.\n对范围5格内所有敌人造成666点魔法伤害.\n(卧槽这还叫神仙水?)"
  end
  
end