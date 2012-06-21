#encoding: utf-8
require 'zlib'
def load_file(fn)
obj=""
File.open(fn, "rb") { |f|
  obj = Marshal.load(f)
}
return obj
end

s=load_file("Scripts1.rvdata2")
File.open("Scripts\\source\\rakefile.info","w"){|out|
s.each{|ss| 
print ss[1]
if (ss[1]!=""and ss[1]!="Main")
out.write("#{ss[1]}\n")
end
}

}
gets