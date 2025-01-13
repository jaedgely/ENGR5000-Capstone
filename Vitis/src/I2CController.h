/*
 * I2CController.h
 *
 *  Created on: Jan 4, 2025
 *      Author: Jack Edgely
 */

#ifndef SRC_I2CCONTROLLER_H_
#define SRC_I2CCONTROLLER_H_

#include <stdint.h>

enum SCLFrequency
{
	KHz100 	= 0,
	KHz400 	= 1,	// Is actually 396.826 KHz
	MHz1 	= 2,
	MHz3P4 	= 3,	// Is actually 3.125 MHz
};

// Just add your device to this enum and youre done!
enum Device
{
	Arduino 	= 0x0A,
	STM32F4	 	= 0x32,
	ADI_DAC		= 0x3D,
	INF_DAC		= 0x1F,
	MAX10		= 0x7F	// 0x7F (127) is the max I2C address
};

enum OpCode
{
	Write = 0x0,
	Read = 0x1
};

enum PacketLength
{
	OneByte = 0x0,
	TwoByte = 0x1,
};

class I2CController
{

private:

	typedef struct AXI_GPIO_CONTROL
	{
		bool Reset 				 : 1; // 0
		bool Start 				 : 1; // 1
		OpCode Operation 		 : 1; // 2
		bool Send16BitsData 	 : 1; // 3
		bool SendRegAddress 	 : 1; // 4
		bool Send16BitsReg  	 : 1; // 5
		SCLFrequency Frequency 	 : 2; // 7:6
		bool ForceClock			 : 1; // 8
		uint8_t PeriphAddress    : 7; // 15:9
		uint16_t RegisterAddress : 16; // 31:16
	} AXI_GPIO_CONTROL;

	typedef struct AXI_GPIO_BUFFER
	{
		uint16_t Data : 16;
	} AXI_GPIO_BUFFER;

	typedef struct AXI_GPIO_STATUS
	{
		uint16_t RxBuffer 	: 16;
		bool Busy 		  	: 1;
		bool NACK 			: 1;
	};

	volatile AXI_GPIO_CONTROL *CONTROL;
	volatile AXI_GPIO_BUFFER *TxBuffer;
	volatile AXI_GPIO_STATUS *STATUS;

	void Init();

	bool ReadOperation(Device device, uint8_t &data);
	bool ReadOperation(Device device, uint16_t &data);
	bool WriteOperation(Device device, uint8_t &data);
	bool WriteOperation(Device device, uint16_t &data);

	bool StartOperation();

public:
	I2CController();

	I2CController(uint32_t baseAddressControl, uint32_t baseAddressTxBuffer, uint32_t baseAddressStatus);

	// Enables the device
	void Enable();

	// Disables the device
	void Disable();

	// Forces I2C_SCL active in an attempt to clear the bus
	void AttemptToClearBus();

	// Sets I2C_SCL frequency
	void SetFrequency(SCLFrequency frequency);

	// Write 8 methods with no register, 8 bit register, or 16 bit register
	void Write8(Device device, uint8_t data);
	void Write8(Device device, uint8_t registerAddress, uint8_t data);
	void Write8(Device device, uint16_t registerAddress, uint8_t data);

	// Write 16 methods with no register, 8 bit register, or 16 bit register
	void Write16(Device device, uint16_t data);
	void Write16(Device device, uint8_t registerAddress, uint16_t data);
	void Write16(Device device, uint16_t registerAddress, uint16_t data);

	// Read 8 methods with no register, 8 bit register, or 16 bit register
	bool Read8(Device device, uint8_t &data);
	bool Read8(Device device, uint8_t registerAddress, uint8_t &data);
	bool Read8(Device device, uint16_t registerAddress, uint8_t &data);

	// Read 16 methods with no register, 8 bit register, or 16 bit register
	bool Read16(Device device, uint16_t &data);
	bool Read16(Device device, uint8_t registerAddress, uint16_t &data);
	bool Read16(Device device, uint16_t registerAddress, uint16_t &data);

	// Status bits
	bool NACKAsserted();
	bool IsBusy();

	uint16_t ReadRxBuffer();

	virtual ~I2CController();
};

#endif /* SRC_I2CCONTROLLER_H_ */
