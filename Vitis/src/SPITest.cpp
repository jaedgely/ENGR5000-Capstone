#include "sleep.h"
#include <stdlib.h>
#include <iostream>
#include <stdio.h>
#include "SpiController.h"

#define PL_SPI_INPUT_ADDR 	0x41200000
#define PL_SPI_OUTPUT_ADDR  0x41210000

void TestSPI(SpiController &SPI)
{
	uint32_t sentData;
	uint32_t receivedData = 0;

	sentData = rand();
	SPI.WriteBuffer(sentData);
	SPI.WriteTarget(Device0);
	receivedData = SPI.ReadBuffer();

	if (sentData == receivedData)
	{
		std::cout << "SPI Loopback PASS" << std::endl;
		std::cout << "	SPI Mode: " << SPI.GetMode() << ", Frequency " << SPI.GetFrequency() << std::endl;
		std::cout << "	Sent " << sentData << ", Received " << receivedData << std::endl;
	}
	else
	{
		std::cout << "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" << std::endl;
		std::cout << "SPI Loopback FAIL" << std::endl;
		std::cout << "	SPI Mode: " << SPI.GetMode() << ", Frequency " << SPI.GetFrequency() << std::endl;
		std::cout << "	Sent " << sentData << ", Received " << receivedData << std::endl;
		std::cout << "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" << std::endl;
	}

	usleep(10000);

	sentData = rand();
	SPI.Write(sentData, Device1);
	receivedData = SPI.ReadBuffer();

	if (sentData == receivedData)
	{
		std::cout << "SPI Loopback PASS" << std::endl;
		std::cout << "	SPI Mode: " << SPI.GetMode() << ", Frequency " << SPI.GetFrequency() << std::endl;
		std::cout << "	Sent " << sentData << ", Received " << receivedData << std::endl;
	}
	else
	{
		std::cout << "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" << std::endl;
		std::cout << "SPI Loopback FAIL" << std::endl;
		std::cout << "	SPI Mode: " << SPI.GetMode() << ", Frequency " << SPI.GetFrequency() << std::endl;
		std::cout << "	Sent " << sentData << ", Received " << receivedData << std::endl;
		std::cout << "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" << std::endl;
	}

	usleep(10000);
}

int main(void)
{
	SpiController SPI(0x41200000, 0x41210000);

	SPI.Disable();
	usleep(100);
	SPI.Enable();

	for (int i = 0; i < 4; i++)
	{
		SPI.SetMode((Mode)i);
		for (int j = 0; j < 8; j++)
		{
			SPI.SetFrequency((ClockFrequency)j);
			TestSPI(SPI);
		}
	}

	return 0;
}
