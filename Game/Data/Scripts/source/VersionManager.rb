module VersionManager; end
class << VersionManager
  def version
    "git current"
  end
  
  def new_version
    (@new_version ||= check) rescue []
  end
  
  def check
    req = CLiteHTTP.request "9buorg.sinaapp.com", 80, <<END
GET /updater.php?id=project7-dev HTTP/1.0
Host: 9buorg.sinaapp.com
User-Agent: RGSS3 Player (RGSSX 1.0; Project7)
Connection: close


END
    if req.is_a?(String) && req[/X-NineBu-Result:\s*200/i]
      title = req[/<h1>(.*?)<\/h1>/i] ? $1 : ""
      description = req[/<blockquote>((.|\n)*?)<\/blockquote>/i] ? $1 : ""
      url = req[/<a href="(.*?)">download<\/a>/i] ? $1 : ""
      time = req[/<span class="time">(.*?)<\/span>/i] ? (
        $1.gsub(/(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)([+-]\d\d:\d\d)/) do
          Time.new($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i, $7).localtime
        end
      ) : Time.now
      return [title, description, url, time]
    end
  end
end
