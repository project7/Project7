#encoding:utf-8
#==============================================================================
# ■ Scene_Skill
#------------------------------------------------------------------------------
# 　技能画面
#   为了方便共通化处理，这里把技能也称为“物品”。
#==============================================================================

class Scene_Skill < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_command_window
    create_status_window
    create_item_window
  end
  #--------------------------------------------------------------------------
  # ● 生成指令窗口
  #--------------------------------------------------------------------------
  def create_command_window
    wy = @help_window.height
    @command_window = Window_SkillCommand.new(0, wy)
    @command_window.viewport = @viewport
    @command_window.help_window = @help_window
    @command_window.actor = @actor
    @command_window.set_handler(:skill,    method(:command_skill))
    @command_window.set_handler(:cancel,   method(:return_scene))
    @command_window.set_handler(:pagedown, method(:next_actor))
    @command_window.set_handler(:pageup,   method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # ● 生成状态窗口
  #--------------------------------------------------------------------------
  def create_status_window
    y = @help_window.height
    @status_window = Window_SkillStatus.new(@command_window.width, y)
    @status_window.viewport = @viewport
    @status_window.actor = @actor
  end
  #--------------------------------------------------------------------------
  # ● 生成物品窗口
  #--------------------------------------------------------------------------
  def create_item_window
    wx = 0
    wy = @status_window.y + @status_window.height
    ww = Graphics.width
    wh = Graphics.height - wy
    @item_window = Window_SkillList.new(wx, wy, ww, wh)
    @item_window.actor = @actor
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @command_window.skill_window = @item_window
  end
  #--------------------------------------------------------------------------
  # ● 获取技能的使用者
  #--------------------------------------------------------------------------
  def user
    @actor
  end
  #--------------------------------------------------------------------------
  # ● 指令“技能”
  #--------------------------------------------------------------------------
  def command_skill
    @item_window.activate
    @item_window.select_last
  end
  #--------------------------------------------------------------------------
  # ● 物品“确定”
  #--------------------------------------------------------------------------
  def on_item_ok
    @actor.last_skill.object = item
    determine_item
  end
  #--------------------------------------------------------------------------
  # ● 物品“取消”
  #--------------------------------------------------------------------------
  def on_item_cancel
    @item_window.unselect
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 播放物品使用声效
  #--------------------------------------------------------------------------
  def play_se_for_item
    Sound.play_use_skill
  end
  #--------------------------------------------------------------------------
  # ● 使用物品
  #--------------------------------------------------------------------------
  def use_item
    super
    @status_window.refresh
    @item_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 切换角色
  #--------------------------------------------------------------------------
  def on_actor_change
    @command_window.actor = @actor
    @status_window.actor = @actor
    @item_window.actor = @actor
    @command_window.activate
  end
end
