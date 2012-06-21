#encoding:utf-8
#==============================================================================
# ■ Window_ShopStatus
#------------------------------------------------------------------------------
# 　商店画面中，显示“物品持有数”和“角色装备”的窗口。
#==============================================================================

class Window_ShopStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item = nil
    @page_index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_possession(4, 0)
    draw_equip_info(4, line_height * 2) if @item.is_a?(RPG::EquipItem)
  end
  #--------------------------------------------------------------------------
  # ● 设置物品
  #--------------------------------------------------------------------------
  def item=(item)
    @item = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 绘制持有数
  #--------------------------------------------------------------------------
  def draw_possession(x, y)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    draw_text(rect, Vocab::Possession)
    change_color(normal_color)
    draw_text(rect, $game_party.item_number(@item), 2)
  end
  #--------------------------------------------------------------------------
  # ● 绘制装备信息
  #--------------------------------------------------------------------------
  def draw_equip_info(x, y)
    status_members.each_with_index do |actor, i|
      draw_actor_equip_info(x, y + line_height * (i * 2.4), actor)
    end
  end
  #--------------------------------------------------------------------------
  # ● 需要绘制信息的角色数组
  #--------------------------------------------------------------------------
  def status_members
    $game_party.members[@page_index * page_size, page_size]
  end
  #--------------------------------------------------------------------------
  # ● 一页中显示的角色人数
  #--------------------------------------------------------------------------
  def page_size
    return 4
  end
  #--------------------------------------------------------------------------
  # ● 获取总页数
  #--------------------------------------------------------------------------
  def page_max
    ($game_party.members.size + page_size - 1) / page_size
  end
  #--------------------------------------------------------------------------
  # ● 绘制角色的装备信息
  #--------------------------------------------------------------------------
  def draw_actor_equip_info(x, y, actor)
    enabled = actor.equippable?(@item)
    change_color(normal_color, enabled)
    draw_text(x, y, 112, line_height, actor.name)
    item1 = current_equipped_item(actor, @item.etype_id)
    draw_actor_param_change(x, y, actor, item1) if enabled
    draw_item_name(item1, x, y + line_height, enabled)
  end
  #--------------------------------------------------------------------------
  # ● 绘制角色的能力值变化
  #--------------------------------------------------------------------------
  def draw_actor_param_change(x, y, actor, item1)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change = @item.params[param_id] - (item1 ? item1.params[param_id] : 0)
    change_color(param_change_color(change))
    draw_text(rect, sprintf("%+d", change), 2)
  end
  #--------------------------------------------------------------------------
  # ● 获取选中装备对应的能力值 ID
  #    默认下武器对应物理攻击、护甲对应物理防御。
  #--------------------------------------------------------------------------
  def param_id
    @item.is_a?(RPG::Weapon) ? 2 : 3
  end
  #--------------------------------------------------------------------------
  # ● 获取当前的装备 
  #    像双持武器这类，同一类型装备装备多个装备的场合，返回比较弱的一个。
  #--------------------------------------------------------------------------
  def current_equipped_item(actor, etype_id)
    list = []
    actor.equip_slots.each_with_index do |slot_etype_id, i|
      list.push(actor.equips[i]) if slot_etype_id == etype_id
    end
    list.min_by {|item| item ? item.params[param_id] : 0 }
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    update_page
  end
  #--------------------------------------------------------------------------
  # ● 更新翻页
  #--------------------------------------------------------------------------
  def update_page
    if visible && Input.trigger?(:A) && page_max > 1
      @page_index = (@page_index + 1) % page_max
      refresh
    end
  end
end
