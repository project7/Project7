#pragma once
#include "RGSS3Runtime.h"
class AbstractRGSSExtension
{
public:
	AbstractRGSSExtension(void);
	~AbstractRGSSExtension(void);

	static void Install(RGSS3Runtime runtime);
};

