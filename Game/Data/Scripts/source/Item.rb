class Item < Skill
  
  attr_accessor :use_cost_num
  attr_accessor :can_use
  
  
  def ele
    @id = 0
    @use_cost_num = 1
    @can_use = true
    @name = ""
    @use_req = "true"
    @use_dis_min = 0
    @use_dis_max = 0
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
    @descr = ""
  end
  
end