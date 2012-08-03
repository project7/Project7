class Buff

  attr_accessor :user                             # buff的产生者
  attr_accessor :icon                             # buff图标
  attr_accessor :animation                        # 被加持buff者动画
  attr_accessor :keep_turn                        # buff可持续的回合
  attr_accessor :keep_step                        # buff可持续的操作数
  attr_accessor :use_effect                       # 加持buff瞬间的效果
  attr_accessor :per_turn_start_effect            # 每回合开始的效果
  attr_accessor :per_step_effect                  # 每次操作的效果
  attr_accessor :per_turn_end_effect              # 每回合结束的效果
  attr_accessor :end_req                          # 结束条件
  attr_accessor :lived_turn                       # buff已经存在的回合数
  attr_accessor :lived_step                       # buff已经存在的操作数

  def initialize(user=nil)
    set_ele(user)
    set_extra
    init_var
  end
  
  def set_ele(user)
    @user = user
    @icon = nil
    @animation = []
    @keep_turn = 0
    @keep_step = 0
    @use_effect = ""
    @per_turn_start_effect = ""
    @per_step_effect = ""
    @per_turn_end_effect = ""
  end
  
  def set_extra
    @end_req = "buff.live_turn>=buff.keep_turn"
  end
  
  def init_var
    @lived_turn = 0
    @lived_step = 0
  end

end