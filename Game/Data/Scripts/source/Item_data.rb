class Massager < Item
  
  def set_ui
    @icon = Bitmap.new(32,32)
    @user_animation = []
    @target_partner_animation = []
    @target_enemy_animation = []
    @target_p_dead_animation = []
    @target_e_dead_animation = []
  end
  
  def ele
    @id = 1
    @use_cost_num = 1
    @can_use = true
    @name = "按摩棒"
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
    @hp_damage = 666
    @sp_damage = 0
    @ap_damage = 0
    @buff = []
    @debuff = []
    @descr = "一根按摩棒"
  end
  
end