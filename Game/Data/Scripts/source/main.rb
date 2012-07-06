#encoding:utf-8
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
