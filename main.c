#include <msp430.h> 

/**
 * Ben Weizenegger, Project Day 1, EELE 371
 * 4/10/2024
 */

/**
 *      AD2 Voltage          | MSP Conversions  | Error
 *------------------------------------------------------------------------------------
 *                           |                  |
 * (1*2^8)/3.3 = 77.57       |    78            |   43 mV
 *                           |                  |
 * (2.3*2^8)/3.3 = 178.42    |    178           |   42 mV
 *                           |                  |
 * (3*2^8)/3.3 = 232.72      |    232           |   72 mV
 *                           |                  |
 *
 *
 *                              Max Resolution Error
 *                      ((178/2^8)*3.3) - ((179/2^8)*3.3) = .013
 *
 *                                  13 mV
 */

/**
 * main.c
 */

unsigned int ADCvalue;

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	//-- LEDs
	P1DIR |= BIT0;
	P1OUT &= ~BIT0;

	//-- Set Port 1.4 for A4

	P1SEL0 |= BIT4;
	P1SEL1 |= BIT4;

	//-- Configure ADC

	ADCCTL0 &= ~ADCSHT;         //-- Clear ADCSHT from def. of ADCSHT=01
	ADCCTL0 |= ADCSHT_2;        // Conversion Cycles = 16
	ADCCTL0 |= ADCON;           // Turn ADC on

	ADCCTL1 |= ADCSSEL_2;       // SMCLK clock source
	ADCCTL1 |= ADCSHP;          // Sample signal source

	ADCCTL2 &= ~ADCRES;         // Clear ADCRES from def. of ADCRES=01
	ADCCTL2 |= ADCRES_0;        // 8-Bit Resolution

	ADCMCTL0 |= ADCINCH_4;      // ADC input channel = A4 P1.4

	ADCIE |= ADCIE0;            // Enable conv complete IRQ

	PM5CTL0 &= ~LOCKLPM5;

	while(1) {
        ADCCTL0 |= ADCENC | ADCSC;              // Enable and start conversion
        __bis_SR_register(GIE | LPM0_bits);     // Enable maskable IRQs

        if (ADCvalue > 176) {
            P1OUT |= BIT0;
        } else if (ADCvalue <= 176) {
            P1OUT &= ~BIT0;
        }
	}
	return 0;
}

//-- Interrupt Service Routines
#pragma vector=ADC_VECTOR
__interrupt void ADC_ISR(void) {
    __bic_SR_register_on_exit(LPM0_bits);       // Wake up CPU
    ADCvalue = ADCMEM0;                         //
} //-- END ADC ISR
