class YangffsChuShou < Equip

  def set_ui
    @icon = Bitmap.new(32,32)
    @atk_pic = "atk"
    @animation = []
  end
  
  def ele
    @id = 1
    @type = 0
    @name = "yangff的触手"
    @descr = "yangff身上掉落的触手."
    @use_req = "true"
    @hurt_area = nil
    @hatred_add = 0
    @miss_rate = 0
    @maxhp_add = 0
    @maxsp_add = 0
    @maxap_add = 0
    @atk_add = 20
    @def_add = 0
    @int_add = 0
    @mdef_add = 0
    @hp_rec_add = 0
    @sp_rec_add = 0
    @per_step_cost_ap_add = 0
    @atk_cost_ap_add = 1
    @item_cost_ap_add = 0
  end
  
end