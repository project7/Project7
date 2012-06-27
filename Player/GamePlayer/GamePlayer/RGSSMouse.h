#pragma once
#include "abstractrgssextension.h"
#include "RGSS3Runtime.h"

class RGSSMouse :
	public AbstractRGSSExtension
{
public:
	RGSSMouse(RGSS3Runtime *_runtime,GamePlayer * _gameplayer);
	~RGSSMouse(void);
	static RGSS3Runtime::VALUE RUBYCALL MouseUpdate(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_get_x(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_get_y(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_up(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key);
	static RGSS3Runtime::VALUE RUBYCALL dm_down(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key);
	static RGSS3Runtime::VALUE RUBYCALL dm_click(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key);
	static RGSS3Runtime::VALUE RUBYCALL dm_dbl_clk(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key);
	static RGSS3Runtime::VALUE RUBYCALL dm_press(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key);
	static RGSS3Runtime::VALUE RUBYCALL dm_toggle(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key);
	static RGSS3Runtime::VALUE RUBYCALL dm_scroll(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_move(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_set_pos(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE x,RGSS3Runtime::VALUE y);
	static RGSS3Runtime::VALUE RUBYCALL dm_set_cursor(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE mouse);
	static RGSS3Runtime::VALUE RUBYCALL dm_sys_cursor(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_clip(int argc, RGSS3Runtime::VALUE *argv,RGSS3Runtime::VALUE obj);
};

/*
#     Mouse.pos
#       提供鼠标坐标,返回值是个数组,格式为[x,y]
#     Mouse.area?(rect)
#       判断鼠标是否在参数rect范围内
#     Mouse.up?(key)
#       鼠标按键是否处在"松开"的瞬间
#       参数key取值(1:左键 2:右键 4:中键),允许不输入参数,表示任意鼠标键,下同
#     Mouse.down?(key)
#       鼠标按键是否处在"按下"的瞬间
#     Mouse.click?(key)
#       鼠标按键单击,脚本简化,仅判断down?
#     Mouse.dbl_clk?(key)
#       鼠标按键双击
#     Mouse.press?(key)
#       鼠标按键是否处在"按下"的状态
#     Mouse.toggle?(key)
#       鼠标按键的触发状态(在开和关之间切换)
#     Mouse.scroll
#       返回鼠标滚轮的滚动值.正值表示向前,负值表示向后,零表示未发生滚动
#     Mouse.move?
#       判断鼠标是否移动
#     Mouse.set_pos(x,y)
#       指定鼠标坐标,鼠标移动到该坐标
#     Mouse.set_cursor(file)
#       改变当前鼠标的光标样式.参数file为光标文件名(路径由配置模块指定)
#       如果参数为nil或者指定光标文件不存在等,不返回错误,但光标不可见
#     Mouse.sys_cursor
#       还原到系统默认光标
#     Mouse.clip(x,y,width,height)
#       把鼠标锁死在指定区域范围内
#       省略参数时,解除鼠标锁定
*/
extern RGSSMouse *cRGSSMouse;