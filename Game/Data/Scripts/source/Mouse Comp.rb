# ---------------------------------------------------------------------- #
# 作者：禾西                                                             #
# 最新update: 2012/6/22                                                  #
# ---------------------------------------------------------------------- #
module Mouse
  class Point
    attr_reader :x
    attr_reader :y
    def initalize(x,y)
      set(x,y)
    end
    def set(pos)
      # pos有可能等于nil，所以還是檢查一下。
      return false unless pos.is_a?(Array)
      return false if @x == pos[0] && @y == pos[1]
      @x = pos[0]
      @y = pos[1]
      return true
    end
  end
  # -------------------------------------------------------------------- #
  # 矩形的區域判斷：x, y 為左上角
  # -------------------------------------------------------------------- #
  module UIRect
    def include?(point)
      if point.x >= @x && point.x <= (@x + @w) &&
         point.y >= @y && point.y <= (@y + @h)
        return true
      end
      return false
    end
  end
  # -------------------------------------------------------------------- #
  # 圓形的區域判斷：x, y 為矩形的左上角。圓心為 (x + w, y + h)
  # -------------------------------------------------------------------- #
  module UICircle
    def include?(point)
      if (point.x - @x - @w)**2 + (point.y - @y - @h)**2 < @w*@h/4
        return true
      end
      return false
    end
  end
  # -------------------------------------------------------------------- #
  # Component 的數據記錄（將來可能會和Component直接結合，所以不建議使用）#
  # -------------------------------------------------------------------- #
  module UICore
    module_function
    def init
      @@components = []
    end
    def add(comp)
      #z值反向排序（最高的放最前面），
      #查詢的時候正向查詢，以便快速找到z值最高的。
      for i in 0...@@components.size
        unless comp.z < @@components[i].z #如果這個組件的z值不比它大
          @@components.insert(i,comp) #則取代這個組件的位置（把組件推後）
          return 
        end
      end
      #如果列表搜索已經到頭（z值都比它大）
      @@components.push(comp) #直接插入尾部（最小位置）
    end
    
    def del(comp)
      @@components.delete(comp)
    end
    def check(point)
      @@components.each do |c|
        return c if c.include?(point)
      end
      return nil
    end
    
    # ------------------------------------------------------------------ #
    # Debug                                                              #
    # ------------------------------------------------------------------ #
    def getComponents
      return @@components
    end
  end
  
  # -------------------------------------------------------------------- #
  # 抽象的 Component 基類                                                #
  # -------------------------------------------------------------------- #
  class Component
    include UIRect
    attr_reader :x
    attr_reader :y
    attr_reader :w
    attr_reader :h
    attr_reader :z
    attr_reader :str
    def initialize(x,y,w,h,z,parent = nil)
      @x = x
      @y = y
      @w = w
      @h = h
      @z = z
      UICore.add(self)
      @children = []
      if parent != nil
        test(parent)
        parent.add(self)
      end
      @str = ""
      @bound = false
      @_spr = Sprite.new()
      @_spr.x = x
      @_spr.y = y
      @_spr.z = z
      @_spr.bitmap = Bitmap.new(w,h)
      onInit
    end
    
    # ------------------------------------------------------------------ #
    def add(comp)
      test(comp)
      @children.push(comp) if !@children.include?(comp)
    end
    
    # ------------------------------------------------------------------ #
    def del(comp)
      test(comp)
      @children.delete(comp)
      comp.dispose
    end
    
    # ------------------------------------------------------------------ #
    def dispose
      @children.each do |comp|
        comp.dispose
      end
      UICore.del(self)
      @_spr.dispose
    end
    
    # ------------------------------------------------------------------ #
    def x=(new_x)
      delta = new_x - @x
      @children.each do |comp|
        comp.x += delta
      end
      @x = new_x
      @_spr.x = new_x
    end
    
    # ------------------------------------------------------------------ #
    def y=(new_y)
      delta = new_y - @y
      @children.each do |comp|
        comp.y += delta
      end
      @y = new_y
      @_spr.y = new_y
    end
    
    # ------------------------------------------------------------------ #
    def z=(new_z)
      @z = new_z
      @_spr.z = new_z
      UICore.del(self)
      UICore.add(self)
    end
    
    # ------------------------------------------------------------------ #
    def str=(new_str)
      @str = new_str
      onInit
    end
    
    # ------------------------------------------------------------------ #
    def getContents
      return @_spr.bitmap
    end
    
    # ------------------------------------------------------------------ #
    def setContents(bitmap)
      @_spr.bitmap = bitmap
    end
    
    # ------------------------------------------------------------------ #
    def drawStr(str, x, y,fontSize = nil)
      getContents.font.size = fontSize if fontSize != nil
      rect = getContents.text_size(str)
      rect.x = x
      rect.y = y
      getContents.draw_text(rect,str)
    end
    
    # ------------------------------------------------------------------ #
    def leave
      return if !@bound
      @bound = false
      onLeave
    end
    
    # ------------------------------------------------------------------ #
    def enter
      return if @bound
      @bound = true
      onEnter
    end
    
    
    # ------------------------------------------------------------------ #
    def test(comp)
      if !comp.is_a?(Component)
        raise "#{comp} is not a object deriving from Component!"
      end
    end
    
    # ------------------------------------------------------------------ #
    def send(msg)
      raise "#{self} received msg #{msg}"
    end
    
    # ------------------------------------------------------------------ #
    def onInit
      getContents.fill_rect(0, 0, w, h, Color.new(255,0,0))
      getContents.fill_rect(6, 6, w-12, h-12, Color.new(0,0,0,0))
      rect = getContents.text_size(str)
      rect.x = (w - rect.width)/2
      rect.y = (h - rect.height)/2
      getContents.draw_text(rect,str)
      p "init #{self}"
    end
    # ------------------------------------------------------------------ #
    def onLeave
      msg = str == "" ? self : str
      p "leave #{msg}"
    end
    # ------------------------------------------------------------------ #
    def onEnter
      msg = str == "" ? self : str
      p "enter #{msg}"
    end
    # ------------------------------------------------------------------ #
    def onClick(key)
      msg = str == "" ? self : str
      p "click #{msg}"
    end
  end
  
  # -------------------------------------------------------------------- #
  def self.init
    @@point  = Point.new(0, 0) #初始化坐標標記
    @@thread = Thread.new{}    #初始化搜索thread
    @@current_comp = nil       #初始化所處組件標記
    UICore.init
  end
  
  # -------------------------------------------------------------------- #
  def self.run
    # -------------------------------------------------------- #
    # 如果設置坐標成功 => (pos != []) && (point != pos) 則搜索 #
    # 這段代碼的效率非常的糟糕，但是我想不到更好的辦法         #
    # -------------------------------------------------------- #
    if @@point.set(Mouse.pos)
      @@thread.kill if @@thread.alive?
      @@thread = Thread.new {
        t1 = Time.now
        current_comp = UICore.check(@@point)
        if current_comp != @@current_comp
          @@current_comp.leave unless @@current_comp.nil?
          @@current_comp = current_comp
          @@current_comp.enter unless @@current_comp.nil?
        end
      }
    end
    # -------------------------------------------------------- #
    key = 0
    key^=1 if up?(1)
    key^=2 if up?(2)
    key^=4 if up?(4)
    if !@@current_comp.nil? && key > 0
      @@current_comp.onClick(key)
    end
    # -------------------------------------------------------- #
    # @禾西，下面一行是我刻意搬过来的，因为 CMouse update 之后会清空结果。
    update
  end
end

class Debug
  def self.test(a, b, off = 0)
    if !a.equal?(b)
      raise "fail! Expect #{a}, but got #{b}"
    end
  end
end
Mouse.init
Scene_Base.amend(:update_basic){ Mouse.run }