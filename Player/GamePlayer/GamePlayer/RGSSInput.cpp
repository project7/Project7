#include "RGSSInput.h"
RGSS3Runtime::VALUE RGSSInput::mCInput;
int RGSSInput::pos;
map<long,bool> RGSSInput::keydown;
map<long,bool> RGSSInput::keyup;
map<long,bool> RGSSInput::keypress;
void RGSSInput::InitRuby()
{
	mCInput = sruntime->rb_define_module("CInput");
	runtime->rb_define_module_function(mCInput,"down?",(RGSS3Runtime::RubyFunc)dm_keydown,1);
	runtime->rb_define_module_function(mCInput,"up?",(RGSS3Runtime::RubyFunc)dm_keyup,1);
	runtime->rb_define_module_function(mCInput,"press?",(RGSS3Runtime::RubyFunc)dm_keypress,1);
	runtime->rb_define_module_function(mCInput,"getall",(RGSS3Runtime::RubyFunc)dm_getall,0);
	runtime->rb_define_module_function(mCInput,"update",(RGSS3Runtime::RubyFunc)dm_keyupdate,0);
}
bool RGSSInput::Install()
{
	pos = SetupWndHook((WNDPROC)KeyboardWndProcHook);
	return true;
}

#define key(v,vKey) 	sruntime->SafeFixnumValue(vKey);\
	int key = RGSS3Runtime::FIX2INT(vKey);\
	map<long, bool>::iterator iter;\
	iter = v.find(vKey);\
	if (iter==v.end())\
		return RGSS3Runtime::Qfalse;\
	if (v[vKey]==false)\
		return RGSS3Runtime::Qfalse;\
	return RGSS3Runtime::Qtrue;
RGSS3Runtime::VALUE RUBYCALL RGSSInput::dm_keydown(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE vKey)
{
	key(keydown,vKey);
}
RGSS3Runtime::VALUE RUBYCALL RGSSInput::dm_keyup(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE vKey)
{
	key(keyup,vKey);
}
RGSS3Runtime::VALUE RUBYCALL RGSSInput::dm_keypress(RGSS3Runtime::VALUE obj,RGSS3Runtime::VALUE vKey)
{
	key(keypress,vKey);
}
RGSS3Runtime::VALUE RUBYCALL RGSSInput::dm_keyupdate(RGSS3Runtime::VALUE obj)
{
	keydown.clear();
	keyup.clear();
	return RGSS3Runtime::Qnil;
}
#undef key
RGSS3Runtime::VALUE RUBYCALL RGSSInput::dm_getall(RGSS3Runtime::VALUE obj)
{
	map<long, bool>::iterator iter;
	RGSS3Runtime::VALUE ary = sruntime->rb_ary_new();
	RGSS3Runtime::VALUE aryup = sruntime->rb_ary_new();
	RGSS3Runtime::VALUE arydown = sruntime->rb_ary_new();
	RGSS3Runtime::VALUE arypress = sruntime->rb_ary_new();
#define arypush(v,myarray) 	for (iter=v.begin();iter!=v.end();iter++) 	if (iter->second==true)	sruntime->rb_ary_push(myarray,sruntime->INT2FIX(iter->first));
	arypush(keyup,aryup);
	arypush(keydown,arydown);
	arypush(keypress,arypress);
	sruntime->rb_ary_push(ary,aryup);
	sruntime->rb_ary_push(ary,arydown);
	sruntime->rb_ary_push(ary,arypress);
	return ary;
}
#ifdef HookerTest
extern FILE *LOG;
#endif
LRESULT WINAPI RGSSInput::KeyboardWndProcHook(HWND hWnd,UINT Msg,WPARAM wParam,LPARAM IParam)
{
	#ifdef HookerTest
	fprintf(LOG,"KeyboardWndProcHook:%d\n\r",pos);fflush(LOG);
	#endif
	if (Msg==WM_KEYDOWN)
	{
		keydown[wParam]=true;
		keyup[wParam]=false;
		keypress[wParam]=true;
	}
	if (Msg==WM_KEYUP)
	{
		keyup[wParam]=true;
		keydown[wParam]=false;
		keypress[wParam]=false;
	}
	return CallNext(hWnd,Msg,wParam,IParam,pos);
}
RGSSInput::RGSSInput(void)
{

}
RGSSInput::~RGSSInput(void)
{
}
