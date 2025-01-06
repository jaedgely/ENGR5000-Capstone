/*
 * SPIController.h
 *
 *  Created on: Dec 23, 2025
 *      Author: Jack Edgely
 */

#ifndef SRC_SPICONTROLLER_H_
#define SRC_SPICONTROLLER_H_

#include "xgpio.h"
#include "xparameters.h"
#include <stdint.h>

enum ClockFrequency
{
	//MHz50 = 0x0,
	MHz25 = 0x1,
	MHz12P5 = 0x2,
	MHz6P25 = 0x3,
	MHz3P125 = 0x4,
	MHz1P5625 = 0x5,
	KHz781 = 0x6,
	KHz390 = 0x7
};

enum Mode
{
	Mode0 = 0x0,
	Mode1 = 0x1,
	Mode2 = 0x2,
	Mode3 = 0x3
};


enum ChipSelect
{
	Idle 	= 0xFF,	// 1 1 1 1 1 1 1 1
	Device0 = 0xFE,	// 1 1 1 1 1 1 1 0
	Device1 = 0xFD, // 1 1 1 1 1 1 0 1
	Device2 = 0xFB, // 1 1 1 1 1 0 1 1
	Device3 = 0xF7, // 1 1 1 1 0 1 1 1
	Device4 = 0xEF, // 1 1 1 0 1 1 1 1
	Device5 = 0xDF, // 1 1 0 1 1 1 1 1
	Device6 = 0xBF, // 1 0 1 1 1 1 1 1
	Device7 = 0x7F, // 0 1 1 1 1 1 1 1
};

/*  TODO
 * 		Implement some sort of timeout to escape the read/write commands if the thing is locked up
 */

class SpiController
{
private:

	typedef struct
	{
		// AXI 0 CHANNEL 0
		uint32_t Reset 				: 1;	// 0 resets device, 1 enables it (enable doesnt mean it will send data);
		Mode SPIMode 				: 2;	// Operation mode. Read following: https://www.analog.com/en/resources/analog-dialogue/articles/introduction-to-spi-interface.html
		ClockFrequency Frequency 	: 3;	// Operation frequency
		uint32_t Padding			: 2;
		ChipSelect	CS				: 8;
		const uint16_t INTERNAL_RESERVE_0 : 16;
		const uint32_t AXI_0_RESERVED_0 	: 32;	// Reserved Area

		// AXI 0 CHANNEL 1
		uint32_t TxBuffer 			: 32;	// TX Data buffer. Whatever is written here is what is written over SPI.
		const uint32_t AXI_0_RESERVED_1   : 32; 	// Reserved Area
	} AXI_GPIO_IN;

	typedef struct
	{
		// AXI 1 CHANNEL 0
		uint64_t Busy : 1;					// Status bit for uC
		const uint64_t AXI_RESERVED_0 : 63;

		// AXI 1 CHANNEL 1;
		uint32_t RxBuffer : 32;				// RX Data buffer
		const uint32_t AXI_RESERVED_1 : 32;
	} AXI_GPIO_OUT;

	volatile AXI_GPIO_IN *AXI_IN;
	volatile AXI_GPIO_OUT *AXI_OUT;

	void Init();
public:

	SpiController(uint32_t BaseAddressInputs, uint32_t BaseAddressOutputs);

	void Enable();
	void Disable();

	void SetMode(Mode mode);
	void SetFrequency(ClockFrequency speed);

	Mode GetMode();
	ClockFrequency GetFrequency();

	bool IsBusy();

	void WriteBuffer(uint32_t data);
	void WriteTarget(ChipSelect target);
	void Write(uint32_t data, ChipSelect target);

	uint32_t ReadBuffer();

	virtual ~SpiController();
};
#endif /* SRC_SPICONTROLLER_H_ */
