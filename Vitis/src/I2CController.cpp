/*
 * I2CController.cpp
 *
 *  Created on: Jan 4, 2025
 *      Author: Jack Edgely
 */

#include "I2CController.h"

I2CController::I2CController(){}

I2CController::I2CController(uint32_t baseAddressControl, uint32_t baseAddressTxBuffer, uint32_t baseAddressStatus)
{
	CONTROL = (AXI_GPIO_CONTROL*)baseAddressControl;
	TxBuffer = (AXI_GPIO_BUFFER*)baseAddressTxBuffer;
	STATUS = (AXI_GPIO_STATUS*)baseAddressStatus;
	this->Init();
}

void I2CController::Init()
{
	CONTROL->Reset = 0;
	CONTROL->Start = 0;
	CONTROL->ForceClock = 0;
	CONTROL->Frequency = KHz100;
	CONTROL->Send16BitsData = 0;
	CONTROL->Send16BitsReg = 0;
	CONTROL->RegisterAddress = 0xCE11;
	CONTROL->SendRegAddress = 0;
	CONTROL->Operation = Write;
	CONTROL->PeriphAddress = 0x7F;
}

bool I2CController::ReadOperation(Device device, uint8_t &data)
{
	CONTROL->Operation = Read;
	CONTROL->Send16BitsData = 0;
	CONTROL->PeriphAddress = device;
	bool NACK = StartOperation();
	data = STATUS->RxBuffer;
	return NACK;
}

bool I2CController::ReadOperation(Device device, uint16_t &data)
{
	CONTROL->Operation = Read;
	CONTROL->Send16BitsData = 1;
	CONTROL->PeriphAddress = device;
	bool NACK = StartOperation();
	data = STATUS->RxBuffer;
	return NACK;
}

bool I2CController::WriteOperation(Device device, uint8_t &data)
{
	CONTROL->Operation = Write;
	CONTROL->Send16BitsData = 0;
	CONTROL->PeriphAddress = device;
	TxBuffer->Data = (uint16_t)(data << 8);
	return StartOperation();
}

bool I2CController::WriteOperation(Device device, uint16_t &data)
{
	CONTROL->Operation = Write;
	CONTROL->Send16BitsData = 1;
	CONTROL->PeriphAddress = device;
	TxBuffer->Data = data;
	return StartOperation();
}

bool I2CController::StartOperation()
{
	// Wait until the FPGA says that the I2C Controller is free
	while (IsBusy()){}

	// Send the start command
	CONTROL->Start = 1;

	// Wait until the FPGA says that the I2C Controller is busy
	while (IsBusy()){}

	// Retract the start command
	CONTROL->Start = 0;

	// Wait until the FPGA says that the I2C Controller is done
	while (IsBusy()){}

	// Return status bit
	return NACKAsserted();
}

void I2CController::Enable()
{
	CONTROL->Reset = 1;
}

void I2CController::Disable()
{
	CONTROL->Reset = 0;
	CONTROL->Start = 0;
}

void I2CController::AttemptToClearBus()
{
	CONTROL->ForceClock = 1;
	for (int i = 0; i < 50000000; i++) {}
	CONTROL->ForceClock = 0;
}

void I2CController::SetFrequency(SCLFrequency frequency)
{
	CONTROL->Frequency = frequency;
}

void I2CController::Write8(Device device, uint8_t data)
{
	CONTROL->Send16BitsReg = 0;
	CONTROL->SendRegAddress = 0;
	this->WriteOperation(device, data);
}

void I2CController::Write8(Device device, uint8_t registerAddress, uint8_t data)
{
	CONTROL->Send16BitsReg = 0;
	CONTROL->SendRegAddress = 1;
	this->WriteOperation(device, data);
}

void I2CController::Write8(Device device, uint16_t registerAddress, uint8_t data)
{
	CONTROL->Send16BitsReg = 1;
	CONTROL->SendRegAddress = 1;
	this->WriteOperation(device, data);
}

void I2CController::Write16(Device device, uint16_t data)
{
	CONTROL->Send16BitsReg = 0;
	CONTROL->SendRegAddress = 0;
	this->WriteOperation(device, data);
}

void I2CController::Write16(Device device, uint8_t registerAddress, uint16_t data)
{
	CONTROL->Send16BitsReg = 0;
	CONTROL->SendRegAddress = 1;
	this->WriteOperation(device, data);
}

void I2CController::Write16(Device device, uint16_t registerAddress, uint16_t data)
{
	CONTROL->Send16BitsReg = 1;
	CONTROL->SendRegAddress = 1;
	this->WriteOperation(device, data);
}

bool I2CController::Read8(Device device, uint8_t &data)
{
	CONTROL->Send16BitsReg = 0;
	CONTROL->SendRegAddress = 0;
	return this->ReadOperation(device, data);
}

bool I2CController::Read8(Device device, uint8_t registerAddress, uint8_t &data)
{
	CONTROL->Send16BitsReg = 0;
	CONTROL->SendRegAddress = 1;
	return this->ReadOperation(device, data);
}

bool I2CController::Read8(Device device, uint16_t registerAddress, uint8_t &data)
{
	CONTROL->Send16BitsReg = 1;
	CONTROL->SendRegAddress = 1;
	return this->ReadOperation(device, data);
}

bool I2CController::Read16(Device device, uint16_t &data)
{
	CONTROL->Send16BitsReg = 0;
	CONTROL->SendRegAddress = 0;
	return this->ReadOperation(device, data);
}

bool I2CController::Read16(Device device, uint8_t registerAddress, uint16_t &data)
{
	CONTROL->Send16BitsReg = 0;
	CONTROL->SendRegAddress = 1;
	return this->ReadOperation(device, data);
}

bool I2CController::Read16(Device device, uint16_t registerAddress, uint16_t &data)
{
	CONTROL->Send16BitsReg = 1;
	CONTROL->SendRegAddress = 1;
	return this->ReadOperation(device, data);
}

bool I2CController::NACKAsserted()
{
	return STATUS->NACK;
}

bool I2CController::IsBusy()
{
	return STATUS->Busy;
}

uint16_t I2CController::ReadRxBuffer()
{
	return STATUS->RxBuffer;
}

I2CController::~I2CController(){}
