class GodWater < Item
  
  def set_ui
    @icon = "godwater"
    @user_animation = []
    @target_partner_animation = []
    @target_enemy_animation = []
    @target_p_dead_animation = []
    @target_e_dead_animation = []
  end
  
  def set_ele
    @id = 1
    @use_cost_num = 2
    @can_use = true
    @name = "神仙水"
    @use_req = "true"
    @use_dis_min = 0
    @use_dis_max = 5
    @hurt_enemy = true
    @hurt_partner = true
    @hurt_p_dead = false
    @hurt_e_dead = false
    @hurt_nothing = false
    @hurt_cant_move = false
    @hurt_area = [ [[2]] ,true]
    @hurt_maxnum = 0
    @sp_cost = 0
    @hp_cost = 50
    @hp_damage = 66
    @sp_damage = 0
    @ap_damage = 0
    @buff = []
    @debuff = []
    @descr = "一瓶神仙水.\n传说拥有生死人,肉白骨的功效.\n对范围5格内所有单位造成66点魔法伤害.\n使用一次消耗2瓶.\n(卧槽这还叫神仙水?)"
  end
  
end

class YellowBook < Item
  
  def set_ui
    @icon = "book"
    @user_animation = []
    @target_partner_animation = []
    @target_enemy_animation = []
    @target_p_dead_animation = []
    @target_e_dead_animation = []
  end
  
  def set_ele
    @id = 2
    @use_cost_num = 0
    @can_use = true
    @name = "黄书"
    @use_req = "true"
    @use_dis_min = 1
    @use_dis_max = 5
    @hurt_enemy = false
    @hurt_partner = false
    @hurt_p_dead = false
    @hurt_e_dead = false
    @hurt_nothing = true
    @hurt_cant_move = false
    @hurt_area = [ [[0]] ,true]
    @hurt_maxnum = 0
    @sp_cost = 0
    @hp_cost = 0
    @hp_damage = 0
    @sp_damage = 0
    @ap_damage = 0
    @buff = []
    @debuff = []
    @descr = "可以让你自由出入战场.\n瞬间移动到5格内任意位置.\n不消耗道具.\n每次使用消耗10HP."
  end
  
  def set_extra
    @spec_effect = "@cur_actor.event.jump(para[1][0]-@cur_actor.x,para[1][1]-@cur_actor.y)"
    @sp_cost_rate = 0
    @hp_cost_rate = 0
    @ap_cost_rate = 0
    @level = 0
    @hp_damage_add = "0"
    @sp_damage_add = "0"
    @ap_damage_add = "0"
    @ignore_mag_det = false
  end
  
end