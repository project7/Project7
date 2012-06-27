#pragma once
#include "abstractrgssextension.h"

class RGSSUtilty :
	public AbstractRGSSExtension
{
public:
	RGSSUtilty(RGSS3Runtime *_runtime,GamePlayer * _gameplayer);
	~RGSSUtilty(void);
};

