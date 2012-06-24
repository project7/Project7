#include "RGSSUtilty.h"


RGSSUtilty::RGSSUtilty(void)
{
}


RGSSUtilty::~RGSSUtilty(void)
{
}


DWORD RGSSUtilty::rbx_addtest(int argc, int *argv){
	return argv[0] + argv[1] - 1;
}

DWORD RGSSUtilty::rbx_define_module_function(int argc, int *argv, DWORD obj){

	char s[1024];
	runtime->rb_define_module_function( argv[0], *(const char **)(argv[1] + runtime->rofs), (DWORD(*)(...))((argv[2]^1)>>1), (argv[3]^1)>>1);
	return 2;
}

RGSS3Runtime* RGSSUtilty::runtime = 0;

void RGSSUtilty::Install(RGSS3Runtime *r)
{
	runtime = r;
	runtime->rb_define_module_function(runtime->rbx, "add", (DWORD(*)(...))rbx_addtest, -1);
	runtime->rb_define_module_function(runtime->rbx, "defun", (DWORD(*)(...))rbx_define_module_function, -1);
}