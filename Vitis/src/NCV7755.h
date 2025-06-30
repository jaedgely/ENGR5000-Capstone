/*
 *  NCV7755.h
 *
 *	Advertising, the new american art
 *
 * 	Created on: Feb 27, 2025
 *      Author: edgelyj
 */

#ifndef SRC_NCV7755_H_
#define SRC_NCV7755_H_

#include "sleep.h"

#include "HALs/GPIO_HAL.h"
#include "HALs/SPI_HAL.h"

enum State
{
	Sleep = 0x0,
	Idle = 0x1,
	Active = 0x2,
};
enum DrainChannel
{
	Ch0 = 1 << 0,
	Ch1 = 1 << 1,
	Ch2 = 1 << 2,
	Ch3 = 1 << 3,
	Ch4 = 1 << 4,
	Ch5 = 1 << 5,
	Ch6 = 1 << 6,
	Ch7 = 1 << 7
};
class NCV7755
{
private:

	typedef struct
	{
		const uint8_t ADDR = 0x00U;
		volatile uint8_t CH0  : 1;
		volatile uint8_t CH1  : 1;
		volatile uint8_t CH2  : 1;
		volatile uint8_t CH3  : 1;
		volatile uint8_t CH4  : 1;
		volatile uint8_t CH5  : 1;
		volatile uint8_t CH6  : 1;
		volatile uint8_t CH7  : 1;
	} OUT_t;

	typedef struct
	{
		const uint8_t ADDR = 0x01U;
		volatile uint8_t CH0  : 1;
		volatile uint8_t CH1  : 1;
		volatile uint8_t CH2  : 1;
		volatile uint8_t CH3  : 1;
		volatile uint8_t CH4  : 1;
		volatile uint8_t CH5  : 1;
		volatile uint8_t CH6  : 1;
		volatile uint8_t CH7  : 1;
	} BIM_t;

	typedef struct
	{
		const uint8_t ADDR = 0x04U;
		volatile uint8_t CH0  : 1;
		volatile uint8_t CH1  : 1;
		volatile uint8_t CH2  : 1;
		volatile uint8_t CH3  : 1;
		volatile uint8_t CH4  : 1;
		volatile uint8_t CH5  : 1;
		volatile uint8_t CH6  : 1;
		volatile uint8_t CH7  : 1;
	} MAPIN0_t;

	typedef struct
	{
		const uint8_t ADDR = 0x05U;
		volatile uint8_t CH0  : 1;
		volatile uint8_t CH1  : 1;
		volatile uint8_t CH2  : 1;
		volatile uint8_t CH3  : 1;
		volatile uint8_t CH4  : 1;
		volatile uint8_t CH5  : 1;
		volatile uint8_t CH6  : 1;
		volatile uint8_t CH7  : 1;
	} MAPIN1_t;

	typedef struct
	{
		const uint8_t ADDR = 0x06U;
		volatile uint8_t CH0  : 1;
		volatile uint8_t CH1  : 1;
		volatile uint8_t CH2  : 1;
		volatile uint8_t CH3  : 1;
		volatile uint8_t CH4  : 1;
		volatile uint8_t CH5  : 1;
		volatile uint8_t CH6  : 1;
		volatile uint8_t CH7  : 1;
	} INST;

	typedef struct REGMAP_t
	{
		/*
		 *	Power Output Control Register bits (OUT.OUT.n)
	 	 *	0B (default) Output is Off
	     *	1B Output is On
	     *	DATA = Channel number 7 to 0 [7:0]
		 */
		uint8_t OUT 	   = 0b000000;
		/*
		 *	Bulb Inrush Mode bits (BIM.OUTn)
		 	 *  	0B (default) Output latches off with overload
		 *		1B Output restarts with overload
		 *	DATA = Channel number 7 to 0 [7:0]
		 */
		uint8_t BulbInrush = 0b000001;
		/*
		 *	Input Mapping (IN0) bits (MAPIN0.OUTn)
		 *		0B (default) No connection to input pin
		 *		1B Output is connected to the input pin
		 *  DATA = Channel number 7 to 0 [7:0]
		 *	Note – Channel 2 has the corresponding bit set to “1” by default
		 */
		uint8_t MAPIN_0    = 0b000100;
		/*
		 *	Input Mapping (IN1) bits (MAPIN1.OUTn)
		 *		0B (default) No connection to input pin
		 *		1B Output is connected to the input pin
		 *  DATA = Channel number 7 to 0 [7:0]
		 *	Note – Channel 3 has the corresponding bit set to “1” by default
		 */
		uint8_t MAPIN_1    = 0b000101;
		/*
		 * 	Input Status Monitor
		 *	TER bit bit (TER) (7)
		 *		0B Previous transmission was successful
		 *		1B (default) Previous transmission failed
		 *	Inx Bit bits (INST.RES) (6:2) – reserved, bits (INST.INn) (1:0)
		 *		0B (default) The input pin is set low
		 *		1B The input pin is set high
		 */
		uint8_t INST 	   = 0b000110;
		/*
		 * 	Open Load Diagnostic Current Control
		 *	bits (DIAG_IOL.OUTn)
		 *		0B (default) Diagnostic current is not enabled
		 *		1B Diagnostic current is enabled
		 * 	DATA = Channel number 7 to 0 [7:0]
		 */
		uint8_t DIAG_IOL   = 0b001000;
		/*
		 *	Output Status Monitor bits (DIAG_OSM.OUTn)
		 *		0B (default) Voutx is less than the Output Status Monitor Threshold Voltage 3.3 V (typ)
		 *		1B Voutx is more than the Output Status Monitor Threshold Voltage 3.3 V (typ)
		 * 	DATA = Channel number 7 to 0 [7:0]
		 */
		uint8_t DIAG_OSM   = 0b001001;
		/*
		 * 	Open Load On Monitor bits (DIAG_OLON.OUTn)
		 *		0B (default) Normal operation or diagnostic performed with channel off
		 *		1B Open load On detected
		 *	DATA = Channel number 7 to 0 (7:0)
		 */
		uint8_t DIAG_OLON  = 0b001010;
		/*
		 * 	Open Load On Diagnostic Control
		 *	bits (7:4) – reserved,
		 *	bits 1000B , 1001B , 1011B , 1100B , 1101B , 1100B - reserved
		 *	bits (DIAG_OLONEN.MUX) (3:0)
		 *		0000B Open Load ON active channel 0
		 *		0001B Open Load ON active channel 1
		 *		0010B Open Load ON active channel 2
		 *		0011B Open Load ON active channel 3
		 *		0100B Open Load ON active channel 4
		 * 		0101B Open Load ON active channel 5
		 * 		0110B Open Load ON active channel 6
		 * 		0111B Open Load ON active channel 7
		 *		1010B Open Load ON Diagnostic Loop Start
		 * 		1111B (default) Open Load ON not active
		 */
		uint8_t DIAG_OLONEN = 0b001011;
		/*
		 * 	Hardware Configuration Register bits (5:4) - reserved
		 *	Active Mode bits (HWCR.ACT) (7)
		 *		0B (default) Normal operation or device leaves Active Mode
		 *		1B Device enters Active Mode
		 *	SPI Register Reset bits (HWCR.RST) (6)
		 *		0B (default) Normal operation
		 *		1B Reset command executed
		 * 		Note - ERRn bits are not cleared by a reset command for safety reasons
		 *	Channels Operating in Parallel bits (HWCR.PAR) (3:0)
		 *		0B (default) Normal operation
		 *		1B Two neighboring channels have overload and overtemperature synchronized. See section “Outputs in Parallel” for output combinations
		 */
		uint8_t HWCR = 0b001100;
		/*
		 * 	Output Latch (ERRn) Clear bits (HWCR_OCL.OUTn)
		 *		0B (default) Normal operation
		 *		1B Clear the error latch for the selected output
		 *	The HWCR_OCL.OUTn bit is set back to “0” internally after de-latching the channel
		 *		DATA = 7 to 0 (7:0)
		 */
		uint8_t HWCR_OCL = 0b001101;
		/*
		 * 	PWM Configuration Register (HWCR_PWM.RES) (3:2) (reserved)
		 * 	PWM Adjustment bits (HWCR_PWM.ADJ) (7:4)
		 * 	fINT ~= 102kHz
		 * 	HWCR_PWM.ADJ Bit | Absolute delta for fINT | Relative delta between steps
	     * 	0000B (reserved) |		   --		       |			--
		 * 	0001B            | Base Frequency  -35.0%  | -35.0% (66.3 kHz[typ])
	     * 	0010B 			 | Base Frequency -30.0%   |
		 * 	0011B 			 | Base Frequency -25.0%   |
		 * 	0100B            | Base Frequency -20.0%   |
		 * 	0101B 			 | Base Frequency -15.0%   |
		 * 	0110B     		 | Base Frequency -10.0%   |
		 * 	0111B 			 | Base Frequency -5.0%	   |
		 * 	1000B (default)	 | Base Frequency fINT     |
		 * 	1001B 			 | Base Frequency +5.0%    |
		 * 	1010B 			 | Base Frequency +10.0%   |
		 * 	1011B 			 | Base Frequency +15.0%   |
		 * 	1100B		     | Base Frequency +20.0%   |
		 * 	1101B			 | Base Frequency +25.0%   |
		 * 	1110B 			 | Base Frequency +30.0%   |
		 * 	1111B 			 | Base Frequency +35.0%   |	+35.0 (137.7 kHz[typ])
		 *
		 *	PWM1 Active bits (HWCR_PWM.PWM1) (1)
		 *		0B (default) PWM Generator 1 not active
		 *		1B PWM Generator 1 active
		 *	PWM0 Active (HWCR_PWM.PWM0) (0)
		 *		0B (default) PWM Generator 0 not active
		 *		1B PWM Generator 0 active
		 */
		uint8_t HWCR_PWM = 0b001110;
		/*
		 * 	PWM Generator 0 Configuration
		 * 	CR0 Frequency (PWM_CR0.FREQ) (9:8)
		 *  	00B Internal clock divided by 1024 (100 Hz) (default)
		 * 		01B Internal clock divided by 512 (200 Hz)
		 * 		10B Internal clock divided by 256 (400 Hz)
		 *		11B 100% Duty Cycle.
		 *	CR0 generator on/off control (PWM_CRO.DC) (7:0)
		 *		00000000B PWM generator is off. (default)
		 *		11111111B PWM generator is On (99.61% DC).
		 */
		uint8_t PWM_CR0 = 0b0100;
		/*
		 * 	PWM Generator 1 Configuration
		 * 	CR1 Frequency(PWM_CR1.FREQ) (9:8)
		 *		00B Internal clock divided by 1024 (100Hz) (default)
		 *		01B Internal clock divided by 512 (200 Hz)
		 *		10B Internal clock divided by 256 (400 Hz)
		 *		11B 100% Duty Cycle
		 *	CR1 generator on/off control (PWM_CR1.DC) (7:0)
		 *		00000000B PWM generator is off. (default)
		 *		11111111B PWM generator is On (99.61% DC)
		 */
		uint8_t PWM_CR1 = 0b0101;
		/*
		 *	PWM Generator Output Control (PWM_OUT.OUTn)
		 *		0B (default) The selected ouput is not driven by one of the two PWM generators
		 *		1B The selected output is connected to a PWM generator
		 *	DATA = Channel number 0 to 7
		 */
		uint8_t PWM_OUT = 0b100100;
		/*
		 * 	PWM Generator Output Mapping (PWM_MAP.OUTn)
		 * 		0B (default) The selected output is connected to PWM Generator 0
		 *		1B The selected output is connected to PWM Generator 1
		 *	DATA = Channel number 0 to 7
		 *	Works in conjunction with PWM_OUT
		 */
		uint8_t PWM_MAP = 0b100101;
	} REGMAP_t;
	uint8_t readCommandStartBits;
	uint8_t readCommandEndBits;
	uint8_t writeCommandStartBits;
	volatile uint8_t activeChannels;
	void Write(uint8_t *command);
	void ReadRegister(uint8_t *command, uint8_t *result);
	volatile uint8_t pinheader;
	volatile uint32_t cs;
    REGMAP_t RegMap;
public:

	NCV7755();
	NCV7755(GPIO_PINHEADER_t header, GPIO_PINNUM_t csGpio);

	/* 	The following methods which take uint8_t input will set the channels to the binary equivalent
	 * 	Example: All channels are currently OFF. If you write 0xAA (0b10101010), then,
	 * 	Ch7, Ch5, Ch3, Ch1 will turn on, but Ch6, Ch4, Ch2, and Ch0 will turn off.
	*/
	void SetState(State state);

	void SetHardwareControl(bool activeMode, bool spiReset);
	void SetOutput(uint8_t channels);
	void SetBulbInrush(uint8_t channels);
	void SetOpenLoadDiagCurrent(uint8_t channels);
	void SetOpenLoadDiagControl(uint8_t channels);
	void ClearOutputLatchBits(uint8_t channels);

	void GetOutput(uint8_t &channels);
	void GetBulbInrush(uint8_t &channels);
	void GetOpenLoadDiagCurrent(uint8_t &channels);
	void GetOpenLoadDiagControl(uint8_t &channels);
	void GetOutputLatchBits(uint8_t &channels);

	/*
	 * 	The following methods will toggle a single channel, and will preserve all other settings
	 * 	Example: All channels are currently ON. If you write (Ch3, false), Ch3 will turn off,
	 * 	and all others will remain on
	 */
	void SetOutput(DrainChannel channel, bool enabled);
	void SetBulbInrush(DrainChannel channel, bool enabled);	// Targets a specific channel, preserves current settings
	void SetOpenLoadDiagCurrent(DrainChannel channels, bool enabled);
	void SetOpenLoadDiagControl(DrainChannel channels, bool enabled);
	void ClearOutputLatchBits(DrainChannel channels);

	/*
	 * 	I am too lazy too make a (uint8_t) and a (DrainChannel, bool) method
	 */
	void GetState(State &state);
	void GetBulbInrushSetting(uint8_t &channels);
	void GetOutputStatus(uint8_t &channels);
	void GetOpenLoadSettings(uint8_t &channels);
	void GetOpenLoadStatus(uint8_t &channels);
	void GetInputStatus(bool &transSuccessful, bool &inStatus1, bool &inStatus2);

	void SetInputMap0(uint8_t channels);
	void SetInputMap1(uint8_t channels);
	void SetInputMap0(DrainChannel channel);
	void SetInputMap1(DrainChannel channel);

	// PWM Control
	void SetPWMFrequency(uint8_t prescale);

	void SetPWM0Output(bool enabled);

	void SetPWM0Config(uint8_t internalClock, uint8_t dutyCycle);
	void SetPWM1Config(uint8_t internalClock, uint8_t dutyCycle);

	void SetPWMConnection(uint8_t channels);
	void SetPWMMapping(uint8_t channels);
	void MapInput0(DrainChannel channel);
	void MapInput1(DrainChannel channel);

	uint8_t &GetInputStatus();

	void __RAW__IO__UNSAFE__WRITE(uint16_t &data);

	virtual ~NCV7755();
};

#endif /* SRC_NCV7755_H_ */
