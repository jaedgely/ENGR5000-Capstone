/*
 * ADC_HAL.c
 *
 *  Created on: Mar 16, 2025
 *      Author: edgelyj
 */
#include "ADC_HAL.h"

const XADC_CHANNEL_t XADC_CH0 = 0x0;
const XADC_CHANNEL_t XADC_CH1 = 0x1;
const XADC_CHANNEL_t XADC_CH2 = 0x2;
const XADC_CHANNEL_t XADC_CH3 = 0x3;
const XADC_CHANNEL_t XADC_CH4 = 0x4;
const XADC_CHANNEL_t XADC_CH5 = 0x5;

static XAdcPs XAdcInst;

static char ChannelMap[6] = {1, 9, 6, 15, 5, 13};

void XADCInit()
{
	XAdcPs_Config *ConfigPtr;
	ConfigPtr = XAdcPs_LookupConfig(XPAR_PS7_XADC_0_DEVICE_ID);
	XAdcPs_CfgInitialize(&XAdcInst, ConfigPtr, ConfigPtr->BaseAddress);
	XAdcPs_SetSequencerMode(&XAdcInst, XADCPS_SEQ_MODE_CONTINPASS);
}
volatile float XADCReadVoltage(XADC_CHANNEL_t channel)
{
	float voltage = 3.3 * XADCRead(channel);
	return voltage / (1 << 16);
}
volatile uint16_t XADCRead(XADC_CHANNEL_t channel)
{
	return XAdcPs_GetAdcData(&XAdcInst, XADCPS_CH_AUX_MIN + ChannelMap[channel]);
}
