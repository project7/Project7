#encoding:utf-8
#==============================================================================
# ■ Scene_ItemBase
#------------------------------------------------------------------------------
# 　物品画面和技能画面的共同父类
#==============================================================================

class Scene_ItemBase < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    create_actor_window
  end
  #--------------------------------------------------------------------------
  # ● 生成角色窗口
  #--------------------------------------------------------------------------
  def create_actor_window
    @actor_window = Window_MenuActor.new
    @actor_window.set_handler(:ok,     method(:on_actor_ok))
    @actor_window.set_handler(:cancel, method(:on_actor_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 获取当前选中的物品
  #--------------------------------------------------------------------------
  def item
    @item_window.item
  end
  #--------------------------------------------------------------------------
  # ● 获取物品的使用者
  #--------------------------------------------------------------------------
  def user
    $game_party.movable_members.max_by {|member| member.pha }
  end
  #--------------------------------------------------------------------------
  # ● 判定光标是否在左列
  #--------------------------------------------------------------------------
  def cursor_left?
    @item_window.index % 2 == 0
  end
  #--------------------------------------------------------------------------
  # ● 显示子窗口
  #--------------------------------------------------------------------------
  def show_sub_window(window)
    width_remain = Graphics.width - window.width
    window.x = cursor_left? ? width_remain : 0
    @viewport.rect.x = @viewport.ox = cursor_left? ? 0 : window.width
    @viewport.rect.width = width_remain
    window.show.activate
  end
  #--------------------------------------------------------------------------
  # ● 隐藏子窗口
  #--------------------------------------------------------------------------
  def hide_sub_window(window)
    @viewport.rect.x = @viewport.ox = 0
    @viewport.rect.width = Graphics.width
    window.hide.deactivate
    activate_item_window
  end
  #--------------------------------------------------------------------------
  # ● 角色“确定”
  #--------------------------------------------------------------------------
  def on_actor_ok
    if item_usable?
      use_item
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ● 角色“取消”
  #--------------------------------------------------------------------------
  def on_actor_cancel
    hide_sub_window(@actor_window)
  end
  #--------------------------------------------------------------------------
  # ● 确定物品
  #--------------------------------------------------------------------------
  def determine_item
    if item.for_friend?
      show_sub_window(@actor_window)
      @actor_window.select_for_item(item)
    else
      use_item
      activate_item_window
    end
  end
  #--------------------------------------------------------------------------
  # ● 启用物品窗口
  #--------------------------------------------------------------------------
  def activate_item_window
    @item_window.refresh
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 获取物品的使用目标数组
  #--------------------------------------------------------------------------
  def item_target_actors
    if !item.for_friend?
      []
    elsif item.for_all?
      $game_party.members
    else
      [$game_party.members[@actor_window.index]]
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定物品是否可以使用
  #--------------------------------------------------------------------------
  def item_usable?
    user.usable?(item) && item_effects_valid?
  end
  #--------------------------------------------------------------------------
  # ● 判定物品的效果是否有效
  #--------------------------------------------------------------------------
  def item_effects_valid?
    item_target_actors.any? do |target|
      target.item_test(user, item)
    end
  end
  #--------------------------------------------------------------------------
  # ● 对角色使用物品
  #--------------------------------------------------------------------------
  def use_item_to_actors
    item_target_actors.each do |target|
      item.repeats.times { target.item_apply(user, item) }
    end
  end
  #--------------------------------------------------------------------------
  # ● 使用物品
  #--------------------------------------------------------------------------
  def use_item
    play_se_for_item
    user.use_item(item)
    use_item_to_actors
    check_common_event
    check_gameover
    @actor_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 公共事件预定判定
  #    如果预约了事件的调用，则切换到地图画面。
  #--------------------------------------------------------------------------
  def check_common_event
    SceneManager.goto(Scene_Map) if $game_temp.common_event_reserved?
  end
end
