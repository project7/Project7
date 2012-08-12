#encoding:utf-8
if $HookerTest
	$fdebug=File.new("debug_#{Time.now.to_i}.log","w")
	$fdebug.flush
end
#==============================================================================
# ■ Auto Flush for STDOUT & STDERR
#------------------------------------------------------------------------------
# 　针对标准流启用自动 flush。
#==============================================================================
[STDOUT, STDERR].each do |stream|
	class << stream
		alias _debugger_noflush_p p
		alias _debugger_noflush_print print
		alias _debugger_noflush_puts puts

		def p(*args); _debugger_noflush_p(*args); flush; end
		def print(*args); _debugger_noflush_print(*args); flush; end
		def puts(*args); _debugger_noflush_puts(*args); flush; end
	end
end
alias _debugger_noflush_p p
alias _debugger_noflush_print print
alias _debugger_noflush_puts puts

def p(*args); _debugger_noflush_p(*args); STDOUT.flush; end
def print(*args); _debugger_noflush_print(*args); STDOUT.flush; end
def puts(*args); _debugger_noflush_puts(*args); STDOUT.flush; end

#==============================================================================
# ■ Debugger
#------------------------------------------------------------------------------
# 　调试器（大雾）
#==============================================================================
class Exception
	def _debugger_
		_debugger_inspect
=begin
		这个 2B 命令行调试器 binding 在 Exception，而无法还原犯罪现场……
		于是直接 exit 了事
		loop do
			STDERR.print "\n# Debugger>"
			input = gets
			begin
				output = eval(input, binding, "Debugger")
				STDERR.print "=> " << output.to_s
			rescue
				$!._debugger_inspect
			end
		end
=end
		exit
	end
	def _debugger_inspect
		STDERR.puts "# 发生异常 " + self.class.name
		STDERR.puts "#   " + self.message.split(/\n/).join("\n#   ")
		STDERR.puts "#       " + self.backtrace.join("\n#       ")
	end
end
#BBB.test
class Jiecao
  def set(id)
    @id=id
  end
  def call(e)
    args=e.split(/\\/)
    if (args[args.size-1]=="exit")
      $fdebug.write("Try to dispose "+e+"\n");
      @id.dispose
      return false
    end
    if (args[args.size-1]=="new")
      @p=Jiecao.new
      @p.set CBrower.new(Dir.pwd+"\\a.html",240+50+5,360+50+5,240,360,@p)
      return false
    end
    $fdebug.write("Try to "+e+"\n");$fdebug.flush;return true # 如果是false就禁止！！
  end
end
#@p=Jiecao.new
#@p.set CBrower.new(Dir.pwd+"\\a.html",25,25,540,420,@p)
#@pp=Jiecao.new
#@pp.set CBrower.new(Dir.pwd+"\\a.html",50,50+360,240,360,@pp)
#==============================================================================
# ■ Loader
#------------------------------------------------------------------------------
# 　脚本加载。
#==============================================================================
File.open("Data/Scripts/source/rakefile.info","rb"){|f|
	fns=f.readlines
	fns.each{|fn|fn=fn.delete("\n").delete("\r")
		File.open("Data/Scripts/source/#{fn}.rb","rb"){|fa|
			begin
				eval(fa.read(),$BINDING,fn)
			rescue
				$!._debugger_
			rescue SyntaxError
				$!._debugger_
			end
		} rescue (STDERR.print "无法打开文件 #{fn}.rb。\n"; exit)
	}
}
#DEBUG Mode
#
#set_trace_func proc{ |event, file, line,id, binding, klass, *rest|
#$fdebug.write(sprintf("<%s> %8s %s:%d %s %s\n", Time.now,event, file, line,klass, id))
#
#}
#alias  old_exit exit
#def exit(*args)
#$fdebug.write(sprintf("<%s> Game exit", Time.now))
#  $fdebug.flush
#  exit_old(*args)
#end
#==============================================================================
# ■ Main
#------------------------------------------------------------------------------
# 　一切准备工作完成之后，从这里开始运行游戏。
#==============================================================================
begin
	rgss_main { SceneManager.run }
rescue
	$!._debugger_
rescue SyntaxError
	$!._debugger_
end

if $HookerTest
	$fdebug.write(sprintf("<%s> Game exit", Time.now))
	$fdebug.close
end