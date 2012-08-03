class Window_Base < Window

  def mouse_in_rect?(index)
    s = item_rect(index)
    tpos=[s.x+16+self.x,s.x+16+s.width+self.x,s.y+16+self.y,s.y+16+s.height+self.y]
    mxy = Mouse.pos
    if mxy[0]>=tpos[0]&&mxy[0]<=tpos[1]&&mxy[1]>=tpos[2]&&mxy[1]<=tpos[3]
      return true
    else
      return false
    end
  end

  def Mouseclick?
    if Mouse.down?(1) && mouse_in_rect?(@index)
      return true
    end
    return false
  end
  
  def Mousescoll?
    if Mouse.scroll!=0 && mouse_in_rect?(@index)
      return Mouse.scroll
    end
    return false
  end
  
end

class Window_Selectable < Window_Base

  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (CInput.trigger?($vkey[:Down]))  if CInput.repeat?($vkey[:Down])
    cursor_up   (CInput.trigger?($vkey[:Up]))    if CInput.repeat?($vkey[:Up])
    cursor_right(CInput.trigger?($vkey[:Right])) if CInput.repeat?($vkey[:Right])
    cursor_left (CInput.trigger?($vkey[:Left]))  if CInput.repeat?($vkey[:Left])
    cursor_pagedown   if !handle?(:pagedown) && CInput.trigger?($vkey[:R])
    cursor_pageup     if !handle?(:pageup)   && CInput.trigger?($vkey[:L])
    item_max.times do |i|
      if mouse_in_rect?(i)
        select(i)
      end
    end
    Sound.play_cursor if @index != last_index
  end

  def process_handling
    return unless open? && active
    return process_ok       if ok_enabled?        && CInput.trigger?($vkey[:Check]) || Mouseclick?
    return process_cancel   if cancel_enabled?    && (CInput.trigger?($vkey[:X]) || Mouse.down?(2))
    return process_pagedown if handle?(:pagedown) && CInput.trigger?($vkey[:R])
    return process_pageup   if handle?(:pageup)   && CInput.trigger?($vkey[:L])
  end

end

class Window_NumberInput < Window_Base

  def process_cursor_move
    return unless active
    last_index = @index
    cursor_right(CInput.trigger?($vkey[:Right])) if CInput.repeat?($vkey[:Right])
    cursor_left (CInput.trigger?($vkey[:Left]))  if CInput.repeat?($vkey[:Left])
    @digits_max.times do |i|
      if mouse_in_rect?(i)
        @index = i % @digits_max
      end
    end
    Sound.play_cursor if @index != last_index
  end
  
  def process_digit_change
    return unless active
    if CInput.repeat?($vkey[:Up]) || CInput.repeat?($vkey[:Down]) || Mousescoll?
      Sound.play_cursor
      place = 10 ** (@digits_max - 1 - @index)
      n = @number / place % 10
      @number -= n * place
      n = (n + 1) % 10 if CInput.repeat?($vkey[:Up]) || Mousescoll?>0
      n = (n + 9) % 10 if CInput.repeat?($vkey[:Down]) || Mousescoll?<0
      @number += n * place
      refresh
    end
  end
  
  def process_handling
    return unless active
    return process_ok     if CInput.trigger?($vkey[:Check]) || Mouse.down?(1)
    return process_cancel if CInput.trigger?($vkey[:X]) || Mouse.down?(2)
  end

end