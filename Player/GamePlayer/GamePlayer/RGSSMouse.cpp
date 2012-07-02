#include "RGSSMouse.h"
int RGSSMouse::mouse_x = 0;
int RGSSMouse::mouse_y = 0;
bool RGSSMouse::mouse_ltd;
bool RGSSMouse::mouse_ldown;
bool RGSSMouse::mouse_rtd;
bool RGSSMouse::mouse_rdown;
int RGSSMouse::mouse_press;
int RGSSMouse::mouse_toggled;
int RGSSMouse::mouse_count=0;
double RGSSMouse::DBLCTIME;
int RGSSMouse::pos;
#ifdef HookerTest
extern FILE *LOG;
#endif
LRESULT WINAPI RGSSMouse::MouseWndProcHook(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam)
{
#ifdef HookerTest
	fprintf(LOG,"MouseWndProcHook:%d\n\r",pos);fflush(LOG);
#endif	
	if (Msg==WM_LBUTTONDOWN)
	{
		mouse_ltd=true;
		if (mouse_ldown) mouse_ltd=false;
		mouse_ldown=true;
	}
	if (Msg==WM_RBUTTONDOWN)
	{
		mouse_rtd=true;
		if (mouse_rdown) mouse_rtd=false;
		mouse_rdown=true;
	}
	if (Msg==WM_LBUTTONUP)
	{
		mouse_ldown=false;
		mouse_ltd=false;
	}
	if (Msg==WM_RBUTTONUP)
	{
		mouse_rdown=false;
		mouse_rtd=false;
	}
	if (Msg==WM_LBUTTONDBLCLK)
	{
		//  ……
	}
	if (Msg==WM_RBUTTONDBLCLK)
	{
		//  ……
	}
	if (Msg==WM_MOUSEMOVE)
	{
		mouse_x = IParam&0xffff;
		mouse_y = IParam>>16;
	}
	return CallNext(hWnd,Msg,wParam,IParam,pos);
}
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::MouseUpdate(RGSS3Runtime::VALUE obj)
{
	return RGSS3Runtime::Qnil;
}
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_get_x(RGSS3Runtime::VALUE obj)
{
	return runtime->INT2FIX(mouse_x); //???会导致APPCRASH？
}
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_get_y(RGSS3Runtime::VALUE obj)
{
	return runtime->INT2FIX(mouse_y);
}
/*
#     Mouse.up?(key)
#       鼠标按键是否处在"松开"的瞬间
#       参数key取值(1:左键 2:右键 4:中键),允许不输入参数,表示任意鼠标键,下同
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_up(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key)
{
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.down?(key)
#       鼠标按键是否处在"按下"的瞬间
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_down(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.click?(key)
#       鼠标按键单击,脚本简化,仅判断down?
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_click(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.dbl_clk?(key)
#       鼠标按键双击
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_dbl_clk(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.press?(key)
#       鼠标按键是否处在"按下"的状态
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_press(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.toggle?(key)
#       鼠标按键的触发状态(在开和关之间切换)
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_toggle(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.scroll
#       返回鼠标滚轮的滚动值.正值表示向前,负值表示向后,零表示未发生滚动
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_scroll(RGSS3Runtime::VALUE obj){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.move?
#       判断鼠标是否移动
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_move(RGSS3Runtime::VALUE obj){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.set_pos(x,y)
#       指定鼠标坐标,鼠标移动到该坐标
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_set_pos(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE x,RGSS3Runtime::VALUE y){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.set_cursor(file)
#       改变当前鼠标的光标样式.参数file为光标文件名(路径由配置模块指定)
#       如果参数为nil或者指定光标文件不存在等,不返回错误,但光标不可见
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_set_cursor(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE mouse){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.sys_cursor
#       还原到系统默认光标
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_sys_cursor(RGSS3Runtime::VALUE obj){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.clip(x,y,width,height)
#       把鼠标锁死在指定区域范围内
#       省略参数时,解除鼠标锁定
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_clip(int argc, RGSS3Runtime::VALUE *argv,RGSS3Runtime::VALUE obj){
	if (argc==0)
	{
		// Unlock
	}
	else
	{

	}
	return RGSS3Runtime::Qnil;
}
void RGSSMouse::InitRuby()
{
	DBLCTIME =   GetDoubleClickTime()*60.0/1000.0;
	RGSS3Runtime::VALUE rbcMouse = runtime->rb_define_module("CMouse");
	runtime->rb_define_module_function(rbcMouse,"update",(RGSS3Runtime::RubyFunc)MouseUpdate,0);
	runtime->rb_define_module_function(rbcMouse,"x",(RGSS3Runtime::RubyFunc)dm_get_x,0);
	runtime->rb_define_module_function(rbcMouse,"y",(RGSS3Runtime::RubyFunc)dm_get_y,0);
	runtime->rb_define_module_function(rbcMouse,"up?",(RGSS3Runtime::RubyFunc)dm_up,0);
	runtime->rb_define_module_function(rbcMouse,"down?",(RGSS3Runtime::RubyFunc)dm_down,0);
	runtime->rb_define_module_function(rbcMouse,"click?",(RGSS3Runtime::RubyFunc)dm_click,0);
	runtime->rb_define_module_function(rbcMouse,"dbl_clk?",(RGSS3Runtime::RubyFunc)dm_dbl_clk,0);
	runtime->rb_define_module_function(rbcMouse,"press?",(RGSS3Runtime::RubyFunc)dm_press,0);
	runtime->rb_define_module_function(rbcMouse,"toggle?",(RGSS3Runtime::RubyFunc)dm_toggle,0);
	runtime->rb_define_module_function(rbcMouse,"scroll",(RGSS3Runtime::RubyFunc)dm_scroll,0);
	runtime->rb_define_module_function(rbcMouse,"move",(RGSS3Runtime::RubyFunc)dm_move,0);
	runtime->rb_define_module_function(rbcMouse,"set_pos",(RGSS3Runtime::RubyFunc)dm_set_pos,2);
	runtime->rb_define_module_function(rbcMouse,"set_cursor",(RGSS3Runtime::RubyFunc)dm_set_cursor,1);
	runtime->rb_define_module_function(rbcMouse,"sys_cursor",(RGSS3Runtime::RubyFunc)dm_sys_cursor,0);
	runtime->rb_define_module_function(rbcMouse,"clip",(RGSS3Runtime::RubyFunc)dm_clip,-1);
}
bool RGSSMouse::Install()
{
	pos = SetupWndHook((WNDPROC)MouseWndProcHook);
	return true;
}


RGSSMouse::RGSSMouse(void)
{
}
RGSSMouse::~RGSSMouse(void)
{
}
