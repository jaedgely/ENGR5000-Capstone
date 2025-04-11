/*
 * main.cpp
 *
 *  Created on: Feb 27, 2025
 *      Author: edgelyj
 */

#include "NCV7755.h"
#include "I2C_HAL.h"
#include "SPI_HAL.h"
#include "ADC_HAL.h"
#include "RGB_HAL.h"
#include "LED_HAL.h"
#include "sleep.h"

#include <string>
using std::string;

int main(void)
{
	SpiInit();
	SpiSetAlignment(SPI_MSB);
	SpiSetPrescale(SPI_MHz10);
	SpiSetMode(SPI_MODE0);
	RGB0Disable();
	RGB1Disable();

	RGB0Enable();
	RGB1Enable();

	RGB0SetHex(0xFF00FF);
	RGB1SetHex(0x00FF00);

	RGB0Red(0xAB);
	RGB0SetHex(0x000000);
	RGB0Green(0xCD);
	RGB0SetHex(0x000000);
	RGB0Blue(0xEF);

	RGB1Red(0xAB);
	RGB1SetHex(0x000000);
	RGB1Green(0xCD);
	RGB1SetHex(0x000000);
	RGB1Blue(0xEF);

	RGB0SetHex(0x702963);
	RGB1SetHex(0xFFFF00);

	LED0DutyCycle(0.32);
	LED2DutyCycle(0.00);
	LED1DutyCycle(1.00);
	LED3DutyCycle(0.75);

	LED0DutyCycle(0);
	LED1DutyCycle(0);
	LED2DutyCycle(0);
	LED3DutyCycle(0);

	uint8_t testWrite = 0xA7;
	SpiSetPrescale(SPI_MHz10);
	NCV7755 GateDriver(Rpi15);
	uint8_t currentChannels;
	uint8_t clearChannels = 0x00;

	GateDriver.SetHardwareControl(true, false);
	GateDriver.SetOutput(testWrite);
	GateDriver.SetInputMap0(clearChannels);
	GateDriver.SetPWM0Config(2, 233);
	GateDriver.GetOutput(currentChannels);

	XADCInit();
	usleep(100);

	while (!false)
	{
		uint8_t hexCode = 0;
		float analogVolt = 0;
		for (int i = 0; i < 6; i++)
		{
			analogVolt = XADCReadVoltage((XADC_CHANNEL_t)i);
			hexCode = (255 * analogVolt) / 3.3;
			switch (i)
			{
			case 0:	RGB0Red(hexCode); break;
			case 1:	RGB0Green(hexCode); break;
			case 2: RGB0Blue(hexCode); break;
			case 3: RGB1Red(hexCode); break;
			case 4: RGB1Green(hexCode); break;
			case 5: RGB1Blue(hexCode); break;
			default:RGB0Red(hexCode); break;
			}
		}
	}
}
