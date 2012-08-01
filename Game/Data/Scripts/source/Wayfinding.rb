#==================================================================#
# AStar Core v1.01 by 禾西 on 2012.01.02
#------------------------------------------------------------------#
# （此算法基于 4 方向）
# public methods
# * new(Game_Map map)
#     生成關聯地圖的 A* 實例
# * set_origin(int ox, int oy)
#     設置起始點（超過地圖范圍會引起 Runtime Error ）
# * set_target(int tx, int ty)
#     設置終止點（超過地圖范圍會引起 Runtime Error ）
# * Array do_search(bool print_rst = false)
#     進行尋路，返回包含移動信息的數組
#
# private methods
# * int _f(x, y)
#     f 值算法
# * print_data
#     數據打印算法（此方法僅在 do_search(true) 時被使用）
#==================================================================#
#
#調用方法
#    astr = AStar.new($game_map)
#    astr.set_origin($game_player.x, $game_player.y)
#    astr.set_target(0, 0)
#    path = astr.do_search
#
#==================================================================#
class AStar
  Point = Struct.new(:x, :y)
  public
  # ============================================================== #
  # 初始化數據
  # ============================================================== #
  def initialize(map,actor)
    @body = actor
    @map_width  = map.width
    @map_height = map.height
    @g_data = Table.new(@map_width, @map_height)
    @f_data = Table.new(@map_width, @map_height)
    @p_data = Table.new(@map_width, @map_height)
    @ox = 0;@oy = 0
    @tx = 0;@ty = 0
    @openList = []
    @g = 0
    @search_done = false
  end
  # ============================================================== #
  # 設置 起始點 
  # ============================================================== #
  def set_origin(ox, oy)
    @ox = ox;@oy = oy
    if is_Overmap(ox, oy)
      raise RuntimeError, "Origin location is overmap!"
    end
  end
  # ============================================================== #
  # 設置 目標點
  # ============================================================== #
  def set_target(tx, ty)
    @tx = tx;@ty = ty
    if is_Overmap(tx, ty)
      raise RuntimeError, "Target location is overmap!"
    end
  end
  # ============================================================== #
  # 開始尋路
  # ============================================================== #
  # 主邏輯
  def do_search(print_rst = false)
    x = @ox;y = @oy
    @g_data[x, y] = 2;@f_data[x, y] = 1
    @openList << [x, y]
    t0 = Time.now
    t = 0
    begin
      t += 1
      point = @openList.shift
      return [] if point == nil
      check_4dir(point[0], point[1]) # ->檢查 4 方向
    end until @search_done
    if @g_data[@tx,@ty] == 1
      @tx = point[0];@ty = point[1];
    end
    t1 = Time.now
    make_path # ->生成路徑
    #  print "#{t1 - t0}, #{t}\n"
    #  print_data # ->打印數據
    return @path
  end
 
  private
  # ============================================================== #
  # 檢查 4 方向
  def check_4dir(x, y) 
    @g = @g_data[x, y] + 1
    mark_point(x, y - 1, 8) # ->檢查單點
    mark_point(x, y + 1, 2) # ->檢查單點
    mark_point(x - 1, y, 4) # ->檢查單點
    mark_point(x + 1, y, 6) # ->檢查單點
  end
  # ============================================================== #
  # 檢查單點
  def mark_point(x, y, dir)
    if is_Overmap(x, y) # ->檢查地圖是否超界
      return
    end
    if @g_data[x, y] > 1
      return
    end
    if check_passibility(x, y, dir) # ->檢查通行度
      f = _f(x, y)
      @g_data[x, y] = @g
      @f_data[x, y] = f
      point = @openList[0]
      if point.nil?
        @openList.push [x, y] 
      elsif (f <= @f_data[point[0], point[1]])
        @openList.unshift [x, y] 
      else
        @openList.push [x, y] 
      end
    else
      @g_data[x, y] = 1
      @f_data[x, y] = _f(x, y)
    end
    if x == @tx && y == @ty
      @search_done = true
    end
  end
  # ============================================================== #
  # 生成路徑
  def make_path
    x = @tx;y = @ty
    @path = []
    while !(x == @ox && y == @oy)
      @g = @g_data[x, y]
      @best_f = 0
      dir = 0
      dir = make_step(x, y - 1, 2)||dir # ->生成單步
      dir = make_step(x, y + 1, 8)||dir # ->生成單步
      dir = make_step(x - 1, y, 6)||dir # ->生成單步
      dir = make_step(x + 1, y, 4)||dir # ->生成單步
      @path.unshift(dir)
      case dir
      when 2 then y -= 1;
      when 8 then y += 1;
      when 6 then x -= 1;
      when 4 then x += 1;
      end
      @p_data[x, y] = 1
    end
  end
  # ============================================================== #
  # 生成單步
  def make_step(x, y, dir)
    if @g_data[x, y].nil? || @p_data[x, y] == 1
      return nil
    end
    if (@g - @g_data[x, y]) == 1 || @g == 1
      f = @f_data[x, y]
      if f > 0 && (@best_f == 0 || f < @best_f)
        @best_f = f
        return dir
      end
      return nil
    end
    return nil
  end
  # ============================================================== #
  # 檢查地圖通行度
  def check_passibility(x, y, dir)
    case dir
    when 2 then y -= 1;
    when 8 then y += 1;
    when 4 then x += 1;
    when 6 then x -= 1;
    end
    return @body.passable?(x, y, dir)
  end
  # ============================================================== #
  # 檢查地圖是否超界
  def is_Overmap(x, y)
    return (x|y|(@map_width - x - 1)|(@map_height - y - 1)) < 0
  end
  # ============================================================== #
  # f 值算法
  def _f(x, y)
    return ((x - @tx).abs + (y - @ty).abs) + @g
  end
  # ============================================================== #
  # 打印數據
  def print_data
    strf = ""
    strg = ""
    for y in 0...@f_data.ysize
      for x in 0...@f_data.xsize 
        if @f_data[x, y] == 0
          strf += "  "
        else
          strf += sprintf("%02d", @f_data[x, y])
        end
        strf += ","
        if @g_data[x, y] < 2
          strg += "  "
        else
          strg += sprintf("%02d", @g_data[x, y])
        end
        strg += ","
      end
      strf += "\n"
      strg += "\n"
    end
    print strf + "\n"
    print strg + "\n"
    strp = ""
    for y in 0...@p_data.ysize
      for x in 0...@p_data.xsize 
        if @p_data[x, y] == 0
          strp += "  "
        else
          strp += sprintf("%02d", @p_data[x, y])
        end
        strp += ","
      end
      strp += "\n"
    end
 
    print strp
    print @path
  end
end
