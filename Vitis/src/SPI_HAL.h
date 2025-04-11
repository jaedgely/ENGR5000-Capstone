/*
 * SPI_HAL.h
 *
 *  Created on: Feb 24, 2025
 *      Author: edgelyj
 */

#ifndef SRC_SPI_HAL_H_
#define SRC_SPI_HAL_H_

#include <stdint.h>
#include <iostream>

#define SPI_AXI_ADDR	0x41230000

typedef uint8_t SPI_MODE_t;
typedef uint8_t SPI_STATUS_t;
typedef uint8_t SPI_PRESCALE_t;
typedef uint8_t SPI_BIT_ALIGNMENT_t;

const extern SPI_MODE_t SPI_MODE0;
const extern SPI_MODE_t SPI_MODE1;
const extern SPI_MODE_t SPI_MODE2;
const extern SPI_MODE_t SPI_MODE3;

const extern SPI_STATUS_t SPI_OK;
const extern SPI_STATUS_t SPI_BUSY;
const extern SPI_STATUS_t SPI_STARTING;
const extern SPI_STATUS_t SPI_TIMEOUT;
const extern SPI_STATUS_t SPI_INVALID_LENGTH;

const extern SPI_PRESCALE_t SPI_MHz50;
const extern SPI_PRESCALE_t SPI_MHz25;
const extern SPI_PRESCALE_t SPI_MHz12p5;
const extern SPI_PRESCALE_t SPI_MHz10;
const extern SPI_PRESCALE_t SPI_MHz6p25;
const extern SPI_PRESCALE_t SPI_MHz5;
const extern SPI_PRESCALE_t SPI_MHz2p5;
const extern SPI_PRESCALE_t SPI_MHz1;
const extern SPI_PRESCALE_t SPI_KHz500;

const extern SPI_BIT_ALIGNMENT_t SPI_LSB;
const extern SPI_BIT_ALIGNMENT_t SPI_MSB;

volatile void SpiInit();
volatile void SpiReset();
volatile void SpiSetAlignment(SPI_BIT_ALIGNMENT_t alignment);
volatile void SpiSetMode(SPI_MODE_t mode);
volatile void SpiSetPrescale(uint8_t prescale); // Freq[SPI] = Freq[FPGA] / (prescale + 1)
volatile SPI_STATUS_t SpiWrite(uint8_t *data, uint8_t length);
volatile SPI_STATUS_t SpiReadWrite(uint8_t *dataTx, uint8_t *dataRx, uint8_t length);
volatile uint8_t SpiIsBusy();
volatile uint8_t SpiIsStarting();
volatile void SpiReadBuffer(uint8_t *rxBuffer);


#endif /* SRC_SPI_HAL_H_ */
