Scene_File = Scene_WebFile
Scene_Save = Scene_WebSave
Scene_Load = Scene_WebLoad

module DataManager
  #--------------------------------------------------------------------------
  # ● 判定存档文件是否存在
  #--------------------------------------------------------------------------
  def self.save_file_exists?
    true
  end
end