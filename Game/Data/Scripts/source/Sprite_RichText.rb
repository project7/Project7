class Sprite_RichText < Sprite
  
  MAX_LIFE = 60
  
  attr_accessor :dead

  def initialize(text,xy,color=Fuc::WHITE_COLOR,size=20,viewport=nil)
    viewport ? super() : super(viewport)
    @text = text
    @xy=xy
    if xy.is_a?(Array)
      @base_x = x
      @base_y = x
      @offset_x = 0
      @offset_y = 0
      self.x = x
      self.y = y
      @freeze_text = true
    else
      @base_x = xy.screen_x
      @base_y = xy.screen_y
      @offset_x = 0
      @offset_y = 0
      self.x = @base_x
      self.y = @base_y
      @freeze_text = false
    end
    @color = color
    @size = size
    @vx = -3+rand(6)
    @vy = -10+rand(6)
    @offset_floor = 20+rand(60)
    @floor = self.y+@offset_floor
    @life = 0
    @dead = false
    create_bitmap
  end
  
  def create_bitmap
    tbitmap = Bitmap.new(10,10)
    tbitmap.font.color = @color
    tbitmap.font.size = @size
    rect = tbitmap.text_size(@text)
    rect.width += 10
    rect.height += 10
    tbitmap.dispose
    self.bitmap = Bitmap.new(rect.width,rect.height)
    self.bitmap.font.color = @color
    self.bitmap.font.size = @size
    self.bitmap.draw_text(0,0,rect.width,rect.height,@text,1)
    if @freeze_text
      self.x-=rect.width/2
      self.y-=rect.height/2
    else
      @offset_x-=rect.width/2
      @offset_y-=rect.height/2
      self.x = @base_x+@offset_x
      self.y = @base_y+@offset_y
    end
  end
  
  def update
    if !@dead
      if @freeze_text
        self.x += @vx
        @vy+=1
        if self.y+@vy > @floor
          self.y = @floor
          @vy = [-@vy+3,-4].min
          @dead = @vy == -4 && @life>MAX_LIFE
        else
          self.y+=@vy
        end
        @life+=1
      else
        @base_x = @xy.screen_x
        @base_y = @xy.screen_y
        @offset_x += @vx
        @vy+=1
        if @offset_y+@vy >= @offset_floor
          @offset_y = @offset_floor
          @vy = [-@vy+3,-4].min
          @dead = @vy == -4 && @life>MAX_LIFE
        else
          @offset_y+=@vy
        end
        self.x = @base_x+@offset_x
        self.y = @base_y+@offset_y
        @life+=1
      end
    elsif !self.bitmap.disposed?
      self.bitmap.dispose
    end
  end
  
end