/*
 * I2C_HAL.c
 *
 *  Created on: Feb 28, 2025
 *      Author: edgelyj
 */

#include "I2C_HAL.h"
#include "sleep.h"
#include <stdio.h>

const uint16_t TIMEOUT_US = 300;
const uint32_t FPGA_CLOCK_HZ = 100000000;

const I2C_FREQUENCY_t I2C_KHz100 = (FPGA_CLOCK_HZ / (4 * 100000)) - 1;
const I2C_FREQUENCY_t I2C_KHz400 = (FPGA_CLOCK_HZ / (4 * 400000)) - 1;
const I2C_FREQUENCY_t I2C_MHz1   = (FPGA_CLOCK_HZ / (4 * 1000000)) - 1;
const I2C_FREQUENCY_t I2C_MHz3P4 = (FPGA_CLOCK_HZ / (4 * 3400000)) - 1;

const I2C_STATUS_t I2C_SUCCESS  = 0;
const I2C_STATUS_t I2C_TIMEOUT  = 1;
const I2C_STATUS_t I2C_BAD_ADDR = 2;
const I2C_STATUS_t I2C_BAD_LENGTH = 3;

typedef struct
{
	uint32_t Reset 		 : 1;
	uint32_t Start 		 : 1;
	uint32_t Stop  	     : 1;
	uint32_t ForceClk    : 1;
	uint32_t TenBitAddr  : 1;
	const uint32_t RSRVD : 3;
	uint32_t ReadWrite   : 1;
	uint32_t PeriphAddr  : 7;
	uint32_t TxBuffer	 : 8;
	uint32_t Prescale    : 8;
} I2C_i_t;

typedef struct
{
	uint32_t RxBuffer	 : 8;
	uint32_t Busy		 : 1;
	uint32_t Loading	 : 1;
	uint32_t NACK		 : 1;
	uint32_t Starting	 : 1;
	uint32_t currState   : 3;
	uint32_t nextState   : 3;
} I2C_o_t;

static volatile I2C_i_t* I2C_i = (I2C_i_t*)(I2C_i_ADDR);
static volatile I2C_o_t* I2C_o = (I2C_o_t*)(I2C_i_ADDR + 0x8);

static volatile inline void _I2CSetAddr(uint8_t *periphAddr)
{
	I2C_i->PeriphAddr = *periphAddr;
}
static volatile inline void _I2CSetData(uint8_t *data)
{
	I2C_i->PeriphAddr = *data;
}
volatile void I2CInit()
{
	I2C_i->Reset = 0;
	I2C_i->Start = 0;
	I2C_i->Stop = 0;
	I2C_i->PeriphAddr = 0;
	I2C_i->ReadWrite = 0;
	I2C_i->TenBitAddr = 0;
	I2C_i->ForceClk = 0;
	I2C_i->Prescale = I2C_KHz100;
	I2C_i->TxBuffer = 0;
	for (int i = 0; i < 25; i++)
	{

	}

	I2C_i->Reset = 1;
}
volatile void I2CReset()
{
	for (int i = 0; i < 25; i++)
	{
		I2C_i->Reset = 0;
	}
	I2C_i->Reset = 1;
}
volatile void I2CSetFrequency(I2C_FREQUENCY_t frequency)
{
	I2C_i->Prescale = frequency;
}
volatile void I2CSetPrescale(uint8_t *prescale)
{
	I2C_i->Prescale = *prescale;
}
volatile uint8_t I2CBusy()
{
	return I2C_o->Busy;
}
volatile void I2CReadBuffer(uint8_t *data)
{
	*data = I2C_o->RxBuffer;
}
volatile void I2CAttemptToClearLine()
{
	for (int i = 0; i < 65535; i++)
	{
		I2C_i->ForceClk = 1;
	}
	I2C_i->ForceClk = 0;
}

volatile I2C_STATUS_t I2CDEBUGWRITE(uint8_t *periphAddr, uint8_t *data, uint8_t len)
{
	if (*periphAddr & (1 << 8))
	{
		return I2C_BAD_ADDR;
	}
	else if (len == 0)
	{
		return I2C_BAD_LENGTH;
	}

	uint8_t lastBitVal = 0;
	uint8_t currentBitVal = 0;
	uint8_t byteCounter = 0;
	clock_t startTime = clock();

	_I2CSetAddr(periphAddr); // Load periphAddr
	I2C_i->ReadWrite = 0;
	_I2CSetData(data);    	// Update txBuffer
	I2C_i->Start = 1;

	printf("Current state: %d, next state: %d \n", I2C_o->currState, I2C_o->nextState);

	while (!(I2C_o->Busy)) {} // Wait until busy bit is high

	printf("Current state: %d, next state: %d \n", I2C_o->currState, I2C_o->nextState);

	I2C_i->Start = 0;

	printf("Current state: %d, next state: %d \n", I2C_o->currState, I2C_o->nextState);

	while (TIMEOUT_US > clock() - startTime)
	{
		printf("Current state: %d, next state: %d \n", I2C_o->currState, I2C_o->nextState);
		lastBitVal = currentBitVal;
		currentBitVal = I2C_o->Loading;
		if (currentBitVal == 1 && lastBitVal == 0)
		{
			_I2CSetData((data + byteCounter));
			byteCounter++;
		}
		if (currentBitVal == 0 && lastBitVal == 0 && byteCounter == len)
		{
			break;
		}
	}

	if (TIMEOUT_US > clock() - startTime)
	{
		return I2C_TIMEOUT;
	}
	else
	{
		I2C_i->Stop = 1;

		while (I2C_o->Busy) {} // Wait for transaction to end (busy bit is low)

		I2C_i->Stop = 0;

		return I2C_SUCCESS;
	}
}

volatile I2C_STATUS_t I2CWrite(uint8_t *periphAddr, uint8_t *data, uint8_t len)
{
	if (*periphAddr & (1 << 8))
	{
		return I2C_BAD_ADDR;
	}
	else if (len == 0)
	{
		return I2C_BAD_LENGTH;
	}

	uint8_t lastBitVal = 0;
	uint8_t currentBitVal = 0;
	uint8_t byteCounter = 0;
	clock_t startTime = clock();

	_I2CSetAddr(periphAddr); // Load periphAddr
	I2C_i->ReadWrite = 0;
	_I2CSetData(data);    	// Update txBuffer
	I2C_i->Start = 1;

	while (!(I2C_o->Busy)) {} // Wait until busy bit is high

	I2C_i->Start = 0;

	while (TIMEOUT_US > clock() - startTime)
	{
		lastBitVal = currentBitVal;
		currentBitVal = I2C_o->Loading;
		if (currentBitVal == 1 && lastBitVal == 0)
		{
			_I2CSetData((data + byteCounter));
			byteCounter++;
		}
		if (currentBitVal == 0 && lastBitVal == 0 && byteCounter == len)
		{
			break;
		}
	}

	if (TIMEOUT_US > clock() - startTime)
	{
		return I2C_TIMEOUT;
	}
	else
	{
		I2C_i->Stop = 1;

		while (I2C_o->Busy) {} // Wait for transaction to end (busy bit is low)

		I2C_i->Stop = 0;

		return I2C_SUCCESS;
	}
}
volatile I2C_STATUS_t I2CRead(uint8_t *periphAddr, uint8_t *data, uint8_t len)
{
	if (*periphAddr & (1 << 8))
	{
		return I2C_BAD_ADDR;
	}

	_I2CSetAddr(periphAddr);

	uint8_t lastBitVal = 0;
	uint8_t currentBitVal = 0;
	uint8_t byteCounter = 0;
	clock_t startTime = clock();

	while (TIMEOUT_US > clock() - startTime)
	{
		lastBitVal = currentBitVal;
		currentBitVal = I2C_o->Loading;
		if (currentBitVal == 1 && lastBitVal == 0)
		{
			*(data + byteCounter) = I2C_o->RxBuffer;
			byteCounter++;
		}
		if (currentBitVal == 0 && lastBitVal == 0 && byteCounter == len)
		{
			break;
		}
	}

	if (TIMEOUT_US > clock() - startTime)
	{
		return I2C_TIMEOUT;
	}
	else
	{
		I2C_i->Stop = 1;

		while (I2C_o->Busy) {} // Wait for transaction to end (busy bit is low)

		I2C_i->Stop = 0;

		return I2C_SUCCESS;
	}
}
volatile I2C_STATUS_t I2CWriteReg(uint8_t *periphAddr, uint8_t *regAddr, uint8_t regLen, uint8_t *data, uint8_t len)
{
	if (*periphAddr & (1 << 8))
	{
		return I2C_BAD_ADDR;
	}
	else if (len == 0)
	{
		return I2C_BAD_LENGTH;
	}

	return I2C_TIMEOUT;
}
volatile I2C_STATUS_t I2CReadReg(uint8_t *periphAddr, uint8_t *regAddr, uint8_t regLen, uint8_t *data, uint8_t len)
{
	if (*periphAddr & (1 << 8))
	{
		return I2C_BAD_ADDR;
	}
	else if (len == 0)
	{
		return I2C_BAD_LENGTH;
	}

	return I2C_TIMEOUT;
}
