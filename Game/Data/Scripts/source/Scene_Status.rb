#encoding:utf-8
#==============================================================================
# ■ Scene_Status
#------------------------------------------------------------------------------
# 　状态画面
#==============================================================================

class Scene_Status < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def start
    super
    @status_window = Window_Status.new(@actor)
    @status_window.set_handler(:cancel,   method(:return_scene))
    @status_window.set_handler(:pagedown, method(:next_actor))
    @status_window.set_handler(:pageup,   method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # ● 切换角色
  #--------------------------------------------------------------------------
  def on_actor_change
    @status_window.actor = @actor
    @status_window.activate
  end
end
