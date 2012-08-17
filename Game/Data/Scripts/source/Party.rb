class Party
  
  attr_accessor :members
  
  def initialize
    @members = []
  end
  
  def learn_skill(skill)
    if $map_battle
      $map_battle.cur_actor.learn_skill(skill)
    else
      @members[0].learn_skill(skill)
    end
  end
  
  def forget_skill(skill_id)
    if $map_battle
      $map_battle.cur_actor.forget_skill(skill_id)
    else
      @members[0].forget_skill(skill_id)
    end
  end
  
  def gain_item(item,num=1)
    if $map_battle
      $map_battle.cur_actor.gain_item(item,num)
    else
      @members[0].gain_item(item,num)
    end
  end
  
  def lose_item(item_id,num=1)
    if $map_battle
      $map_battle.cur_actor.lose_item(item_id,num)
    else
      @members[0].lose_item(item_id,num)
    end
  end
  
  def get_all_fake
    tarr = []
    @members.each do |i|
      tarr << i.str
      tarr << i.het
      tarr << i.tec
      tarr << i.agi
      tarr << i.ep
    end
    return tarr
  end
  
  def change_leader
    @members << @members.shift
  end
  
end