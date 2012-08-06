class Comp_Command < Mouse::Component
  def initialize(rect,win,index)
    @win = win
    @index = index
    # 12是窗口預留的邊界，貌似是12 #
    super(win.x+rect.x+12,win.y+rect.y+12,rect.width,rect.height,win.z)
  end
  def onInit
  end
  def onEnter
    @win.sendMSG(@index, :e)
  end
  def onLeave
    @win.sendMSG(@index, :l)
  end
  def onClick(key)
    case key
    when 1
      return unless @win.active
      @win.sendMSG(@index, :c)
    when 2
      @win.sendMSG(@index, :d)
    end
  end
end