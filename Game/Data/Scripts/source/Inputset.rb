﻿$vkey={:Attack=>[0x41],
             :Check=>[0x20,0x43,0x0D],
             :C=>[0x20,0x43,0x0D],
             :X=>[0x58,0x1B],
             :B=>[0x58,0x1B],
             :Run=>[0x10],
             :Z=>[0x10],
             :Test=>[0x11],
             :R=>[0x57],
             :L=>[0x51],
             :Up=>[0x26],
             :Down=>[0x28],
             :Left=>[0x25],
             :Right=>[0x27],
             :Item1=>[0x31],
             :Item2=>[0x32],
             :Item3=>[0x33],
             :Item4=>[0x34],
             :Item6=>[0x35]
             }

class Array
  def included?(arr)
    arr.each do |i|
      if self.include?(i)
        return true
      end
    end
    return false
  end
end