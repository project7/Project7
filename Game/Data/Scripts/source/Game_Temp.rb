#encoding:utf-8
#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 　在没有存档的情况下，处理临时数据的类。本类的实例请参考 $game_temp 。
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :common_event_id          # 公共事件ID
  attr_accessor :fade_type                # 场所移动时的淡出类型
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    @common_event_id = 0
    @fade_type = 0
  end
  #--------------------------------------------------------------------------
  # ● 预定调用的公共事件
  #--------------------------------------------------------------------------
  def reserve_common_event(common_event_id)
    @common_event_id = common_event_id
  end
  #--------------------------------------------------------------------------
  # ● 清除预定调用的公共事件
  #--------------------------------------------------------------------------
  def clear_common_event
    @common_event_id = 0
  end
  #--------------------------------------------------------------------------
  # ● 判定是否存在预定调用的公共事件
  #--------------------------------------------------------------------------
  def common_event_reserved?
    @common_event_id > 0
  end
  #--------------------------------------------------------------------------
  # ● 获取当前预定的公共事件
  #--------------------------------------------------------------------------
  def reserved_common_event
    $data_common_events[@common_event_id]
  end
  
  DEFAULT_FIGURE_MAP = {
    "亚历山大" => "Alexander",
    "琳" => "Lynn",
    "学者" => "Ch15"
  }
  
  DEFAULT_FIGUREPOS_MAP = {
      "亚历山大" => 1,
      "琳" => 1,
      "学者" => 1,
  }
  
  def figure_map name
    (@figure_map ? @figure_map[name] : nil) ||
    DEFAULT_FIGURE_MAP[name]
  end

  def figurepos_map name
    (@figurepos_map ? @figurepos_map[name] : nil) ||
    DEFAULT_FIGUREPOS_MAP[name]
  end
  
  def set_figure name, f
    @figure_map ||={}
    @figure_map[name] = f
  end
  
  def set_figurepos name, pos
    @figurepos_map ||={}
    @figurepos_map[name] = pos
  end
  
  def clean_figure
    @figure_map = nil
  end
  
  def clean_figurepos
    @figurepos_map = nil
  end
end
