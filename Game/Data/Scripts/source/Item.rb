class Item < Skill
  
  attr_accessor :use_cost_num
  attr_accessor :can_use

  def set_ele
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
    @hurt_nothing = false
    @hurt_cant_move = false
    @hurt_area = nil
    @hurt_maxnum = 1
    @sp_cost = 0
    @hp_cost = 0
    @ap_cost = 0
    @hp_damage = 1
    @sp_damage = 0
    @ap_damage = 0
    @buff = [[0,100]]
    @debuff = [[0,100]]
    @descr = ""
  end
  
  def enough_to_use(num,ap,hp,sp)
    if num >= @use_cost_num
      if ap
        if hp >= @hp_cost
          if sp>=@sp_cost
            if @can_use
              if eval(@use_req)
                return true
              else
                return 0
              end
            else
              return 2
            end
          else
            return 3
          end
        else
          return 4
        end
      else
        return 5
      end
    else
      return 6
    end
  end
  
end