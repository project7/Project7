#pragma once
#include "abstractrgssextension.h"
#include "RGSS3Runtime.h"

class RGSSMouse :
	public AbstractRGSSExtension
{
public:
	RGSSMouse();//(RGSS3Runtime *_runtime,GamePlayer * _gameplayer);
	static bool Install();
	~RGSSMouse(void);
	static RGSS3Runtime::VALUE RUBYCALL MouseUpdate(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_get_x(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_get_y(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_up(int argc, RGSS3Runtime::VALUE *argv,RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_down(int argc, RGSS3Runtime::VALUE *argv,RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_click(int argc, RGSS3Runtime::VALUE *argv, RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_dbl_clk(int argc, RGSS3Runtime::VALUE *argv, RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_press(int argc, RGSS3Runtime::VALUE *argv, RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_toggle(int argc, RGSS3Runtime::VALUE *argv, RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_scroll(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_move(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_set_pos(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE x,RGSS3Runtime::VALUE y);
	static RGSS3Runtime::VALUE RUBYCALL dm_set_cursor(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE mouse);
	static RGSS3Runtime::VALUE RUBYCALL dm_sys_cursor(RGSS3Runtime::VALUE obj);
	static RGSS3Runtime::VALUE RUBYCALL dm_clip(int argc, RGSS3Runtime::VALUE *argv,RGSS3Runtime::VALUE obj);
	static LRESULT WINAPI MouseWndProcHook(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam);
	static int mouse_x;
	static int mouse_y;
	static bool mouse_ldown;
	static bool mouse_rdown;
	static bool mouse_mdown;
	static bool mouse_lup;
	static bool mouse_rup;
	static bool mouse_mup;
	static bool mouse_lpress;
	static bool mouse_rpress;
	static bool mouse_mpress;
	static bool mouse_ldblc;
	static bool mouse_rdblc;
	static bool mouse_mdblc;
	static bool mouse_ltoggle;
	static bool mouse_rtoggle;
	static bool mouse_mtoggle;
	static bool mouse_moved;
	static int mouse_wheel;
	static LONG dwNewLong;
	static const int MOUSELKEY=1;
	static const int MOUSERKEY=2;
	static const int MOUSEMKEY=4;
	static double DBLCTIME;
	static int pos;
	static void InitRuby();
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