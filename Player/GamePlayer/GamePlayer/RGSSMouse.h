#pragma once
#include "abstractrgssextension.h"
#include "RGSS3Runtime.h"

class RGSSMouse :
	public AbstractRGSSExtension
{
public:
	RGSSMouse(void);
	~RGSSMouse(void);

	static void Install(RGSS3Runtime *runtime);
};

