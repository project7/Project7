module Fuc

  DIR_LIST =      [[0,8,2],[4],[6]]# 方向表，方便写
  SP_OPA =        [255,100,150,200,100] # 透明度表
  MOV_AREA_C =    [Color.new(0,100,255,255),Color.new(0,150,255,255)]
  WAY_AREA_C =    [Color.new(0,180,100,255),Color.new(100,200,50,255)]
  EFFECT_AREA_C = [Color.new(255,255,50,255),Color.new(200,200,0,200)]
  ENABLE_AREA_C = [Color.new(200,20,20,255),Color.new(255,50,0,255)]
  OPA_COLOR =     Color.new(0,0,0,0)
  WHITE_COLOR =   Color.new(255,255,255,255)
  HP_COST_COLOR = Color.new(255,0,0,255)
  HP_ADD_COLOR =  Color.new(0,255,0,255)
  BINGO_COLOR =   Color.new(255,255,0,255)
  SP_COST_COLOR = Color.new(255,255,255,255)
  SP_ADD_COLOR =  Color.new(255,255,255,255)
  TIPS_POINT = Bitmap.new("Graphics/System/cur_actor.png")
  FAILD_ATTACK_TEXT = 
  [ "伤害被闪避",
    "伤害被无效化",
    "目标对物理伤害免疫",
    "目标是魔免的",
    "目标是无敌的",
    "攻击范围内没有任何目标",
    "不能攻击友方单位",
    "目标点超出攻击范围",
    "你不能攻击尸体",
  ]

  # 寻路
  def self.sm(x,y)
    unless ($game_player.auto_move_path!=[] && x==@@last_x && y==@@last_y)
      astr = AStar.new($game_map,$game_player)
      astr.set_origin($game_player.x, $game_player.y)
      astr.set_target(x, y)
      $game_player.auto_move_path = astr.do_search
      @@last_x = x
      @@last_y = y
    end
  end
  
  # 战斗寻路
  def self.xxoo(x,y,dis,actor)
    astr = AStar.new($game_map,actor)
    astr.set_origin(actor.x, actor.y)
    astr.set_target(x, y)
    actor.auto_move_path = (astr.do_search)[0,dis]
    return actor.auto_move_path
  end
  
  # 通过屏幕坐标获取游戏坐标
  def self.getpos_by_screenpos(pos)
    game_pos = [0,0]
    game_pos[0] = (pos[0]+$game_map.display_x*32).to_i/32
    game_pos[1] = (pos[1]+$game_map.display_y*32).to_i/32
    return game_pos
  end
  
  # 通过游戏坐标获取屏幕坐标
  def self.getpos_by_gamepos(pos)
    screen_pos = [0,0]
    screen_pos[0] = pos[0]*32-$game_map.display_x*32+16
    screen_pos[1] = pos[1]*32-$game_map.display_y*32+16
    return screen_pos
  end
  
  # 旋转区域数组
  def self.turn(para,dir)
    return para if dir == 0
    para.each_index do |i|
      case para[i].size
      when 2
        case dir
        when 8
          para[i] = [-para[i][0],-para[i][1]]
        when 6
          para[i] = [para[i][1],-para[i][0]]
        when 4
          para[i] = [-para[i][1],para[i][0]]
        end
      when 4
        case dir
        when 8
          para[i] = [-para[i][0]-para[i][2]+1,-para[i][1]-para[i][3]+1,para[i][2],para[i][3]]
        when 6
          para[i] = [para[i][1],-para[i][0]-para[i][2]+1,para[i][3],para[i][2]]
        when 4
          para[i] = [-para[i][1]-para[i][3]+1,para[i][0],para[i][3],para[i][2]]
        end
      end
    end
    return para
  end
  
  # 鼠标在角色的方向
  def self.mouse_dir_body(actor,target)
    tempos = target.is_a?(Array) ? target : [target.x,target.y]
    sx = actor.x-tempos[0]
    sy = actor.y-tempos[1]
    if sx.abs > sy.abs
      return sx > 0 ? 4 : 6
    elsif sy != 0
      return sy > 0 ? 8 : 2
    end
    return 0
  end
  
  # 鼠标指向地板的选框
  def self.mouse_icon
    a = Bitmap.new(32,32)
    a.gradient_fill_rect(0, 0, 32, 32, Color.new(255,0,0,200), Color.new(180,120,0,200),true)
    a.gradient_fill_rect(1, 1, 30, 30, Color.new(180,120,0,150),Color.new(255,0,0,150),true)
    return a
  end
  
  # 物品栏背景图
  def self.ui_item
    return Bitmap.new("Graphics/System/UI_Item_Frame.png")
  end
  
  # 物品选框图
  def self.ui_item_rect
    a = Bitmap.new(36,36)
    a.gradient_fill_rect(0, 0, 36, 36, Color.new(255,255,0,255),Color.new(255,180,0,255))
    a.gradient_fill_rect(1, 1, 34, 34, Color.new(200,200,200,160), Color.new(120,120,120,150),true)
    return a
  end
  
  # 头像区资料
  def self.ui_detail
    return Bitmap.new("Graphics/System/UI_Detail_Frame.png")
  end
  
  # 头像
  def self.ui_head
    if $sel_body
      begin
        a = Bitmap.new("Graphics/Heads/"+$sel_body.name+".png")
        return a
      rescue
        return nil
      end
    end
    return nil
  end
  
  # 当前角色资料
  def self.ui_head_detail
    if $sel_body
      a = Bitmap.new(193,105)
      a.font.color = Color.new(255,255,255,255)
      a.font.name = "方正隶变简体"
      a.draw_text(104,25,60,30,$sel_body.ap.to_s,1)
      a.draw_text(96,70,100,30,$sel_body.name,1)
      return a
    end
    return nil
  end
  
  

end