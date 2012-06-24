#pragma once
#include "abstractrgssextension.h"

class RGSSUtilty :
	public AbstractRGSSExtension
{
public:
	RGSSUtilty(void);
	~RGSSUtilty(void);
	static RGSS3Runtime* runtime;
	static void Install(RGSS3Runtime *runtime);
	static DWORD RGSSUtilty::rbx_addtest(int argc, int *argv);
	static DWORD RGSSUtilty::rbx_define_module_function(int argc, int *argv, DWORD obj);
};

