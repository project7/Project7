class Sprite_RichValue < Sprite
  
  MAX_LIFE = 120
  
  attr_accessor :dead

  def initialize(rate,xy,color=Fuc::HP_VALUE_COLOR,wh=nil,viewport=nil)
    viewport ? super() : super(viewport)
    @rate = rate
    @xy=xy
    @opa_time = 60
    @wh = wh ? wh : [32,5]
    if xy.is_a?(Array)
      self.x = x
      self.y = y
      @freeze_text = true
    else
      self.x = xy.screen_x
      self.y = xy.screen_y
      @freeze_text = false
    end
    @color = color
    @life = 0
    @dead = false
    create_bitmap
  end
  
  def create_bitmap
    self.bitmap = Bitmap.new(*@wh)
    value = (@wh[0]-2)*@rate/100
    self.bitmap.fill_rect(0,0,*@wh,Fuc::BUFF_DES_BACK)
    self.bitmap.fill_rect(1,1,value,@wh[1]-2,@color)
    self.x=@xy.screen_x-self.bitmap.width/2
    self.y=@xy.screen_y-self.bitmap.height-@xy.gra_height-2
  end
  
  def update
    if !@dead
      unless @freeze_text
        self.x = @xy.screen_x-self.bitmap.width/2
        self.y = @xy.screen_y-self.bitmap.height-@xy.gra_height-2
        if @opa_time>0
          @opa_time-=1
        else
          self.opacity-=5
        end
        @dead = @life>MAX_LIFE && self.opacity<=30
        @life+=1
      end
    elsif !self.bitmap.disposed?
      self.bitmap.dispose
    end
  end
  
  def refresh(rate,xy,color=Fuc::HP_VALUE_COLOR,wh=nil)
    self.bitmap.dispose if self.bitmap && !self.bitmap.disposed?
    @rate = rate
    @opa_time = 60
    self.opacity = 255
    @xy=xy
    @wh = wh ? wh : [32,5]
    if xy.is_a?(Array)
      self.x = x
      self.y = y
      @freeze_text = true
    else
      self.x = xy.screen_x
      self.y = xy.screen_y
      @freeze_text = false
    end
    @color = color
    @life = 0
    @dead = false
    create_bitmap
  end
  
end