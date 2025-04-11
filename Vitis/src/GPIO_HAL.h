/*
 * GPIO_HAL.h
 *
 *  Created on: Feb 27, 2025
 *      Author: edgelyj
 */

#ifndef SRC_GPIO_HAL_H_
#define SRC_GPIO_HAL_H_
#include <stdint.h>
#define GPIO_TX_ADDR 0x41200008
#define GPIO_RX_ADDR 0x41210000
#define GPIO_3S_ADDR 0x41200000

extern volatile uint32_t *GPIO_TX;
extern volatile uint32_t *GPIO_RX;
extern volatile uint32_t *GPIO_3S;

typedef uint8_t GPIO_PINDRIVE_t;
const extern GPIO_PINDRIVE_t GPIO_PIN_SET;
const extern GPIO_PINDRIVE_t GPIO_PIN_RESET;

typedef uint8_t GPIO_PINMODE_t;
const extern GPIO_PINMODE_t GPIO_PIN_INPUT;
const extern GPIO_PINMODE_t GPIO_PIN_OUTPUT;

typedef uint32_t GPIO_PINNUM_t;
const extern GPIO_PINNUM_t Rpi0;
const extern GPIO_PINNUM_t Rpi1;
const extern GPIO_PINNUM_t Rpi3;
const extern GPIO_PINNUM_t Rpi4;
const extern GPIO_PINNUM_t Rpi5;
const extern GPIO_PINNUM_t Rpi6;
const extern GPIO_PINNUM_t Rpi7;
const extern GPIO_PINNUM_t Rpi8;
const extern GPIO_PINNUM_t Rpi9;
const extern GPIO_PINNUM_t Rpi10;
const extern GPIO_PINNUM_t Rpi11;
const extern GPIO_PINNUM_t Rpi12;
const extern GPIO_PINNUM_t Rpi13;
const extern GPIO_PINNUM_t Rpi14;
const extern GPIO_PINNUM_t Rpi15;
const extern GPIO_PINNUM_t Rpi16;
const extern GPIO_PINNUM_t Rpi17;
const extern GPIO_PINNUM_t Rpi18;
const extern GPIO_PINNUM_t Rpi19;
const extern GPIO_PINNUM_t Rpi20;
const extern GPIO_PINNUM_t Rpi21;
const extern GPIO_PINNUM_t Rpi22;
const extern GPIO_PINNUM_t Rpi23;
const extern GPIO_PINNUM_t Rpi24;
const extern GPIO_PINNUM_t Rpi25;
const extern GPIO_PINNUM_t Rpi26;
const extern GPIO_PINNUM_t Rpi27;
const extern GPIO_PINNUM_t Rpi28;
const extern GPIO_PINNUM_t Rpi29;
const extern GPIO_PINNUM_t Rpi30;
const extern GPIO_PINNUM_t Rpi31;

const extern GPIO_PINNUM_t Ard0;
const extern GPIO_PINNUM_t Ard1;
const extern GPIO_PINNUM_t Ard2;
const extern GPIO_PINNUM_t Ard3;
const extern GPIO_PINNUM_t Ard4;
const extern GPIO_PINNUM_t Ard5;
const extern GPIO_PINNUM_t Ard6;
const extern GPIO_PINNUM_t Ard7;
const extern GPIO_PINNUM_t Ard8;
const extern GPIO_PINNUM_t Ard9;
const extern GPIO_PINNUM_t Ard10;
const extern GPIO_PINNUM_t Ard11;
const extern GPIO_PINNUM_t Ard12;
const extern GPIO_PINNUM_t Ard13;

GPIO_PINDRIVE_t GPIO_PinGet(GPIO_PINNUM_t pin);
void GPIO_PinSet(GPIO_PINNUM_t pin, GPIO_PINDRIVE_t drive);
void GPIO_PinMode(GPIO_PINNUM_t pin, GPIO_PINMODE_t mode);

#endif /* SRC_GPIO_HAL_H_ */
