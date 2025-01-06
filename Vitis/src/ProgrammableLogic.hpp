/*
 * ProgrammableLogic.h
 *
 *  Created on: Dec 31, 2024
 *      Author: Jack Edgely
 */

#ifndef SRC_PROGRAMMABLELOGIC_H_
#define SRC_PROGRAMMABLELOGIC_H_

#include "SpiController.h"
//#include "XADC.h"

class ProgrammableLogic {

public:
	SpiController *SPI;
	XilinxADC *XADC;
  I2CController *I2C;

	ProgrammableLogic();

	void InitSpi(uint32_t BaseAddressInputs, uint32_t BaseAddressOutputs, Mode mode, ClockFrequency frequency);
	void InitXADC();
  void InitI2C(uint32_t baseAddress);

	virtual ~ProgrammableLogic();
};

#endif /* SRC_PROGRAMMABLELOGIC_H_ */
