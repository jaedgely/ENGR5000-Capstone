/*
 * SPIController.cpp
 *
 *  Created on: Dec 31, 2025
 *      Author: Jack Edgely
 */

#include "sleep.h"
#include "SpiController.h"

SpiController::SpiController(uint32_t BaseAddressInputs, uint32_t BaseAddressOutputs)
{
	AXI_IN = (AXI_GPIO_IN*)(BaseAddressInputs);
	AXI_OUT = (AXI_GPIO_OUT*)(BaseAddressOutputs);
	this->Init();
}

void SpiController::Init()
{
	AXI_IN->Reset = 0;
	AXI_IN->CS = Idle;
	AXI_IN->Frequency = MHz25;
	AXI_IN->TxBuffer = 0xDEADCE11; // Yell
	AXI_IN->SPIMode = Mode0;
}

void SpiController::Enable()
{
	AXI_IN->Reset = 1;
}

void SpiController::Disable()
{
	AXI_IN->Reset = 0;
}

bool SpiController::IsBusy()
{
	return AXI_OUT->Busy;
}

void SpiController::SetMode(Mode mode)
{
	AXI_IN->SPIMode = mode;
}

void SpiController::SetFrequency(ClockFrequency frequency)
{
	AXI_IN->Frequency = frequency;
}

Mode SpiController::GetMode()
{
	return AXI_IN->SPIMode;
}

ClockFrequency SpiController::GetFrequency()
{
	return AXI_IN->Frequency;
}

void SpiController::WriteBuffer(uint32_t data)
{
	AXI_IN->TxBuffer = data;

	// DO NOT REMOVE THIS COMMAND OTHERWISE THE WHOLE THING BREAKS.
	// I WISH I WAS JOKING. SERIOUSLY. DON'T REMOVE AND DON'T ASK ME WHY.
	//		 |		  |
	//		 |		  |
	//		 V		  V
	AXI_IN->Reset = AXI_IN->Reset;
}

void SpiController::WriteTarget(ChipSelect target)
{
	// Wait until FPGA reports that the SPI chip is free
	while (AXI_OUT->Busy){}

	// Update chip select
	AXI_IN->CS = target;

	// Wait until FPGA reports that the SPI chip is busy
	while (!AXI_OUT->Busy){}

	// Pull the chip select line high to prevent the FPGA
	// from sending multiple packets
	AXI_IN->CS = Idle;
}

void SpiController::Write(uint32_t data, ChipSelect target)
{
	WriteBuffer(data);
	WriteTarget(target);
}

uint32_t SpiController::ReadBuffer()
{
	// Wait until the FPGA reports that the SPI chip is not busy
	// (AKA transaction ended, latest data received)
	while (AXI_OUT->Busy);

	return AXI_OUT->RxBuffer;
}

SpiController::~SpiController()
{

}
{

}
