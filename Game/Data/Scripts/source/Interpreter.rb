#Interpreter v0.2
#支持逻辑控制符 IF WHILE
#by yangff
=begin
	下面由我来解说事件系统脚本语言
	符号：
		在代码中，符号有三种（算上事件结构是4种）分别是（不含引号）“#”，“+”，“-”，“*”（只用在事件结构中）
		其中
			# 是人民群众喜闻乐见的注释。
			+ 是事件语句，由系统直接eval得到
			- 是逻辑结构语句，后接 IF WHILE END 这三种控制语句。
			* 是事件的声明语句，以后再介绍
	迭代深度：
		代码的迭代深度本来是由程序计算，因为作者懒得弄，所以你就写出来吧。。
		其中IF WHILE会导致接下来的迭代深度++而END的会导致其--
		比如
			-x IF ....
			+(x+1) 你的代码
			+(x+1) 你的代码
			+(x+1) 你的代码
			-(x+1) WHILE ....
			+(x+2) 你的代码
			+(x+2) 你的代码
			+(x+2) 你的代码			
			-(x+1) END
			-x END
		虽然要计算这个不是很麻烦……但是……呵呵呵。
	纠错系统比RM的执行脚本好多了……试了就知道……湿了就知道……嘿嘿嘿。
=end
class Interpreter
	def initialize(event,script,deep=0)
		flag=false
		throw "Stack over flow." if deep>500
		@child=nil
		@scripts=[]
		@event=event
		@pos=0
		@abspos=script[2]
		@level=0
		@sleep=0
		@name=script[0]
		@var=[]
		@whileflag=[]
		@sum=[0]
		line=0
		for i in script[1]
			@sum[line]=@sum[line-1]+1 if (@sum[line].nil?)
			i=i.lstrip
			if (i[0]=="#"||i=="")
				@sum[line]+=1
				next
			end
			@scripts<<i if (i[0]=="+"||i[0]=="-")
			line+=1
		end
	end
	def safeval(code)
		eval(code,"Event:#{@name} Line:#{@sum[@pos]+@abspos+1}\n")
	end
	def go
		@sleep-=1
		return true if @pos>=@scripts.size
		return false if @sleep>0
		if (@child!=nil)
			@child=nil if @child.go
			return false
		else
			code=@scripts[@pos].split(" ",3)
			if (code[0][0]=="-")
				if (code[1].upcase=="IF")
					
					if (saveval(code[2]))
						@level+=1
						@pos+=1
					else
						@pos=findflag(@level,"ELSE")+1
						@level+=1
					end
				end
				if (code[1].upcase=="ELSE")
					@level-=1
					@pos=findflag(@level,"END")+1
				end
				if (code[1].upcase=="WHILE")
					if (saveval(code[2]))
						@whileflag[@level]=@pos
						@pos+=1
						@level+=1
					else
						@pos=findflag(@level,"END")+1
						@whileflag[@level]=nil
					end
				end
				if (code[1].upcase=="END")
					if (@whileflag[@level-1])
						@pos=@whileflag[@level-1]
					else
						@pos=@pos+1
					end
					@level-=1
				end
			else
				if (@scripts[@pos][0]=="+")
					eval(saveval(code[2]))
					@pos+=1
				end
			end
		end
		return false
	end
	def setpos(i)
		@child=nil
		@pos=0
	end
	def callevent(name)
		@child=Interpreter.new(@event,$evman.load(name),deep+1)
	end
	def sleep(time)
		@sleep+=time
	end
	def findflag(lv,flag)
		for i in @pos...@scripts.size
			code=@scripts[i].split(" ",2)
			if (code[0]=="-#{lv}" and code[1].upcase==flag)
				return i
			end
		end
	end
end
#############################################################
#下面是测试代码
#############################################################
scr="+0 print 'hi'
-0 IF true
  +1 print 'true'
  +1 print 'yooooooooo'
-0 END
-0 IF false
  +1 print 'true'
  +1 print 'yooooooooo'
-0 ELSE
  +1 print 'hi'
  +1 @var[0]=1
  -1 WHILE @var[0]<5
    +2 print 'ooo'
    +2 @var[0]+=1
  -1 END
-0 END"
@interpreter=Interpreter.new(nil,["EV0001",scr.split(/\n/),0])
a=false
a=@interpreter.go while not a