Graphics.resize_screen(640,480)
UpperLeft = Mouse::Component.new(11,13,239,114,100)
UpperLeft.setContents Bitmap.new("Graphics/System/player")
UpperRight = [
Mouse::Component.new(608,13,24,24,100),
Mouse::Component.new(608-24-7,13,24,24,100)
]
UpperRight[0].str = "1"
UpperRight[1].str = "2"
LowerRight = Mouse::Component.new(507,348,108,103,100)
LowerRight.setContents Bitmap.new("Graphics/System/skill")
LowerRight.getContents.font = Font.new("百度综艺简体")
LowerRight.getContents.font.outline = false
LowerRight.getContents.font.color = Color.new(0,0,0)
LowerRight.drawStr("30%",37,50,18)
Desc = Mouse::Component.new(494,275,130,60,100)
Icon = [
Mouse::Component.new(507,410,36,36,100),
Mouse::Component.new(542,348,36,36,100),
Mouse::Component.new(579,410,36,36,100)
]
Icon[0].setContents Bitmap.new("Graphics/System/cs")
Icon[1].setContents Bitmap.new("Graphics/System/cs")
Icon[2].setContents Bitmap.new("Graphics/System/cs")