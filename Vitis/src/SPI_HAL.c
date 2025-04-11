/*
 * SPI_HAL.c
 *
 *  Created on: Feb 24, 2025
 *      Author: edgelyj
 */

#include "SPI_HAL.h"

/*
typedef struct SPI_i_t
{
	uint8_t Reset 	  : 1;
	uint8_t Start 	  : 1;
	SPI_MODE_t Mode  	  : 2;
	SPI_BIT_ALIGNMENT_t Alignment : 1;
	const uint8_t Res : 3;
	uint8_t Prescale  : 8;
	uint8_t TxBuffer  : 8;
} SPI_i_t;

typedef struct SPI_o_t
{
	const uint8_t Busy     : 1;
	const uint8_t Starting : 1;
	const uint8_t RxBuffer : 8;
} SPI_o_t;
*/
static volatile uint32_t* SPI_i = (uint32_t*)(SPI_AXI_ADDR);
static volatile uint32_t* SPI_o = (uint32_t*)(SPI_AXI_ADDR + 0x8);
//static volatile SPI_i_t* SPI_I_T = (SPI_i_t*)(SPI_AXI_ADDR);
//static volatile SPI_o_t* SPI_O_T = (SPI_o_t*)(SPI_AXI_ADDR + 0x8);

const SPI_MODE_t SPI_MODE0 = 0x0;
const SPI_MODE_t SPI_MODE1 = 0x1;
const SPI_MODE_t SPI_MODE2 = 0x2;
const SPI_MODE_t SPI_MODE3 = 0x3;

const SPI_STATUS_t SPI_OK = 0x0;
const SPI_STATUS_t SPI_BUSY = 0x1;
const SPI_STATUS_t SPI_STARTING = 0x2;
const SPI_STATUS_t SPI_TIMEOUT = 0x3;
const SPI_STATUS_t SPI_INVALID_LENGTH = 0x4;

const SPI_PRESCALE_t SPI_MHz50 = 0;
const SPI_PRESCALE_t SPI_MHz25 = 2;
const SPI_PRESCALE_t SPI_MHz12p5 = 6;
const SPI_PRESCALE_t SPI_MHz10 = 8;
const SPI_PRESCALE_t SPI_MHz6p25 = 14;
const SPI_PRESCALE_t SPI_MHz5 = 18;
const SPI_PRESCALE_t SPI_MHz2p5 = 38;
const SPI_PRESCALE_t SPI_MHz1 = 98;
const SPI_PRESCALE_t SPI_KHz500 = 198;

const SPI_BIT_ALIGNMENT_t SPI_LSB = 0x0;
const SPI_BIT_ALIGNMENT_t SPI_MSB = 0x1;

static inline void invalidType(const char *file, int line)
{
	printf("TYPE CHECKER FAIL: FILE %s, LINE %d", file, line);
}
static inline void SpiBitAlignmentValid(SPI_BIT_ALIGNMENT_t alignment)
{
	if (!(alignment == SPI_LSB || alignment == SPI_MSB))
	{
		invalidType(__FILE__, __LINE__);
	}
}
static inline void SpiModeValid(SPI_MODE_t spiMode)
{
	if (!(spiMode == SPI_MODE0 || spiMode == SPI_MODE1 || spiMode == SPI_MODE2 || spiMode == SPI_MODE3))
	{
		invalidType(__FILE__, __LINE__);
	}
}

volatile void SpiInit()
{
	*SPI_i &= ~(1 << 0);
	*SPI_i &= ~(1 << 1);
	*SPI_i &= ~(SPI_MODE0 << 2);
	*SPI_i &= ~(SPI_MSB << 4);
	*SPI_i &= ~(0xFFFF << 8);
	//SPI_i->Reset = 0;
	//SPI_i->Start = 0;
	//SPI_i->Mode = SPI_MODE0;
	//SPI_i->Alignment = SPI_MSB;
	//SPI_i->Prescale = 0;
	//SPI_i->TxBuffer = 0xFF;
	for (int i = 0; i < 5; i++) {}
	*SPI_i |= (1 << 0);
	//SPI_i->Reset = 1;
}
volatile void SpiReset()
{
	*SPI_i &= ~(1 << 0);
	//SPI_i->Reset = 0;
	for(int i = 0; i < 5; i++) {}
	//SPI_i->Reset = 1;
	*SPI_i &= ~(1 << 1);
	for(int i = 0; i < 5; i++) {}
}
volatile void SpiSetAlignment(SPI_BIT_ALIGNMENT_t alignment)
{
	SpiBitAlignmentValid(alignment);
	if (alignment == SPI_MSB)
	{
		*SPI_i |= (1 << 4);
	}
	else
	{
		*SPI_i &= ~(1 << 4);
	}
}
volatile void SpiSetMode(SPI_MODE_t mode)
{
	SpiModeValid(mode);
	*SPI_i &= ~(0x3 << 2);
	*SPI_i |= (mode << 2);
	//SPI_i->Mode = mode;
}
volatile void SpiSetPrescale(uint8_t prescale)
{
	*SPI_i &= ~(0xFF << 8);
	*SPI_i |= (prescale << 8);
}
volatile SPI_STATUS_t SpiWrite(uint8_t *data, uint8_t length)
{
	if (length == 0)
	{
		return SPI_INVALID_LENGTH;
	}

	for (int i = 0; i < length; i++)
	{
		/*
		SPI_i->TxBuffer = *(data + i);
		while(SPI_o->Busy){}
		SPI_i->Start = 1;
		while(!SPI_o->Busy){}
		SPI_i->Start = 0;
		*/
		*SPI_i &= ~(0xFF << 16);
		*SPI_i |= (*(data + i) << 16);
		while(*SPI_o & (1)){}
		*SPI_i |= (1 << 1);
		while(!(*SPI_o & (1))){}
		*SPI_i &= ~(1 << 1);
	}

	while (*SPI_o & (1)){}
	return SPI_OK;
}
volatile SPI_STATUS_t SpiReadWrite(uint8_t *dataTx, uint8_t *dataRx, uint8_t length)
{
	if (length == 0)
	{
		return SPI_INVALID_LENGTH;
	}
	for (int i = 0; i < length; i++)
	{
		/*
		while(SPI_o->Busy){}
		SPI_i->TxBuffer = *(dataTx + i);
		SPI_i->Start = 1;
		while(!SPI_o->Busy){}
		SPI_i->Start = 0;
		while(SPI_o->Busy){}
		*(dataRx + i) = SPI_o->RxBuffer;
		*/
		*SPI_i &= ~(0xFF << 16);
		*SPI_i |= (*(dataTx + i) << 16);
		while(*SPI_o & 1){}
		*SPI_i |= (1 << 1);
		while(!(*SPI_o & (1))){}
		*SPI_i &= ~(1 << 1);
		while(*SPI_o & 1){}
		*(dataRx + i) = (*SPI_o) >> 2;
	}

	return SPI_OK;
}
volatile uint8_t SpiIsBusy()
{
	return *SPI_o & (1 << 0);
	//return SPI_o->Busy;
}
volatile uint8_t SpiIsStarting()
{
	return *SPI_o * (1 << 1);
	//return SPI_o->Starting;
}
volatile void SpiReadBuffer(uint8_t *rxBuffer)
{
	while(*SPI_o & (1 << 0)){}
	*rxBuffer = (*SPI_o) >> 2;
	/*
	while(SPI_o->Busy){}
	*rxBuffer = SPI_o->RxBuffer;
	*/
}
{

}
