#==============================================================================
# 模板场（继承于Field_Base）
#------------------------------------------------------------------------------
# by FantasyDR
#==============================================================================
# 用于粒子工厂(PTCF)建立模板粒子
#==============================================================================

#==============================================================================
# 模板场-星空（粒子出现地点x,y坐标均随机的场）
#==============================================================================
class Field_Star < Field_Base
  def get_start_x(id)
    return @particle.left + rand(@particle.range.width)
  end
  
  def get_start_y(id)
    return @particle.top + rand(@particle.range.height)
  end
end
#==============================================================================
# 模板场-雪花（粒子出现地点x坐标随机的场）
#==============================================================================
class Field_Snow < Field_Base
  def get_start_x(id)
    return @particle.left + rand(@particle.range.width)
  end
end
#==============================================================================
# 模板场-火焰（粒子出现地点x,y坐标小范围抖动的场）
#==============================================================================
class Field_Fire < Field_Base
  def get_start_x(id)
    return @particle.t_start_x + rand(10)*(1-rand(2)*2)
  end
  def get_start_y(id)
    return @particle.t_start_y + rand(10)*(1-rand(2)*2)
  end
end
#==============================================================================
# 模板场-炸弹（粒子初速度随机的场）
#==============================================================================
class Field_Bomb < Field_Base
  def get_speed(id)
    rand(@particle.speed)
  end
end
#==============================================================================
# 模板场-引力（粒子受到一个定点引力的场）
#==============================================================================
class Field_Gravity < Field_Base
  attr_accessor:plant_x #行星位置x
  attr_accessor:plant_y #行星位置y
  attr_accessor:gravity #引力常量
  
  def initialize(particle,plant_x,plant_y,gravity)
    super(particle)
    @particle= particle
    @plant_x = plant_x
    @plant_y = plant_y
    @gravity = gravity
  end
  
  def gx(id)
    @rx = @plant_x - @particle.px[id]
    @ry = @plant_y - @particle.py[id]
    @pos = Math.sqrt(@rx*@rx+@ry*@ry)
    @particle.gx = @gravity * @rx / @pos
    @particle.gy = @gravity * @ry / @pos
  end
end
#==============================================================================
# 模板场-漂移（针对TYPE_SAMETIME情况，粒子出现点随机的场）
#==============================================================================
class Field_Drift < Field_Base
  #起始点随机
  def get_start_x(id)
    if id==0
      return @particle.left + rand(@particle.range.width)
    else
      return @particle.start_x
    end
  end
  
  def get_start_y(id)
    if id==0
      return @particle.top + rand(@particle.range.height)
    else
      return @particle.start_y
    end
  end
end
#==============================================================================
# 模板场-反弹（粒子到边缘会反弹的场）
#==============================================================================
class Field_Rebound < Field_Base
  attr_accessor:damp #衰减系数，默认为1，
  def initialize(particle)
    super
    @damp=1.0
  end
  #x方向反弹
  def gx(id)
    rx=@particle.center_x*@particle.particle[id].zoom_x
    if (@particle.px[id]-rx<=@particle.left && @particle.sx[id]<0)||\
       (@particle.px[id]+rx>=@particle.right && @particle.sx[id]>0)
     @particle.sx[id] = -@particle.sx[id]*@damp
    end
  end
  #y方向反弹
  def gy(id)
    ry=@particle.center_y*@particle.particle[id].zoom_y
    if (@particle.py[id]-ry<=@particle.top && @particle.sy[id]<0)||\
       (@particle.py[id]+ry>=@particle.buttom && @particle.sy[id]>0)
      @particle.sy[id] = -@particle.sy[id]*@damp
    end
  end
end
#==============================================================================
# 模板场-碰撞（两个粒子之间会发生碰撞的场）
#==============================================================================
class Field_Kick < Field_Base
  attr_accessor:damp #衰减系数，默认为1，
  def initialize(particle)
    super
    @damp=1.0
  end
  def gy(id)
    max=@particle.count-1
    isKnock=false
    for i in id+1..max
      if i!=id
        rx=@particle.px[i]-@particle.px[id]
        ry=@particle.py[i]-@particle.py[id]
        if ry.abs<@particle.center_y*@particle.particle[i].zoom_y &&\
           rx.abs<@particle.center_x*@particle.particle[i].zoom_x
           
           if  (@particle.sx[i]-@particle.sx[id]) * rx <0
             temp=@particle.sx[id]
             @particle.sx[id] = @particle.sx[i]*@damp
             @particle.sx[i] = temp*@damp
             isKnock=true
             break
           end
           
           if  (@particle.sy[i]-@particle.sy[id]) * ry <0
             temp=@particle.sy[id]
             @particle.sy[id] = @particle.sy[i]*@damp
             @particle.sy[i] = temp*@damp
             isKnock=true
             break
           end
           
        end
      end
    end
    if isKnock
      #碰撞发生，可以加一些声效处理
    end
  end
end 
#==============================================================================
# 组合场-行星（在Gravity场上叠加Star场，产生四周粒子被一点吸引的效果）
#==============================================================================
class Field_Plant < Field_Gravity
  def initialize(particle,plant_x,plant_y,gravity)
    super
    @f_star=Field_Star.new(particle)
  end
  
  def get_start_x(id)
    return @f_star.get_start_x(id)
  end
  
  def get_start_y(id)
    return @f_star.get_start_y(id)
  end
  
end
#==============================================================================
# 组合场-反弹和碰撞（在Rebound场上叠加Kick的场）
#==============================================================================
class Field_Rebound_Kick < Field_Rebound
  def initialize(particle)
    super
    @f_kick=Field_Kick.new(particle)
  end
  
  def gy(id)
    super
    @f_kick.gy(id)
  end
end