#男主角
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

  def set_ele
    @maxhp = 120
    @maxsp = 80
    @maxap = 20
    @atk = 32
    @atk_area = [[0]]
    @atk_dis_min = 1
    @atk_dis_max = 1
    @def = 2
    @int = 20
    @mdef = 2
    @hp_rec = 1
    @sp_rec = 1
    @per_step_cost_ap = 2
    @atk_cost_ap = 4
    @item_cost_ap = 2
    @hatred_base = 1
    @miss_rate = 0
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
    @maxap = 5
    @atk = 5
    @atk_area = [[1]]
    @atk_dis_min = 4
    @atk_dis_max = 6
    @def = 5
    @int = 5
    @mdef = 5
    @hp_rec = 0
    @sp_rec = 0
    @per_step_cost_ap = 1
    @atk_cost_ap = 1
    @item_cost_ap = 1
    @hatred_base = 1000
    @miss_rate = 0
  end
  
  def set_ai
    @ai = Fux.new(self)
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
    @hp_absorb = 10
    @sp_absorb_rate = 0
    @sp_absorb = 0
    @invincible = false
    @ignore_physical = false
    @ignore_magic = true
    @invisible = false
    @deinvisible = true
    @ignore_dmg_rate = 0
    @dmg_rebound = 1
    @dmg_rebound_rate = 0
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
    @maxhp = 100
    @maxsp = 100
    @maxap = 1
    @atk = 5
    @atk_area = [[-3,-3,7,1]]
    @atk_dis_min = 5
    @atk_dis_max = 10
    @def = 5
    @int = 5
    @mdef = 5
    @hp_rec = 50
    @sp_rec = 50
    @per_step_cost_ap = 1
    @atk_cost_ap = 1
    @item_cost_ap = 1
    @hatred_base = 1000
    @miss_rate = 50
  end


end