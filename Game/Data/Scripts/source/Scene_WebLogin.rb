#encoding:utf-8
#==============================================================================
# ■ Scene_WebLogin
#==============================================================================

class Scene_WebLogin < Scene_Base
  class Jiecao
    def call(e)
      puts e
      args = e[/^lynn:\/\/(.*)$/i]
      if args
        puts args
        @browser.dispose
        @browser = nil
        return false
      end
    end
  end
  
  def main
    jiecao = Jiecao.new
    jiecao.instance_variable_set :@browser, CBrower.new("http://lynngame.sinaapp.com/?action=ingameLogin", 0, 0, 640, 480, jiecao)
    loop do
      Graphics.update
      break unless jiecao.instance_variable_get :@browser
    end
    return_scene
  end
end
