/*
 * GPIO_HAL.c
 *
 *  Created on: Feb 27, 2025
 *      Author: edgelyj
 */

#include "GPIO_HAL.h"

volatile uint32_t *GPIO_TX = (uint32_t*)GPIO_TX_ADDR;
volatile uint32_t *GPIO_RX = (uint32_t*)GPIO_RX_ADDR;
volatile uint32_t *GPIO_3S = (uint32_t*)GPIO_3S_ADDR;

const GPIO_PINDRIVE_t GPIO_PIN_RESET = 0;
const GPIO_PINDRIVE_t GPIO_PIN_SET = 1;

const GPIO_PINMODE_t GPIO_PIN_OUTPUT = 0;
const GPIO_PINMODE_t GPIO_PIN_INPUT = 1;

const GPIO_PINNUM_t Rpi0 = (1 << 0);
const GPIO_PINNUM_t Rpi1 = (1 << 1);
const GPIO_PINNUM_t Rpi2 = (1 << 2);
const GPIO_PINNUM_t Rpi3 = (1 << 3);
const GPIO_PINNUM_t Rpi4 = (1 << 4);
const GPIO_PINNUM_t Rpi5 = (1 << 5);
const GPIO_PINNUM_t Rpi6 = (1 << 6);
const GPIO_PINNUM_t Rpi7 = (1 << 7);
const GPIO_PINNUM_t Rpi8 = (1 << 8);
const GPIO_PINNUM_t Rpi9 = (1 << 9);
const GPIO_PINNUM_t Rpi10 = (1 << 10);
const GPIO_PINNUM_t Rpi11 = (1 << 11);
const GPIO_PINNUM_t Rpi12 = (1 << 12);
const GPIO_PINNUM_t Rpi13 = (1 << 13);
const GPIO_PINNUM_t Rpi14 = (1 << 14);
const GPIO_PINNUM_t Rpi15 = (1 << 15);
const GPIO_PINNUM_t Rpi16 = (1 << 16);
const GPIO_PINNUM_t Rpi17 = (1 << 17);
const GPIO_PINNUM_t Rpi18 = (1 << 18);
const GPIO_PINNUM_t Rpi19 = (1 << 19);
const GPIO_PINNUM_t Rpi20 = (1 << 20);
const GPIO_PINNUM_t Rpi21 = (1 << 21);
const GPIO_PINNUM_t Rpi22 = (1 << 22);
const GPIO_PINNUM_t Rpi23 = (1 << 23);
const GPIO_PINNUM_t Rpi24 = (1 << 24);
const GPIO_PINNUM_t Rpi25 = (1 << 25);
const GPIO_PINNUM_t Rpi26 = (1 << 26);
const GPIO_PINNUM_t Rpi27 = (1 << 27);
const GPIO_PINNUM_t Rpi28 = (1 << 28);
const GPIO_PINNUM_t Rpi29 = (1 << 29);
const GPIO_PINNUM_t Rpi30 = (1 << 30);
const GPIO_PINNUM_t Rpi31 = (1 << 31);

const GPIO_PINNUM_t Ard0 = (1 << 0);
const GPIO_PINNUM_t Ard1 = (1 << 1);
const GPIO_PINNUM_t Ard2 = (1 << 2);
const GPIO_PINNUM_t Ard3 = (1 << 3);
const GPIO_PINNUM_t Ard4 = (1 << 4);
const GPIO_PINNUM_t Ard5 = (1 << 5);
const GPIO_PINNUM_t Ard6 = (1 << 6);
const GPIO_PINNUM_t Ard7 = (1 << 7);
const GPIO_PINNUM_t Ard8 = (1 << 8);
const GPIO_PINNUM_t Ard9 = (1 << 9);
const GPIO_PINNUM_t Ard10 = (1 << 10);
const GPIO_PINNUM_t Ard11 = (1 << 11);
const GPIO_PINNUM_t Ard12 = (1 << 12);
const GPIO_PINNUM_t Ard13 = (1 << 13);

GPIO_PINDRIVE_t GPIO_PinGet(GPIO_PINNUM_t pin)
{
	return *GPIO_RX & pin;
}
void GPIO_PinSet(GPIO_PINNUM_t pin, GPIO_PINDRIVE_t drive)
{
	if (drive == GPIO_PIN_SET)
	{
		*GPIO_TX |= pin;
	}
	else
	{
		*GPIO_TX &= ~pin;
	}
}
void GPIO_PinMode(GPIO_PINNUM_t pin, GPIO_PINMODE_t mode)
{
	if (mode == GPIO_PIN_INPUT)
	{
		*GPIO_3S |= pin;
	}
	else
	{
		*GPIO_3S &= ~pin;
	}
}
