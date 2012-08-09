=begin
#==============================================================================
# ■ [VX] 鼠标系统核心(依赖于dll)
#    [VX] Mouse_System(depend on dll)
#----------------------------------------------------------------------------
# 使用说明:
#
#    利用紫苏提供的winproc,而写的新鼠标系统,跟外站那个完全不相干了
#
#    在使用RM精灵伪造鼠标光标时,利用WM_SETFOCUS和WM_KILLFOCUS消息解决了F1窗口
#    不显示鼠标问题.
#
#    也提供另一种选择:
#    允许使用系统光标(即cur或ani后缀的光标文件),由配置模块TrueMouse参数设定
#    由于光标文件不是rgss支持的格式,在指定文件时,最好包含后缀.
#
#     ** 注意: 开启TrueMouse时会关闭全屏模式,因为全屏下光标不可见
#    ------------------------------------------------------------------------
#    提供的主要方法如下:
#     Mouse.pos
#       提供鼠标坐标,返回值是个数组,格式为[x,y]
#     Mouse.area?(rect)
#       判断鼠标是否在参数rect范围内
#     Mouse.up?(key)
#       鼠标按键是否处在"松开"的瞬间
#       参数key取值(1:左键 2:右键 4:中键),允许不输入参数,表示任意鼠标键,下同
#     Mouse.down?(key)
#       鼠标按键是否处在"按下"的瞬间
#     Mouse.click?(key)
#       鼠标按键单击,脚本简化,仅判断down?
#     Mouse.dbl_clk?(key)
#       鼠标按键双击
#     Mouse.press?(key)
#       鼠标按键是否处在"按下"的状态
#     Mouse.toggle?(key)
#       鼠标按键的触发状态(在开和关之间切换)
#     Mouse.scroll
#       返回鼠标滚轮的滚动值.正值表示向前,负值表示向后,零表示未发生滚动
#     Mouse.move?
#       判断鼠标是否移动
#     Mouse.set_pos(x,y)
#       指定鼠标坐标,鼠标移动到该坐标
#     Mouse.set_cursor(file)
#       改变当前鼠标的光标样式.参数file为光标文件名(路径由配置模块指定)
#       如果参数为nil或者指定光标文件不存在等,不返回错误,但光标不可见
#     Mouse.sys_cursor
#       还原到系统默认光标
#     Mouse.clip(x,y,width,height)
#       把鼠标锁死在指定区域范围内
#       省略参数时,解除鼠标锁定
#==============================================================================
module FSL
  module Mouse_System
    TrueMouse = true               # 使用系统真实鼠标(否则用RM精灵代替)
    CursorFile = "Cursor.cur"       # 光标文件名(最好包含后缀)
    EmptyCursor = "Empty.cur"        #空光标
    AttackCursor = "Attack.cur"        # 攻击光标
    CursorPath = "Graphics/System/" # 光标存放路径
    LKEY = 1
    RKEY = 2
    MKEY = 4
  end
end
class JuhuaLan
	def bili
	
	end
end
#==============================================================================
# ■ Mouse
#==============================================================================
module Mouse
  include FSL::Mouse_System
  module_function
  #--------------------------------------------------------------------------
  # ## 刷新
  #--------------------------------------------------------------------------
  def update
    ## 处理按键
    @up,@down,@dblc,@press,@toggled = 0,0,0,0,0
    @move  = MouseMove.call
    @wheel = MouseWheel.call
    @up      += 1 if MouseUp.call(1) > 0
    @up      += 2 if MouseUp.call(2) > 0
    @up      += 4 if MouseUp.call(4) > 0
    @down    += 1 if MouseDown.call(1) > 0
    @down    += 2 if MouseDown.call(2) > 0
    @down    += 4 if MouseDown.call(4) > 0
    @dblc    += 1 if MouseDblClk.call(1) > 0
    @dblc    += 2 if MouseDblClk.call(2) > 0
    @dblc    += 4 if MouseDblClk.call(4) > 0
    @press   += 1 if MousePress.call(1) > 0
    @press   += 2 if MousePress.call(2) > 0
    @press   += 4 if MousePress.call(4) > 0
    @toggled += 1 if MouseToggled.call(1) > 0
    @toggled += 2 if MouseToggled.call(2) > 0
    @toggled += 4 if MouseToggled.call(4) > 0
    ## 更新光标
    update_cursor
  end
  #--------------------------------------------------------------------------
  # ## 更新光标
  #--------------------------------------------------------------------------
  def update_cursor
    @pos = get_pos
    return if TrueMouse
    if @pos.nil?
      $mousec.visible = false
    else
      $mousec.visible = true
      $mousec.x,$mousec.y = @pos
    end      
  end
  #--------------------------------------------------------------------------
  # ## 获取坐标
  #--------------------------------------------------------------------------
  def get_pos
    return [CMouse.x,CMouse.y]
    begin
      if MouseInClient.call.zero?
        return nil
      else
        pt = [0,0].pack("ll")
        MousePos.call(pt)
	return pt.unpack("ll")
      end
    rescue
      return nil
    end
  end
  #--------------------------------------------------------------------------
  # ## 坐标
  #--------------------------------------------------------------------------
  def pos
    return @pos
  end
  #--------------------------------------------------------------------------
  # ## 在区域内?
  #--------------------------------------------------------------------------
  def area?(x, y, width, height)
    return false if @pos.nil?
    return false unless @pos[0].between?(x, x+width)
    return false unless @pos[1].between?(y, y+height)
    return true
  end
  #--------------------------------------------------------------------------
  # ## 在区域内?
  #--------------------------------------------------------------------------
  def rect?(rect)
    return false if @pos.nil?
    return false unless @pos[0].between?(rect.x, rect.x+rect.width)
    return false unless @pos[1].between?(rect.y, rect.y+rect.height)
    return true
  end
  #--------------------------------------------------------------------------
  # ## 释放?
  #--------------------------------------------------------------------------
  def up?(key = 7)
    return @up & key != 0
  end
  #--------------------------------------------------------------------------
  # ## 按下? 
  #--------------------------------------------------------------------------
  def down?(key = 7)
    return @down & key != 0
  end
  #--------------------------------------------------------------------------
  # ## 单击?
  #--------------------------------------------------------------------------
  def click?(key = 7)
    return down?(key)
  end
  #--------------------------------------------------------------------------
  # ## 双击?
  #--------------------------------------------------------------------------
  def dbl_clk?(key = 7)
    return @dblc & key != 0
  end
  #--------------------------------------------------------------------------
  # ## 按住?
  #--------------------------------------------------------------------------
  def press?(key = 7)
    return @press & key != 0
  end
  #--------------------------------------------------------------------------
  # ## 触发?
  #--------------------------------------------------------------------------
  def toggled?(key = 7)
    return @doggled & key != 0
  end
  #--------------------------------------------------------------------------
  # ## 滚轮
  #--------------------------------------------------------------------------
  def scroll
    return @wheel
  end
  #--------------------------------------------------------------------------
  # ## 移动?
  #--------------------------------------------------------------------------
  def move?
    return @move
  end
  #--------------------------------------------------------------------------
  # ## 设定鼠标位置
  #--------------------------------------------------------------------------
  def set_pos(x, y)
    return MouseSetPos.call(x, y)
  end
  #--------------------------------------------------------------------------
  # ## 设定鼠标光标
  #--------------------------------------------------------------------------
  def set_cursor(file)
    MouseSetCursor.call(check_path(file))
    return
    if TrueMouse
      if check_file(file).is_a? Array
        for f in file
          result = MouseSetCursor.call(check_path(f))
          break unless result.zreo?
        end
      end
    else
      $mousec.bitmap.dispose
      $mousec.bitmap = Bitmap.new(check_path(file))
    end
  end
  #--------------------------------------------------------------------------
  # ## 还原光标为系统默认
  #--------------------------------------------------------------------------
  def sys_cursor
    MouseSysCursor.call if TrueMouse
  end
  #--------------------------------------------------------------------------
  # ## 限制鼠标区域
  #--------------------------------------------------------------------------
  def clip(x = nil, y = nil, width = nil, height = nil)
    if x.nil? || y.nil? || width.nil? || height.nil?
      MouseRelease.call
    else
      MouseClip.call(x, y, width, height)
    end
  end
  #--------------------------------------------------------------------------
  # ## 检查光标名
  #--------------------------------------------------------------------------
  def check_file(file)
    if TrueMouse
      unless file =~ /\.cur$|\.ani$/
        return file+".cur",file+".ani"
      end
    end
    return file
  end
  #--------------------------------------------------------------------------
  # ## 检查路径
  #--------------------------------------------------------------------------
  def check_path(file)
    return CursorPath[/\/$/] ? (CursorPath+file) : (CursorPath+"/"+file)
  end
  #--------------------------------------------------------------------------
  # ## 常量
  #--------------------------------------------------------------------------
  HWND           = Win32API.new("RG3rd","hWnd","v","l")
  MousePos       = Win32API.new("RG3rd","MousePos","p","i")
  MouseInClient  = Win32API.new("RG3rd","MouseInClient","v","i")
  MouseUp        = Win32API.new("RG3rd","MouseUp","i","i")
  MouseDown      = Win32API.new("RG3rd","MouseDown","i","i")
  MouseDblClk    = Win32API.new("RG3rd","MouseDblClk","i","i")
  MousePress     = Win32API.new("RG3rd","MousePress","i","i")
  MouseToggled   = Win32API.new("RG3rd","MouseToggled","i","i")
  MouseWheel     = Win32API.new("RG3rd","MouseWheel","v","i")
  MouseMove      = Win32API.new("RG3rd","MouseMove","v","i")
  MouseSetPos    = Win32API.new("RG3rd","MouseSetPos","ii","i")
  MouseSetCursor = Win32API.new("RG3rd","MouseSetCursor","p","i")
  MouseSysCursor = Win32API.new("RG3rd","MouseSysCursor","v","i")
  MouseClip      = Win32API.new("RG3rd","MouseClip","iiii","i")
  MouseRelease   = Win32API.new("RG3rd","MouseRelease","v","i")
  CallBackStart  = Win32API.new("RG3rd","Start","i","i")
  CallBackStop   = Win32API.new("RG3rd","Stop","v","i")
  #--------------------------------------------------------------------------
  # ## 运行
  #--------------------------------------------------------------------------
  unless const_defined? :MouseStart
    begin
      MouseStart = CallBackStart.call(TrueMouse ? 1 : 0)
      raise("链接库加载失败,代码#{MouseStart}") unless MouseStart.zero?
      if TrueMouse
        MouseSetCursor.call(check_path(CursorFile))
      else
        $mousec = Sprite.new
        $mousec.z = 10001
        $mousec.bitmap = Bitmap.new(check_path(CursorFile))
        update_cursor
      end
    rescue Errno::ENOENT
      print("鼠标系统初始化失败!")
      exit
    end
  end
end
=end