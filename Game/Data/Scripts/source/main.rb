File.open("Data/Scripts/source/rakefile.info","rb"){|f|
	fns=f.readlines
	fns.each{|fn|fn=fn.delete("\n").delete("\r")
		File.open("Data/Scripts/source/#{fn}.rb","rb"){|fa|eval(fa.read(),$BINDING,fn)}
	}
}
rgss_main { SceneManager.run }
