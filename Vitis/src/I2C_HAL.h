/*
 * I2C_HAL.h
 *
 *  Created on: Feb 28, 2025
 *      Author: edgelyj
 */

#ifndef SRC_I2C_HAL_H_
#define SRC_I2C_HAL_H_

#include <stdint.h>
#include <time.h>

#define I2C_i_ADDR 0x412020000

const extern uint16_t I2C_TIMEOUT_US;
const extern uint32_t I2C_FPGA_CLOCK_HZ;

typedef uint8_t I2C_FREQUENCY_t;
const extern I2C_FREQUENCY_t I2C_KHz100;
const extern I2C_FREQUENCY_t I2C_KHz400;
const extern I2C_FREQUENCY_t I2C_MHz1;
const extern I2C_FREQUENCY_t I2C_MHz3P4;

typedef uint8_t I2C_STATUS_t;
const extern I2C_STATUS_t I2C_SUCCESS;
const extern I2C_STATUS_t I2C_TIMEOUT;
const extern I2C_STATUS_t I2C_BAD_ADDR;
const extern I2C_STATUS_t I2C_BAD_LENGTH;

volatile void I2CInit();
volatile void I2CReset();
volatile void I2CSetFrequency(I2C_FREQUENCY_t frequency);
volatile void I2CSetPrescale(uint8_t *prescale);
volatile uint8_t I2CBusy();
volatile void I2CReadBuffer(uint8_t *data);
volatile void I2CAttemptToClearLine();

volatile I2C_STATUS_t I2CDEBUGWRITE(uint8_t *periphAddr, uint8_t *data, uint8_t len);
volatile I2C_STATUS_t I2CWrite(uint8_t *periphAddr, uint8_t *data, uint8_t len);
volatile I2C_STATUS_t I2CRead(uint8_t *periphAddr, uint8_t *data, uint8_t len);
volatile I2C_STATUS_t I2CWriteReg(uint8_t *periphAddr, uint8_t *regAddr, uint8_t regLen, uint8_t *data, uint8_t len);
volatile I2C_STATUS_t I2CReadReg(uint8_t *periphAddr, uint8_t *regAddr, uint8_t regLen, uint8_t *data, uint8_t len);

#endif /* SRC_I2C_HAL_H_ */
