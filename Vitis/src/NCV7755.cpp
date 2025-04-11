/*
 * NCV7755.cpp
 *
 *  Created on: Feb 27, 2025
 *      Author: edgelyj
 */

#include "NCV7755.h"

static const uint8_t readCommandStartBits = 0x40;
static const uint8_t readCommandEndBits = 0x02;
static const uint8_t writeCommandStartBits = 0x80;

// CONSTRUCTOR BEGIN
NCV7755::NCV7755()
{
}
NCV7755::NCV7755(GPIO_PINNUM_t csGpio)
{
	cs = csGpio;
}
// CONSTRUCTOR END

// PRIVATE METHOD BEGIN
void NCV7755::Write(uint8_t *command)
{
	SpiSetPrescale(SPI_MHz5);
	// Set the SPI mode to... take a guess
	SpiSetMode(SPI_MODE1);
	// Set alignment to MSB
	SpiSetAlignment(SPI_MSB);
	// Pull CS line low
	GPIO_PinSet(cs, GPIO_PIN_RESET);
	// Write the command
	SpiWrite(command, 2);
	// Pull CS line high
	GPIO_PinSet(cs, GPIO_PIN_SET);
}
void NCV7755::ReadRegister(uint8_t *command, uint8_t *result)
{
	SpiSetPrescale(SPI_MHz5);
	// Set the SPI mode to... take a guess
	SpiSetMode(SPI_MODE1);
	// Set alignment to MSB
	SpiSetAlignment(SPI_MSB);
	// Pull the CS line low
	GPIO_PinSet(cs, GPIO_PIN_RESET);
	// First command will tell the chip what register to load. Disregard outputs.
	SpiWrite(command, 2);
	// Second command will write the same command, but we will read the register contents
	SpiReadWrite(command, result, 2);
	// Pull the CS line high
	GPIO_PinSet(cs, GPIO_PIN_SET);
}
// PRIVATE METHOD END

// PUBLIC METHOD BEGIN
void NCV7755::SetHardwareControl(bool activeMode, bool spiReset)
{
	uint8_t command[2] = {(uint8_t)(0x80 + RegMap.HWCR), (uint8_t)((activeMode << 7) + (spiReset << 6) + 0x00)};
	Write(command);
}
void NCV7755::SetOutput(uint8_t &channels)
{
	uint8_t command[2] = {(uint8_t)(0x80 + RegMap.OUT), channels};
	activeChannels = channels;
	Write(command);
}
void NCV7755::SetBulbInrush(uint8_t &channels)
{
	uint8_t command[2] = {(uint8_t)(0x80 + RegMap.BulbInrush), channels};
	Write(command);
}
void NCV7755::SetOpenLoadDiagCurrent(uint8_t &channels)
{
	uint8_t command[2] = {(uint8_t)(0x80 + RegMap.DIAG_IOL), channels};
	Write(command);
}
void NCV7755::SetOpenLoadDiagControl(uint8_t &channels)
{
	uint8_t command[2] = {(uint8_t)(0x80 + RegMap.DIAG_OLONEN), channels};
	Write(command);
}
void NCV7755::SetInputMap0(uint8_t &channels)
{
	uint8_t command[2] = {(uint8_t)(0x80 + RegMap.MAPIN_0), channels};
	Write(command);
}
void NCV7755::SetInputMap1(uint8_t &channels)
{
	uint8_t command[2] = {(uint8_t)(0x80 + RegMap.MAPIN_1), channels};
	Write(command);
}

void NCV7755::SetPWM0Config(uint8_t internalClock, uint8_t dutyCycle)
{
	uint8_t command[2] = {(uint8_t)(0x80 + (RegMap.PWM_CR0 << 2) + (internalClock & 0x3)), dutyCycle};
	Write(command);
}
void NCV7755::SetPWM1Config(uint8_t internalClock, uint8_t dutyCycle)
{
	uint8_t command[2] = {(uint8_t)(0x80 + (RegMap.PWM_CR1 << 2) + (internalClock & 0x3)), dutyCycle};
	Write(command);
}
void NCV7755::SetPWMFrequency(uint8_t &prescale)
{
	uint8_t command[2] = {(uint8_t)(0x80 + RegMap.HWCR_PWM), prescale};
	Write(command);
}

void NCV7755::SetPWMConnection(uint8_t &channels)
{
	uint8_t command[2] = {(uint8_t)(0x80 + RegMap.PWM_OUT), channels};
	Write(command);
}

void NCV7755::SetPWMMapping(uint8_t &channels)
{
	uint8_t command[2] = {(uint8_t)(0x80 + RegMap.PWM_MAP), channels};
	Write(command);
}
/*
void NCV7755::ClearOutputLatchBits(uint8_t &channels)
{
	uint8_t *command = (uint8_t*)(writeCommandStartBits | RegMap.);
	*(command + 1) = channels;
	Write(command);
}
*/
void NCV7755::SetOutput(DrainChannel channel, bool enabled)
{
	uint8_t *command = (uint8_t*)(readCommandStartBits | RegMap.OUT);
	if (enabled)
	{
		activeChannels |= channel;
	}
	else
	{
		activeChannels &= ~(channel);
	}
	*(command + 1) = activeChannels;
	Write(command);
}
void NCV7755::GetOutput(uint8_t &channels)
{
	uint8_t *dataRx = 0;
	//uint16_t dataTx = (readCommand << 14 | RegMap.OUT << 8 | 0x00);
	uint8_t *dataTx = (uint8_t*)(readCommandStartBits << 6 | RegMap.OUT);
	*(dataTx + 1) = (readCommandEndBits);
	ReadRegister(dataTx, dataRx);
	channels = *(dataRx + 1);
}

void NCV7755::__RAW__IO__UNSAFE__WRITE(uint16_t &data)
{
	uint8_t *tx = (uint8_t*)(data & 0x00FF);
	*(tx + 1) = (data >> 8);
	Write(tx);
}
// DECONSTRUCTOR BEGIN
NCV7755::~NCV7755()
{
	// TODO Auto-generated destructor stub
}
// DECONSTRUCTOR END
