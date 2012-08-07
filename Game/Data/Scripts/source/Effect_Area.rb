class Effect_Area
  
  attr_accessor :four_d
  attr_accessor :arg
  attr_accessor :rect_arr
  attr_accessor :point_arr
  attr_accessor :bitmap
  attr_accessor :offset_x
  attr_accessor :offset_y
  attr_accessor :x
  attr_accessor :y
  attr_reader   :width
  attr_reader   :height

  def initialize(pos,arg=[],four_d=true,color=Fuc::MOV_AREA_C[0],bcolor=Fuc::MOV_AREA_C[1])
    @four_d = four_d
    @arg = arg
    @rect_arr = []
    @point_arr = []
    @bitmap = nil
    @width = 0
    @height = 0
    @x,@y = pos[0],pos[1]
    @dir = four_d
    set_offet(0,0)
    arg.each do |i|
      case i.size
      when 1
        [*0..i[0]].each do |j|
          @rect_arr <<  [-i[0]+j,-j,(i[0]-j)*2+1,j*2+1]
        end
      when 2
        @point_arr << i
        if four_d
          @point_arr << [-i[0],-i[1]]
          @point_arr << [i[1],-i[0]]
          @point_arr << [-i[1],i[0]]
        end
      when 3
        [*(i[0]..i[1])].each do |j|
          j.times do |k|
            point = [k,j-k]
            @point_arr << point
            @point_arr << [-point[0],-point[1]]
            @point_arr << [point[1],-point[0]]
            @point_arr << [-point[1],point[0]]
          end
        end
      when 4
        @rect_arr << i
        if four_d
          @rect_arr << [-i[0]-i[2]+1,-i[1]-i[3]+1,i[2],i[3]]
          @rect_arr << [i[1],-i[0]-i[2]+1,i[3],i[2]]
          @rect_arr << [-i[1]-i[3]+1,i[0],i[3],i[2]]
        end
      end
    end
    cale
    create_bitmap(color,bcolor)
  end
  
  def set_offet(x,y)
    @offset_x = x
    @offset_y = y
  end
  
  def cale
    min_x = 0
    min_y = 0
    max_x = 0
    max_y = 0
    @point_arr.each do |i|
      min_x = i[0] if i[0]<min_x
      max_x = i[0] if i[0]>max_x
      min_y = i[1] if i[1]<min_y
      max_y = i[1] if i[1]>max_y
    end
    @rect_arr.each do |i|
      min_x = i[0] if i[0]<min_x
      max_x = i[0]+i[2] if i[0]+i[2]>max_x
      min_y = i[1] if i[1]<min_y
      max_y = i[1]+i[3] if i[1]+i[3]>max_y
    end
    @offset_x = min_x
    @offset_y = min_y
    @width = max_x-min_x+1
    @height = max_y-min_y+1
  end
  
  def include?(tx,ty)
    tempx=tx-@x
    tempy=ty-@y
    @rect_arr.each do |i|
      if tempx>=i[0]&&tempx<=i[0]+i[2]-1&&tempy>=i[1]&&tempy<=i[1]+i[3]-1
        return true
      end
    end
    @point_arr.each do |i|
      if tempx==i[0]&&tempy==i[1]
        return true
      end
    end
    return false
  end
  
  def create_bitmap(color,bcolor)
    @bitmap.dispose if @bitmap
    return if @width < 1 || @height < 1
    @bitmap = Bitmap.new(@width*32,@height*32)
    @point_arr.each{|i| @bitmap.gradient_fill_rect((i[0]-@offset_x)*32,(i[1]-@offset_y)*32,32,32,color,bcolor,true)}
    @rect_arr.each{|i| @bitmap.gradient_fill_rect((i[0]-@offset_x)*32,(i[1]-@offset_y)*32,i[2]*32,i[3]*32,color,bcolor,true)}
    @width.times{|i| @bitmap.fill_rect(i*32,0,1,@height*32,Fuc::OPA_COLOR)}
    @height.times{|i| @bitmap.fill_rect(0,i*32,@width*32,1,Fuc::OPA_COLOR)}
  end
  
  def dispose
    @bitmap.dispose if @bitmap
  end

  def screen_x
    $game_map.adjust_x(@x+@offset_x)  * 32
  end

  def screen_y
    $game_map.adjust_y(@y+@offset_y) * 32
  end
  
end