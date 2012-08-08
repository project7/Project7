class Party
  
  attr_accessor :members
  
  def initalize
    @members = []
  end
  
  def join(actor)
    @members << actor
  end
  
  def kick(actor)
    @members.delete(actor)
  end

end