#MainActor#
class Fucker < Actor

  def set_tec
    @id = 1
    @name = "男主角"
    @skill = [AttackDown,Blinkill,SoulSword,BreakSelf,MultAttack,Kingdom]
    @equip = {"武器"=>[0,nil],"盾牌"=>[1,nil],"挂件"=>[2,nil],"指环"=>[3,nil]}
    @atk_pic = "atk"
    @atk_cot = 4
    @item_pic = "item"
    @item_cot = 4
    @skill_pic = "skill"
    @skill_cot = 4
  end
  
  def set_ui
    @head = "Alexander_B"
    @head2 = "Alexander_ele"
    @animation = []
  end
  
  def set_show_ele
    @str=[2,0]
    @het=[4,0]
    @tec=[2,0]
    @agi=[2,0]
  end

  def set_ele
    @maxhp = 250
    @maxsp = 100
    @maxap = 15
    @atk = 25
    @atk_area = [ [[0,0,1,3]] ,false]
    @atk_dis_min = 1
    @atk_dis_max = 1
    @def = 8
    @int = 16
    @mdef = 3
    @hp_rec = 1
    @sp_rec = 0
    @per_step_cost_ap = 3
    @atk_cost_ap = 5
    @item_cost_ap = 3
    @hatred_base = 1
    @miss_rate = 5
  end

  def set_extra
    @atk_buff = []
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
    @bingo_rate = 5
    @bingo_damage = 300
    @damage_reduce_rate = 0
    @damage_reduce = 0
    @cost_reduce_rate = 0
    @cost_reduce = 0
    @hp_absorb_rate = 0
    @hp_absorb = 14
    @sp_absorb_rate = 0
    @sp_absorb = 0
    @invincible = false
    @ignore_physical = false
    @ignore_magic = false
    @invisible = false
    @deinvisible = false
    @ignore_dmg_rate = 0
    @dmg_rebound = 0
    @dmg_rebound_rate = 0
  end
  
  def atk_anima
    return $random_center.rand(3)+20
  end
  
end

#MainActor2
class BeFucker < Actor

  def set_tec
    @id = 2
    @name = "女主角"
    @skill = [FuckEachOther,PlaceEachOther,Baqiyemenbo,MagicBang,Refraction,Disturb]
    @equip = {"武器"=>[0,nil],"盾牌"=>[1,nil],"挂件"=>[2,nil],"指环"=>[3,nil]}
    @atk_pic = "atk"
    @atk_cot = 4
    @item_pic = "item"
    @item_cot = 4
    @skill_pic = "skill"
    @skill_cot = 4
  end
  
  def set_ui
    @head = "Lynn_B"
    @head2 = "Lynn_ele"
    @animation = []
  end
  
  def set_show_ele
    @str=[2,0]
    @het=[2,0]
    @tec=[4,0]
    @agi=[2,0]
  end

  def set_ele
    @maxhp = 160
    @maxsp = 100
    @maxap = 12
    @atk = 10
    @atk_area = [ [[0]] ,false]
    @atk_dis_min = 1
    @atk_dis_max = 6
    @def = 2
    @int = 25
    @mdef = 13
    @hp_rec = 1
    @sp_rec = 0
    @per_step_cost_ap = 2
    @atk_cost_ap = 1
    @item_cost_ap = 2
    @hatred_base = 2
    @miss_rate = 5
  end
  
  def set_extra
    @atk_buff = []
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
    @bingo_rate = 5
    @bingo_damage = 100
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
    @ignore_dmg_rate = 10
    @dmg_rebound = 0
    @dmg_rebound_rate = 0
  end
  
  def atk_anima
    return 49
  end
  
end

#测试
class Shit < Actor

  def set_tec
    @id = 3
    @name = "狼"
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
    @maxsp = 0
    @maxap = 30
    @atk = 18
    @atk_area = [ [[0]] ,true]
    @atk_dis_min = 1
    @atk_dis_max = 1
    @def = 0
    @int = 0
    @mdef = 0
    @hp_rec = 1
    @sp_rec = 0
    @per_step_cost_ap = 3
    @atk_cost_ap = 10
    @item_cost_ap = 1
    @hatred_base = 1
    @miss_rate = 5
  end
  
  def set_ai
    @ai = SB_AI.new(self)
  end

  def set_extra
    @atk_buff = []
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
    @dmg_rebound_rate = 15
  end
  
  def atk_anima
    return 44
  end

end
#测试2
class God < Actor

  def set_tec
    @id = 4
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
    @maxsp = 8
    @maxap = 20
    @atk = 15
    @atk_area = [ [[0,0,1,3]] ,false]
    @atk_dis_min = 1
    @atk_dis_max = 3
    @def = -10
    @int = 5
    @mdef = 5
    @hp_rec = 1
    @sp_rec = -1
    @per_step_cost_ap = 3
    @atk_cost_ap = 6
    @item_cost_ap = 5
    @hatred_base = 2
    @miss_rate = 10
  end
  
  def set_extra
    @atk_buff = []
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
    @bingo_damage = 150
    @damage_reduce_rate = 0
    @damage_reduce = 0
    @cost_reduce_rate = 0
    @cost_reduce = 0
    @hp_absorb_rate = 0
    @hp_absorb = 14
    @sp_absorb_rate = 0
    @sp_absorb = 0
    @invincible = false
    @ignore_physical = false
    @ignore_magic = false
    @invisible = false
    @deinvisible = false
    @ignore_dmg_rate = 0
    @dmg_rebound = 0
    @dmg_rebound_rate = 0
  end
  
  def set_ai
    @ai = OrzAI.new(self)
  end


end
#测试
class Yangff < Actor

  def set_tec
    @id = 5
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
    @maxsp = 100
    @maxap = 10
    @atk = 11
    @atk_area = [ [[0] ] ,true]
    @atk_dis_min = 1
    @atk_dis_max = 3
    @def = 5000
    @int = 5
    @mdef = 5000
    @hp_rec = 2
    @sp_rec = 0
    @per_step_cost_ap = 1
    @atk_cost_ap = 3
    @item_cost_ap = 10
    @hatred_base = 5000
    @miss_rate = 0
  end
  
  def set_ai
    @ai = SB_AI.new(self)
  end

  def set_extra
    @atk_buff = []
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
    @bingo_rate = 12
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
    @ignore_magic = true
    @invisible = false
    @deinvisible = false
    @ignore_dmg_rate = 30
    @dmg_rebound = 0
    @dmg_rebound_rate = 100
  end

end

# 测试
class Orzfly < Actor

  def set_tec
    @id = 6
    @name = "Orzfly"
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
    @maxhp = 300000
    @maxsp = 100
    @maxap = 1
    @atk = 0
    @atk_area = [ [[0] ] ,true]
    @atk_dis_min = 1
    @atk_dis_max = 1
    @def = -100
    @int = 5
    @mdef = -100
    @hp_rec = 3
    @sp_rec = 0
    @per_step_cost_ap = 1
    @atk_cost_ap = 100
    @item_cost_ap = 100
    @hatred_base = 50000
    @miss_rate = 0
  end
  
  def set_ai
    @ai = SB_AI.new(self)
  end

  def set_extra
    @atk_buff = []
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
    @dmg_rebound_rate = 10
  end

end