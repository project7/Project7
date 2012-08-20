module Fuc

  DIR_LIST =          [[0,8,2],[4],[6]]# 方向表，方便写
  SP_OPA =            [255,100,150,200,100] # 透明度表
  UI_SKILL_POS =      [ [51,5],[92,27],[92,74],[51,97],[10,74],[10,27] ]
  MENU_ELE_POS =      [ [21,238,94,22],[21,268,94,22],[21,298,94,22],[21,328,94,22] ]
  MENU_GRA_POS =      [ [157,51],[157,89],[157,127],[157,165] ]
  MENU_VOI_POS =      [ [134,35],[134,67],[134,99] ]
  MENU_SAV_POS =      [ [21,40,166,34],[21,40,83,34],[105,40,82,34],[21,113,83,34],[105,113,82,34] ]
  MENU_MES_POS =      [142,326,120,33]
  MENU_MES_TEXT_POS=  [17,52,370,262]
  MOV_AREA_C =        [Color.new(0,100,255,255),Color.new(0,150,255,255)]
  WAY_AREA_C =        [Color.new(0,180,100,255),Color.new(100,200,50,255)]
  EFFECT_AREA_C =     [Color.new(255,255,50,255),Color.new(200,200,0,200)]
  ENABLE_AREA_C =     [Color.new(200,20,20,255),Color.new(255,50,0,255)]
  OPA_COLOR =         Color.new(0,0,0,0)
  WHITE_COLOR =       Color.new(255,255,255,255)
  HP_COST_COLOR =     Color.new(255,0,0,255)
  HP_ADD_COLOR =      Color.new(0,255,0,255)
  BINGO_COLOR =       Color.new(255,255,0,255)
  SP_COST_COLOR =     Color.new(100,100,100,255)
  SP_ADD_COLOR =      Color.new(255,255,255,255)
  AP_COST_COLOR =     Color.new(100,255,100,255)
  AP_ADD_COLOR =      Color.new(255,100,255,255)
  DAMGE_GREEN =       Color.new(102,0,255,255)
  BUFF_DES_BACK =     Color.new(0,0,0,180)
  TIPS_TEXT_COLOR =   Color.new(0,0,0,255)
  DESCR_TITLE_COLOR = Color.new(255,255,0,255)
  HP_VALUE_COLOR =    Color.new(255,0,0,255)
  TIPS_POINT = "Graphics/System/cur_actor.png"
  TIPS_TEXT = "Graphics/System/Tips_Text.png"
  BUFF_BACK = "Graphics/System/Buff_Back.png"
  SKILL_BACK = "Graphics/System/Skill_Back.png"
  ELE_BACK = "Graphics/System/ele_back.png"
  ELE_SHOW = "Graphics/System/ele_show.png"
  ELE_SEL = "Graphics/System/ele_sel.png"
  MENU_GRA = "Graphics/System/graphic_scene.png"
  MENU_VOI = "Graphics/System/voice_scene.png"
  MENU_SAV = "Graphics/System/save_scene.png"
  MENU_MES = "Graphics/System/mesg_scene.png"
  MENU_SEL = "Graphics/System/seled.png"
  MENU_SAV_SEL = ["Graphics/System/save_sel1.png","Graphics/System/save_sel2.png","Graphics/System/save_sel3.png"]
  MENU_SAV_LOG = "Graphics/System/login.png"
  MENU_SAV_SL = "Graphics/System/sl.png"
  MENU_MES_SEL = "Graphics/System/mesg_sel.png"
  EMPTY_SKILL = "Graphics/Icon/empty_skill.png"
  O_TURN = "Graphics/System/onalo_turn.png"
  E_TURN = "Graphics/System/enemy_turn.png"
  RECT_SEL = Rect.new(0,0,26,26)
  DAMAGE_EFFECT = [Color.new(255,0,0,255),20]
  FAILD_ATTACK_TEXT = 
  [ "Miss",
    "Trick",
    "目标对物理伤害免疫",
    "目标是魔免的",
    "目标是无敌的",
    "作用范围内无目标",
    "不能攻击友方单位",
    "目标点超出允许范围",
    "你不能攻击尸体",
    "不能作用于敌人",
    "不能作用于友方",
    "不能作用于敌方尸体",
    "不能作用于友方尸体",
    "无法作用于目标点",
    "未满足使用条件",
    "无法使用的技能",
    "无法使用的道具",
    "怒气值不足",
    "生命值不足",
    "行动力不足",
    "物品数量不足",
    "该单位太强大"
  ]
  ELE_DESCR = 
  [ ["力量","每点效果:\n攻击+10\n防御+5\n暴击伤害倍数+20%\n生命最大上限+15"],
    ["体力","每点增加:\n生命最大上限+60\n防御+1\n行动力+2\n每两点增加1行动血量回复"],
    ["智力","每点增加:\n法力+10\n法抗+5\n基础仇恨-1\n行动力+1\n每三点增加1行动怒气回复"],
    ["敏捷","每点增加:\n攻击+2\n防御+5\n闪避+2%\n暴击+2%\n行动力+1"]
  ]
  COMMON_BATTLE_REQ = " $game_switches[2] = @partner_num==0;
                        $game_switches[3] = @enemy_num==0;
                        $game_switches[2] || $game_switches[3]"
  LVLUP_END_REQ     = " $game_switches[2] = @partner_num==0;
                        $game_switches[3] = @enemy_num==0;
                        $game_switches[4] = $team_set[2].dead?;
                        $game_switches[2] || $game_switches[3] || $game_switches[4]"

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
    rpath = astr.do_search
    if dis < 1
      path = rpath
      actor.auto_move_path = path
    else
      path = rpath[0,dis]
      actor.auto_move_path = rpath if dis>=rpath.size
    end
    return path
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
    screen_pos[0] = (pos[0]*32-$game_map.display_x*32+16).to_i
    screen_pos[1] = (pos[1]*32-$game_map.display_y*32+16).to_i
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
        a = Bitmap.new("Graphics/Heads/"+$sel_body.head+".png")
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
      tfont = a.font.name
      tsize = a.font.size
      a.font.name = "钟齐孟宪敏硬笔简体"
      a.font.size = 50
      a.draw_text(82,8,100,60,$sel_body.ap.to_s,1)
      a.font.name = tfont
      a.font.size = tsize
      a.draw_text(96,70,100,30,$sel_body.name,1)
      return a
    end
    return nil
  end
  
  # 获取当前角色
  def self.cur_actor
    if $map_battle
      return $map_battle.cur_actor
    else
      return $party.members[0]
    end
  end
  
  # 获取buff位图
  def self.get_buff_bitmap
    actor = $sel_body
    return Bitmap.new(22,20) unless $sel_body
    tbitmap = Bitmap.new([22*actor.buff.size,22].max,20)
    trect = Rect.new(0,0,21,20)
    actor.buff.each_with_index do |i,j|
      tbitmap.blt(j*22,0,Bitmap.new("Graphics/Icon/"+i.icon+".png"),trect)
    end
    return tbitmap
  end
  
  # 获取buff说明
  def self.get_buff_descr(index)
    index = [index,$sel_body.buff.size-1].min
    title = $sel_body.buff[index].name
    text = $sel_body.buff[index].descr
    textarr = text.split(/\n/)
    tbitmap = Bitmap.new(10,10)
    tbitmap.font.size = 16
    maxw = 0
    lineh = tbitmap.text_size("■").height
    tbitmap.font.size = 20
    titleh = tbitmap.text_size("■").height
    tbitmap.font.size = 16
    maxh = lineh*textarr.size+8+titleh
    textarr.each{|i| tw = tbitmap.text_size(i).width;maxw=tw if tw>maxw}
    maxw+=8
    tbitmap.dispose
    tbitmap = Bitmap.new(maxw,maxh)
    tbitmap.font.size = 20
    tbitmap.fill_rect(0,0,maxw,maxh,BUFF_DES_BACK)
    rem = tbitmap.font.color.clone
    tbitmap.font.color = DESCR_TITLE_COLOR
    tbitmap.draw_text(2,2,maxw,titleh,title,0)
    tbitmap.font.color = rem
    tbitmap.font.size = 16
    textarr.each_with_index{|i,j| tbitmap.draw_text(2,2+j*lineh+titleh,maxw,lineh,i,0)}
    return tbitmap
  end
  
  # 获取道具位图
  def self.get_item_bitmap(index)
    return Bitmap.new(36,36) if !$sel_body || !$sel_body.bag[index]
    a = Bitmap.new("Graphics/Icon/"+$sel_body.bag[index][0].icon+".png")
    tBitmap = Bitmap.new(36,36)
    tBitmap.font.size = 16
    tBitmap.blt(18-a.width/2,18-a.height/2,a,Rect.new(0,0,a.width,a.height))
    trect = tBitmap.text_size($sel_body.bag[index][1].to_s)
    trect.width+=2
    trect.height+=2
    tBitmap.draw_text(0,36-trect.height,36,trect.height,$sel_body.bag[index][1].to_s,2)
    return tBitmap
  end
  
  # 获取道具描述
  def self.get_item_descr(index)
    title = $sel_body.bag[index][0].name
    text = $sel_body.bag[index][0].descr
    textarr = text.split(/\n/)
    tbitmap = Bitmap.new(10,10)
    tbitmap.font.size = 16
    maxw = 0
    lineh = tbitmap.text_size("■").height
    tbitmap.font.size = 20
    titleh = tbitmap.text_size("■").height
    tbitmap.font.size = 16
    maxh = lineh*textarr.size+8+titleh
    textarr.each{|i| tw = tbitmap.text_size(i).width;maxw=tw if tw>maxw}
    maxw+=8
    tbitmap.dispose
    tbitmap = Bitmap.new(maxw,maxh)
    tbitmap.font.size = 20
    tbitmap.fill_rect(0,0,maxw,maxh,BUFF_DES_BACK)
    rem = tbitmap.font.color.clone
    tbitmap.font.color = DESCR_TITLE_COLOR
    tbitmap.draw_text(2,2,maxw,titleh,title,0)
    tbitmap.font.color = rem
    tbitmap.font.size = 16
    textarr.each_with_index{|i,j| tbitmap.draw_text(2,2+j*lineh+titleh,maxw,lineh,i,0)}
    return tbitmap
  end
  
  # 获取整个技能位图
  def self.get_all_skill_bitmap
    tBitmap = Bitmap.new(136,136)
    trect = Rect.new(0,0,38,38)
    [*0..5].each do |i|
      tBitmap.blt(*UI_SKILL_POS[i],self.get_skill_bitmap(i),trect)
    end
    tBitmap.font.size = 30
    if $sel_body
      if $sel_body.fake_skill && $sel_body.fake_skill[0].id == 4
        tBitmap.font.size = 22
        tBitmap.draw_text(39,40,60,60,"设置",1)
      else
        tBitmap.draw_text(39,37,60,60,$sel_body.sp,1)
      end
    end
    return tBitmap
  end
  
  # 获取技能位图
  def self.get_skill_bitmap(index)
    if !$sel_body || !$sel_body.skill[index]
      a = Bitmap.new(EMPTY_SKILL)
    else
      a = Bitmap.new("Graphics/Icon/"+$sel_body.skill[index].icon+".png")
    end
    tBitmap = Bitmap.new(38,38)
    tBitmap.blt(18-a.width/2,18-a.height/2,a,Rect.new(0,0,a.width,a.height))
    return tBitmap
  end
  
  # 获取技能说明
  def self.get_skill_descr(index)
    title = $sel_body.skill[index].name
    title=title+"(被动)" if !$sel_body.skill[index].init_skill
    title=title+"("+$sel_body.skill[index].hotkey.chr+")" if $sel_body.skill[index].hotkey
    text = $sel_body.skill[index].descr
    textarr = text.split(/\n/)
    tbitmap = Bitmap.new(10,10)
    tbitmap.font.size = 16
    maxw = 0
    lineh = tbitmap.text_size("■").height
    tbitmap.font.size = 20
    titleh = tbitmap.text_size("■").height
    tbitmap.font.size = 16
    maxh = lineh*textarr.size+8+titleh
    textarr.each{|i| tw = tbitmap.text_size(i).width;maxw=tw if tw>maxw}
    maxw+=8
    tbitmap.dispose
    tbitmap = Bitmap.new(maxw,maxh)
    tbitmap.font.size = 20
    tbitmap.fill_rect(0,0,maxw,maxh,BUFF_DES_BACK)
    rem = tbitmap.font.color.clone
    tbitmap.font.color = DESCR_TITLE_COLOR
    tbitmap.draw_text(2,2,maxw,titleh,title,0)
    tbitmap.font.color = rem
    tbitmap.font.size = 16
    textarr.each_with_index{|i,j| tbitmap.draw_text(2,2+j*lineh+titleh,maxw,lineh,i,0)}
    return tbitmap
  end
  
  # 获取属性的界面背景
  def self.get_ele_back_bitmap
    twidth = $party.members.size*128+($party.members.size-1)*42
    theight = 391
    rbitmap = Bitmap.new(twidth,theight)
    tbackbitmap = Bitmap.new(ELE_BACK)
    tshowbitmap = Bitmap.new(ELE_SHOW)
    trect = Rect.new(0,0,tbackbitmap.width,tbackbitmap.height)
    $party.members.each_with_index do |i,j|
      tmidbitmap = Bitmap.new("Graphics/Heads/"+i.head2+".png")
      tx = j*160
      ty = 0
      rbitmap.blt(tx,ty,tbackbitmap,trect)
      rbitmap.blt(tx,ty,tmidbitmap,trect)
      rbitmap.blt(tx,ty,tshowbitmap,trect)
    end
    return rbitmap
  end
  
  # 获取属性数值
  def self.get_ele_value_bitmap(w,h)
    rbitmap = Bitmap.new(w,h)
    $party.members.each_with_index do |i,j|
      tx = j*160
      ty = 0
      rbitmap.font.name = Font.default_name
      rbitmap.draw_text(tx,ty,128,34,i.name,1)
      rbitmap.font.name = "钟齐孟宪敏硬笔简体"
      rbitmap.draw_text(tx+42,ty+228,55,40,i.str[0]+i.str[1],2)
      rbitmap.draw_text(tx+42,ty+258,55,40,i.het[0]+i.het[1],2)
      rbitmap.draw_text(tx+42,ty+288,55,40,i.tec[0]+i.tec[1],2)
      rbitmap.draw_text(tx+42,ty+318,55,40,i.agi[0]+i.agi[1],2)
      rbitmap.draw_text(tx+18,ty+346,55,40,i.ep,2)
    end
    return rbitmap
  end
  
  # 获取属性描述
  
  def self.get_ele_descr(index)
    title = ELE_DESCR[index][0]
    text = ELE_DESCR[index][1]
    textarr = text.split(/\n/)
    tbitmap = Bitmap.new(10,10)
    tbitmap.font.size = 16
    maxw = 0
    lineh = tbitmap.text_size("■").height
    tbitmap.font.size = 20
    titleh = tbitmap.text_size("■").height
    tbitmap.font.size = 16
    maxh = lineh*textarr.size+8+titleh
    textarr.each{|i| tw = tbitmap.text_size(i).width;maxw=tw if tw>maxw}
    maxw+=8
    tbitmap.dispose
    tbitmap = Bitmap.new(maxw,maxh)
    tbitmap.font.size = 20
    tbitmap.fill_rect(0,0,maxw,maxh,BUFF_DES_BACK)
    rem = tbitmap.font.color.clone
    tbitmap.font.color = DESCR_TITLE_COLOR
    tbitmap.draw_text(2,2,maxw,titleh,title,0)
    tbitmap.font.color = rem
    tbitmap.font.size = 16
    textarr.each_with_index{|i,j| tbitmap.draw_text(2,2+j*lineh+titleh,maxw,lineh,i,0)}
    return tbitmap
  end
  
end