/*
 * XADC.cpp
 *
 *  Created on: Jan 5, 2025
 *      Author: Jack Edgely
 */

#include "XilinxADC.h"

XADC::XADC()
{
	// Set up the xilinx adc here
}

float XADC::ReadVoltage(ADCChannel channel)
{
	return 3.3 * (this->ReadBits(channel) / 4095);
}

uint16_t XADC::ReadBits(ADCChannel channel)
{
	return 0xAA;
}
XADC::~XADC()
{
	// TODO Auto-generated destructor stub
}

