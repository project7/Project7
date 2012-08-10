#MainActor
class Fucker < Actor

  def set_tec
    @id = 1
    @name = "男主角"
    @skill = []
    @equip = {"武器"=>[0,nil],"盾牌"=>[1,nil],"挂件"=>[2,nil],"指环"=>[3,nil]}
    @atk_pic = "atk"
    @atk_cot = 4
    @item_pic = "item"
    @item_cot = 4
    @skill_pic = "skill"
    @skill_cot = 4
  end
  
  def set_ui
    @head = "MainActor"
    @animation = []
  end

  def set_ele
    @maxhp = 120
    @maxsp = 80
    @maxap = 20
    @atk = 10
    @atk_area = [ [[0,0,1,3]] ,false]
    @atk_dis_min = 1
    @atk_dis_max = 1
    @def = 10
    @int = 20
    @mdef = 2
    @hp_rec = 1
    @sp_rec = 1
    @per_step_cost_ap = 3
    @atk_cost_ap = 6
    @item_cost_ap = 4
    @hatred_base = 1
    @miss_rate = 25
  end
  
  def set_extra
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
    @bingo_rate = 20
    @bingo_damage = 400
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
    @ignore_dmg_rate = 25
    @dmg_rebound = 0
    @dmg_rebound_rate = 0
  end
  
end

#测试
class Shit < Actor

  def set_tec
    @id = 2
    @name = "屎"
    @skill = []
    @equip = {}
    @atk_pic = nil
    @atk_cot = 4
    @item_pic = nil
    @item_cot = 4
    @skill_pic = nil
    @skill_cot = 4
  end
  
  def set_ele
    @maxhp = 100
    @maxsp = 100
    @maxap = 20
    @atk = 25
    @atk_area = [ [[0,0,1,2],[1,2]] ,true]
    @atk_dis_min = 3
    @atk_dis_max = 5
    @def = 5
    @int = 5
    @mdef = 5
    @hp_rec = 0
    @sp_rec = 0
    @per_step_cost_ap = 1
    @atk_cost_ap = 8
    @item_cost_ap = 1
    @hatred_base = 1000
    @miss_rate = 0
  end
  
  def set_ai
    @ai = SB_AI.new(self)
  end

  def set_extra
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
    @bingo_rate = 20
    @bingo_damage = 300
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
    @dmg_rebound_rate = 50
  end

end
#测试2
class God < Actor

  def set_tec
    @id = 3
    @name = "神"
    @skill = []
    @equip = {}
    @atk_pic = nil
    @atk_cot = 4
    @item_pic = nil
    @item_cot = 4
    @skill_pic = nil
    @skill_cot = 4
  end
  
  def set_ele
    @maxhp = 200
    @maxsp = 100
    @maxap = 10
    @atk = 15
    @atk_area = [ [[0,0,1,3]] ,false]
    @atk_dis_min = 1
    @atk_dis_max = 3
    @def = -10
    @int = 5
    @mdef = 5
    @hp_rec = 1
    @sp_rec = 1
    @per_step_cost_ap = 1
    @atk_cost_ap = 2
    @item_cost_ap = 1
    @hatred_base = 500
    @miss_rate = 0
  end
  
  def set_extra
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
    @hp_absorb = 150
    @sp_absorb_rate = 0
    @sp_absorb = 0
    @invincible = false
    @ignore_physical = false
    @ignore_magic = true
    @invisible = false
    @deinvisible = true
    @ignore_dmg_rate = 0
    @dmg_rebound = 0
    @dmg_rebound_rate = 0
  end
  
  def set_ai
    @ai = SB_AI.new(self)
  end


end
#测试
class Yangff < Actor

  def set_tec
    @id = 3
    @name = "Yangff"
    @skill = []
    @equip = {}
    @atk_pic = nil
    @atk_cot = 4
    @item_pic = nil
    @item_cot = 4
    @skill_pic = nil
    @skill_cot = 4
  end
  
  def set_ele
    @maxhp = 10
    @maxsp = 0
    @maxap = 5
    @atk = -1
    @atk_area = [ [[0] ] ,true]
    @atk_dis_min = 1
    @atk_dis_max = 1
    @def = 5000
    @int = 5
    @mdef = 5000
    @hp_rec = 2
    @sp_rec = 2
    @per_step_cost_ap = 1
    @atk_cost_ap = 10
    @item_cost_ap = 10
    @hatred_base = 5000
    @miss_rate = 50
  end
  
  def set_ai
    @ai = SB_AI.new(self)
  end

  def set_extra
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
    @bingo_rate = 6
    @bingo_damage = 1000000
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
    @ignore_dmg_rate = 50
    @dmg_rebound = 10
    @dmg_rebound_rate = 0
  end

end