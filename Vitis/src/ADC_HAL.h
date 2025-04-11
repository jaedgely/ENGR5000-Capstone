/*
 * ADC_HAL.h
 *
 *  Created on: Mar 16, 2025
 *      Author: edgelyj
 */

#ifndef SRC_ADC_HAL_H_
#define SRC_ADC_HAL_H_

#include <stdint.h>
#include "xadcps.h"
#include "xparameters.h"
#include "xstatus.h"

typedef uint8_t XADC_CHANNEL_t;
extern const XADC_CHANNEL_t XADC_CH0;
extern const XADC_CHANNEL_t XADC_CH1;
extern const XADC_CHANNEL_t XADC_CH2;
extern const XADC_CHANNEL_t XADC_CH3;
extern const XADC_CHANNEL_t XADC_CH4;
extern const XADC_CHANNEL_t XADC_CH5;

void XADCInit();
volatile float XADCReadVoltage(XADC_CHANNEL_t channel);
volatile uint16_t XADCRead(XADC_CHANNEL_t channel);

#endif /* SRC_ADC_HAL_H_ */
