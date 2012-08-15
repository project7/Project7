class Array
  
  def included?(arr)
    arr.each do |i|
      if self.include?(i)
        return true
      end
    end
    return false
  end
  
  def inrect?(tar)
    if self[0]>=tar[0]&&self[0]<=tar[0]+tar[2]&&self[1]>=tar[1]&&self[1]<=tar[1]+tar[3]
      return true
    end
    return false
  end
  
  def einrect?(tar,index)
    return false if index<0
    offset = index*160
    if self[0]>=tar[0]+offset&&self[0]<=tar[0]+tar[2]+offset&&self[1]>=tar[1]&&self[1]<=tar[1]+tar[3]
      return true
    end
    return false
  end
  
end

class Sprite
  
  alias bmp bitmap
  def bitmap
    if bmp
      if bmp.disposed?
        return nil
      else
        return bmp
      end
    else
      return nil
    end
  end
  
end