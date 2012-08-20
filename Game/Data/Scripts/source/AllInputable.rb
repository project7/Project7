module CInput
  @R_Key_Hash = {}
  @R_Key_Repeat = {}
  @press_keys = []
  @down_keys = []
  class << CInput
    
    alias ud update
    def update
      @down_keys,@press_keys = getall[1],getall[2]
      ud
    end

    alias dn down?
    def down?(rkey)
      return rkey.any?{|i| @down_keys.include?(i)} rescue false
    end

    alias pre press?
    def press?(rkey)
      return rkey.any?{|i| @press_keys.include?(i)} rescue false
    end
   
    def repeat?(rkey)
      return rkey.any?{|i| rrepeat?(i)} rescue false
    end

    def trigger?(rkey)
      return rkey.any?{|i| rtrigger?(i)} rescue false
    end

    def rrepeat?(rkey)
      result = @press_keys.include?(rkey)
      if result
        if @R_Key_Repeat[rkey].nil?
          @R_Key_Repeat[rkey] = [0,0,0]
          return true
        end
        @R_Key_Repeat[rkey][0] += 1
      else
        @R_Key_Repeat[rkey] = nil
        @R_Key_Hash[rkey] = 0
      end
      if @R_Key_Repeat[rkey]
        if @R_Key_Repeat[rkey][1] == 1
          if @R_Key_Repeat[rkey][0] >= 6
            @R_Key_Repeat[rkey][0] = 0
            return true
          end
        elsif @R_Key_Repeat[rkey][0] >= 20
          @R_Key_Repeat[rkey][0] = 0
          @R_Key_Repeat[rkey][1] = 1
          return true
        end
        return false
      else
        return false
      end
    end


    def rtrigger?(rkey)
      result = @press_keys.include?(rkey)
      if @R_Key_Hash[rkey] == 1 and result
        return false
      end
      if result
        @R_Key_Hash[rkey] = 1
        return true
      else
        @R_Key_Hash[rkey] = 0
        return false
      end
    end
   
    def dir4
      return 8 if @press_keys.included?($vkey[:Up])
      return 6 if @press_keys.included?($vkey[:Right])
      return 4 if @press_keys.included?($vkey[:Left])
      return 2 if @press_keys.included?($vkey[:Down])
      return 0
    end
    
    def item4
      return 0 if trigger?($vkey[:Item1])
      return 1 if trigger?($vkey[:Item2])
      return 2 if trigger?($vkey[:Item3])
      return 3 if trigger?($vkey[:Item4])
      return false
    end
 
  end
end