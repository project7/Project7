#include "RGSSMouse.h"
int mouse_x;
int mouse_y;
bool mouse_ltd;
bool mouse_ldown;
bool mouse_rtd;
bool mouse_rdown;
int mouse_press;
int mouse_toggled;
int mouse_count=0;
const int MOUSELKEY=1;
const int MOUSERKEY=2;
const int MOUSEMKEY=4;
double DBLCTIME;
LRESULT WINAPI MouseWndProcHook(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam)
{
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
		//  ����
	}
	if (Msg==WM_RBUTTONDBLCLK)
	{
		//  ����
	}
	if (Msg==WM_MOUSEMOVE)
	{
		mouse_x = IParam&0xffff;
		mouse_x = IParam>>16;
	}
	return cRGSSMouse->CallNext(hWnd,Msg,wParam,IParam);
}
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::MouseUpdate(RGSS3Runtime::VALUE obj)
{
	return RGSS3Runtime::Qnil;
}
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_get_x(RGSS3Runtime::VALUE obj)
{
	return mouse_x;
}
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_get_y(RGSS3Runtime::VALUE obj)
{
	return mouse_y;
}
/*
#     Mouse.up?(key)
#       ��갴���Ƿ���"�ɿ�"��˲��
#       ����keyȡֵ(1:��� 2:�Ҽ� 4:�м�),�������������,��ʾ��������,��ͬ
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_up(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key)
{
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.down?(key)
#       ��갴���Ƿ���"����"��˲��
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_down(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.click?(key)
#       ��갴������,�ű���,���ж�down?
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_click(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.dbl_clk?(key)
#       ��갴��˫��
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_dbl_clk(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.press?(key)
#       ��갴���Ƿ���"����"��״̬
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_press(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.toggle?(key)
#       ��갴���Ĵ���״̬(�ڿ��͹�֮���л�)
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_toggle(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE key){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.scroll
#       ���������ֵĹ���ֵ.��ֵ��ʾ��ǰ,��ֵ��ʾ���,���ʾδ��������
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_scroll(RGSS3Runtime::VALUE obj){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.move?
#       �ж�����Ƿ��ƶ�
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_move(RGSS3Runtime::VALUE obj){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.set_pos(x,y)
#       ָ���������,����ƶ���������
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_set_pos(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE x,RGSS3Runtime::VALUE y){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.set_cursor(file)
#       �ı䵱ǰ���Ĺ����ʽ.����fileΪ����ļ���(·��������ģ��ָ��)
#       �������Ϊnil����ָ������ļ������ڵ�,�����ش���,����겻�ɼ�
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_set_cursor(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE mouse){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.sys_cursor
#       ��ԭ��ϵͳĬ�Ϲ��
*/
RGSS3Runtime::VALUE RUBYCALL RGSSMouse::dm_sys_cursor(RGSS3Runtime::VALUE obj){
	return RGSS3Runtime::Qnil;
}
/*
#     Mouse.clip(x,y,width,height)
#       �����������ָ������Χ��
#       ʡ�Բ���ʱ,����������
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
RGSSMouse::RGSSMouse(RGSS3Runtime *_runtime,GamePlayer * _gameplayer):AbstractRGSSExtension(_runtime,_gameplayer)
{
	DBLCTIME =   GetDoubleClickTime()*60.0/1000.0;
	SetupWndHook((WNDPROC)MouseWndProcHook);
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


RGSSMouse::~RGSSMouse(void)
{
}
RGSSMouse *cRGSSMouse;