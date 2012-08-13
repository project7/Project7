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
  
end