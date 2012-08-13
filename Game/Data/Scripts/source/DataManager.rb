#encoding:utf-8
#==============================================================================
# ■ DataManager
#------------------------------------------------------------------------------
# 　数据库和游戏实例的管理器。所有在游戏中使用的全局变量都在这里初始化。
#==============================================================================

module DataManager
  #--------------------------------------------------------------------------
  # ● 模块的实例变量
  #--------------------------------------------------------------------------
  @last_savefile_index = 0                # 最后访问的存档文件
  #--------------------------------------------------------------------------
  # ● 初始化模块
  #--------------------------------------------------------------------------
  def self.init
    @last_savefile_index = 0
    load_database
    create_game_objects
    setup_battle_test if $BTEST
  end
  #--------------------------------------------------------------------------
  # ● 读取数据库
  #--------------------------------------------------------------------------
  def self.load_database
    if $BTEST
      load_battle_test_database
    else
      load_normal_database
      check_player_location
    end
  end
  #--------------------------------------------------------------------------
  # ● 读取普通的数据库
  #--------------------------------------------------------------------------
  def self.load_normal_database
    $data_actors        = load_data("Data/Actors.rvdata2")
    $data_classes       = load_data("Data/Classes.rvdata2")
    $data_skills        = load_data("Data/Skills.rvdata2")
    $data_items         = load_data("Data/Items.rvdata2")
    $data_weapons       = load_data("Data/Weapons.rvdata2")
    $data_armors        = load_data("Data/Armors.rvdata2")
    $data_enemies       = load_data("Data/Enemies.rvdata2")
    $data_troops        = load_data("Data/Troops.rvdata2")
    $data_states        = load_data("Data/States.rvdata2")
    $data_animations    = load_data("Data/Animations.rvdata2")
    $data_tilesets      = load_data("Data/Tilesets.rvdata2")
    $data_common_events = load_data("Data/CommonEvents.rvdata2")
    $data_system        = load_data("Data/System.rvdata2")
    $data_mapinfos      = load_data("Data/MapInfos.rvdata2")
  end
  #--------------------------------------------------------------------------
  # ● 读取战斗测试用的数据库
  #--------------------------------------------------------------------------
  def self.load_battle_test_database
    $data_actors        = load_data("Data/BT_Actors.rvdata2")
    $data_classes       = load_data("Data/BT_Classes.rvdata2")
    $data_skills        = load_data("Data/BT_Skills.rvdata2")
    $data_items         = load_data("Data/BT_Items.rvdata2")
    $data_weapons       = load_data("Data/BT_Weapons.rvdata2")
    $data_armors        = load_data("Data/BT_Armors.rvdata2")
    $data_enemies       = load_data("Data/BT_Enemies.rvdata2")
    $data_troops        = load_data("Data/BT_Troops.rvdata2")
    $data_states        = load_data("Data/BT_States.rvdata2")
    $data_animations    = load_data("Data/BT_Animations.rvdata2")
    $data_tilesets      = load_data("Data/BT_Tilesets.rvdata2")
    $data_common_events = load_data("Data/BT_CommonEvents.rvdata2")
    $data_system        = load_data("Data/BT_System.rvdata2")
  end
  #--------------------------------------------------------------------------
  # ● 检查玩家初始位置
  #--------------------------------------------------------------------------
  def self.check_player_location
    if $data_system.start_map_id == 0
      msgbox(Vocab::PlayerPosError)
      exit
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成各种游戏对象
  #--------------------------------------------------------------------------
  def self.create_game_objects
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_timer         = Game_Timer.new
    $game_message       = Game_Message.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    $party              = Party.new
    $party.members << Fucker.new(0,[0])
    $party.members << BeFucker.new(-1,[0])
  end
  #--------------------------------------------------------------------------
  # ● 设置新游戏
  #--------------------------------------------------------------------------
  def self.setup_new_game
    create_game_objects
    $game_party.setup_starting_members
    $game_map.setup($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    Graphics.frame_count = 0
  end
  #--------------------------------------------------------------------------
  # ● 设置战斗测试
  #--------------------------------------------------------------------------
  def self.setup_battle_test
    $game_party.setup_battle_test
    BattleManager.setup($data_system.test_troop_id)
    BattleManager.play_battle_bgm
  end
  #--------------------------------------------------------------------------
  # ● 判定存档文件是否存在
  #--------------------------------------------------------------------------
  def self.save_file_exists?
    !Dir.glob('Save*.rvdata2').empty?
  end
  #--------------------------------------------------------------------------
  # ● 存档文件的最大数
  #--------------------------------------------------------------------------
  def self.savefile_max
    return 16
  end
  #--------------------------------------------------------------------------
  # ● 生成文件名
  #     index : 文件索引
  #--------------------------------------------------------------------------
  def self.make_filename(index)
    sprintf("SaveData.orzfly", index + 1)
  end
  #--------------------------------------------------------------------------
  # ● 执行存档
  #--------------------------------------------------------------------------
  def self.save_game(index)
    begin
      save_game_without_rescue(index)
    rescue
      delete_save_file(index)
      false
    end
  end
  #--------------------------------------------------------------------------
  # ● 执行读档
  #--------------------------------------------------------------------------
  def self.load_game(index)
    load_game_without_rescue(index) rescue false
  end
  #--------------------------------------------------------------------------
  # ● 读取存档的头数据
  #--------------------------------------------------------------------------
  def self.load_header(index)
    load_header_without_rescue(index) rescue nil
  end
  #--------------------------------------------------------------------------
  # ● 执行存档（没有错误处理）
  #--------------------------------------------------------------------------
  def self.save_game_without_rescue(index)
    File.open(make_filename(index), "wb") do |file|
      file << self.save_game_real
      @last_savefile_index = index
    end
    return true
  end
  def self.save_game_real
    temps = []
    $game_system.on_before_save
    temps << Marshal.dump(make_save_header)
    temps << Marshal.dump(make_save_contents)
    return Zlib::Deflate.deflate(Marshal.dump(temps))
  end
  #--------------------------------------------------------------------------
  # ● 执行读档（没有错误处理）
  #--------------------------------------------------------------------------
  def self.load_game_without_rescue(index)
    File.open(make_filename(index), "rb") do |file|
      self.load_game_real file.read
      @last_savefile_index = index
    end
    return true
  end
  def self.load_game_real real
    extract_save_contents(Marshal.load(Marshal.load(Zlib::Inflate.inflate(real))[1]))
    reload_map_if_updated
  end
  #--------------------------------------------------------------------------
  # ● 读取存档的头数据（没有错误处理）
  #--------------------------------------------------------------------------
  def self.load_header_without_rescue(index)
    File.open(make_filename(index), "rb") do |file|
      return self.load_header_real file.read
    end
    return nil
  end
  def self.load_header_real real
    return Marshal.load(Marshal.load(Zlib::Inflate.inflate(real))[0])
  end
  #--------------------------------------------------------------------------
  # ● 删除存档文件
  #--------------------------------------------------------------------------
  def self.delete_save_file(index)
    File.delete(make_filename(index)) rescue nil
  end
  #--------------------------------------------------------------------------
  # ● 生成存档的头数据
  #--------------------------------------------------------------------------
  def self.make_save_header
    header = {}
    header[:characters] = $game_party.characters_for_savefile
    header[:playtime_s] = $game_system.playtime_s
    header
  end
  #--------------------------------------------------------------------------
  # ● 生成存档内容
  #--------------------------------------------------------------------------
  def self.make_save_contents
    contents = {}
    contents[:system]        = $game_system
    contents[:timer]         = $game_timer
    contents[:message]       = $game_message
    contents[:switches]      = $game_switches
    contents[:variables]     = $game_variables
    contents[:self_switches] = $game_self_switches
    contents[:actors]        = $game_actors
    contents[:party]         = $game_party
    contents[:troop]         = $game_troop
    contents[:map]           = $game_map
    contents[:player]        = $game_player
    contents[:rparty]        = $party
    contents
  end
  #--------------------------------------------------------------------------
  # ● 展开存档内容
  #--------------------------------------------------------------------------
  def self.extract_save_contents(contents)
    $game_system        = contents[:system]
    $game_timer         = contents[:timer]
    $game_message       = contents[:message]
    $game_switches      = contents[:switches]
    $game_variables     = contents[:variables]
    $game_self_switches = contents[:self_switches]
    $game_actors        = contents[:actors]
    $game_party         = contents[:party]
    $game_troop         = contents[:troop]
    $game_map           = contents[:map]
    $game_player        = contents[:player]
    $party              = contents[:rparty]
  end
  #--------------------------------------------------------------------------
  # ● 如果数据已更新则重载地图
  #--------------------------------------------------------------------------
  def self.reload_map_if_updated
    if $game_system.version_id != $data_system.version_id
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
      $game_player.make_encounter_count
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取存档文件时间戳
  #--------------------------------------------------------------------------
  def self.savefile_time_stamp(index)
    File.mtime(make_filename(index)) rescue Time.at(0)
  end
  #--------------------------------------------------------------------------
  # ● 获取“最后更新的存档文件”的索引
  #--------------------------------------------------------------------------
  def self.latest_savefile_index
    savefile_max.times.max_by {|i| savefile_time_stamp(i) }
  end
  #--------------------------------------------------------------------------
  # ● 获取“最后访问的存档文件”的索引
  #--------------------------------------------------------------------------
  def self.last_savefile_index
    @last_savefile_index
  end
  
  def self.save_web_game(index)
    content = [self.save_game_real].pack("m").gsub("\n", "").tr("+=", ":$")
    req = CLiteHTTP.request "lynngame.sinaapp.com", 80, re = <<END
POST /project7.php?secret=#{$WebLogin_user}&id=#{index} HTTP/1.0
Host: lynngame.sinaapp.com
User-Agent: RGSS3 Player (RGSSX 1.0; Project7)
Content-Type: application/x-www-form-urlencoded
Content-Length: #{content.size + 5}
Connection: close

data=#{content}
END
    if req.is_a?(String) && req[/X-Project7Cloud-Result:\s*200/i]
      return true
    else
      return false
    end
  end
  
  def self.load_web_game(index)
    @web_cache ||= []
    unless @web_cache[index]
      load_web_header(index)
    end
    return (self.load_game_real @web_cache[index]; true) rescue false
  end
  
  def self.load_web_header(index)
    @web_cache ||= []
    req = CLiteHTTP.request "lynngame.sinaapp.com", 80, <<END
GET /project7.php?secret=#{$WebLogin_user}&id=#{index} HTTP/1.0
Host: lynngame.sinaapp.com
User-Agent: RGSS3 Player (RGSSX 1.0; Project7)
Connection: close


END
    if req.is_a?(String) && req[/X-Project7Cloud-Result:\s*200/i]
      if req[/<code>(.*?)<\/code>/i]
        return nil if $1.size == 0
        @web_cache[index] = $1.tr(":$", "+=").unpack("m")[0]
        return self.load_header_real @web_cache[index] rescue nil
      end
    end
    nil
  end
end