#pragma once
#include "AbstractRGSSExtension.h"
class RGSSInput:public AbstractRGSSExtension
{
public:
	RGSSInput(RGSS3Runtime *_runtime,GamePlayer * _gameplayer):AbstractRGSSExtension(_runtime, _gameplayer){};
	~RGSSInput(void);
};

