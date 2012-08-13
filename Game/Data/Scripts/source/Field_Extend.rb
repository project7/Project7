#==============================================================================
# 自定义场示例
#------------------------------------------------------------------------------
# by FantasyDR
#==============================================================================
# 1、建立一个类，继承原有的Field_Base或者其他场。
# 2、根据需要重载某个方法，比如get_start_x(id)控制起始点x坐标。
# 3、重载的方法必须是Field_Base原有的。
# 4、请参考Field_Template脚本块中的“模板场”和“组合场”的写法。
# 5、下面的类是一个示例
#==============================================================================
class Field_Example < Field_Base
  #起始点循环往复
  def get_start_x(id)
    start_x = @particle.start_x - (rand(3)+1)
    if start_x<=@particle.left
      start_x=@particle.right
    end
    return start_x
  end
  
  def get_start_y(id)
    start_y = @particle.start_y - (rand(5)+1)
    if start_y<=@particle.top
      start_y=@particle.buttom
    end
    return start_y
  end
  
  #y向加一个阻力
  def sy(id)
    super
    if @particle.sy[id]>0
      @particle.sy[id] -= 0.1
    else
      @particle.sy[id] += 0.1
    end
  end
  
  #x向加一个阻力
  def sx(id)
    super
    if @particle.sx[id]>0
      @particle.sx[id] -= 0.05
    else
      @particle.sx[id] += 0.05
    end
  end
end