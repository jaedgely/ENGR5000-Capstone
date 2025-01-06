/*
 * XADC.h
 *
 *  Created on: Jan 5, 2025
 *      Author: Jack Edgely
 */

#ifndef SRC_XILINXADC_H_
#define SRC_XILINXADC_H_

#include <stdint.h>

enum ADCChannel
{
	Channel0 = 0x0,
	Channel1 = 0x1,
	Channel2 = 0x2,
	Channel3 = 0x3,
	Channel4 = 0x4,
	Channel5 = 0x5
};

class XADC
{
private:
	// Some XADC Config stuff that you hide from the user

public:
	XADC();
	float ReadVoltage(ADCChannel channel);
	uint16_t ReadBits(ADCChannel channel);
	virtual ~XADC();
};

#endif /* SRC_XILINXADC_H_ */
