#encoding:utf-8
#==============================================================================
# ■ Scene_WebLogin
#==============================================================================

class Scene_WebLogin < Scene_Base
  class Jiecao
    def call(e)
      args = e[/^lynn:\/\/(.*)\/?$/i]
      if args
        hook=$1
        if hook[/^cancel\/?$/i]
          $WebLogin_user = nil
          SceneManager.return
        else
          hook[/^(.*)\/(.*)$/]
          $WebLogin_user = $2
        end
        @browser.dispose
        @browser = nil
        return false
      end
    end
  end
  
  def main
    jiecao = Jiecao.new
    jiecao.instance_variable_set :@browser, CBrower.new("http://lynngame.sinaapp.com/?action=ingameLogin", 0, 0, Graphics.width, Graphics.height, jiecao)
    loop do
      Graphics.update
      break unless jiecao.instance_variable_get :@browser
    end
    RGSSX.ensure
    return_scene
  end
  
  def adapt_screen
    a = (jiecao.instance_variable_get :@browser)
    a.w = Graphics.width
    a.h = Graphics.height
  end
end
