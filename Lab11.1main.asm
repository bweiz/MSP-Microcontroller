;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;	Benton Weizenegger, EELE 371, Lab 11.1
;	2/26/24
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

init:

;----------- Outputs ---------------------------------------------------------

		mov.b	#0000h, &P1SEL0			;Initialize LED1 as output
		mov.b	#0000h, &P1SEL1

		bis.b	#00000001b, &P1DIR
		bic.b	#00000000b, &P1OUT

		mov.b	#000h, &P6SEL0			;Initialize LED2 as output
		mov.b	#000h, &P6SEL1

		bis.b	#01000000b, &P6DIR
		bic.b	#01000000b, &P6OUT

		mov.b	#0000h, &P5SEL0			;Initialize Pin5 as output
		mov.b	#0000h, &P5SEL1

		bis.b	#1111b, &P5DIR
		bic.b	#1111b, &P5OUT

;----------- Inputs ---------------------------------------------------------

		mov.b	#0000h, &P4SEL0			;Initialize SW1 as as input
		mov.b	#0000h, &P4SEL1

		bic.b	#BIT1, &P4DIR
		bis.b	#BIT1, &P4REN
		bis.b	#BIT1, &P4OUT			;Pull up resistor


		mov.b	#0000h, &P2SEL0			;Initialize SW2 as as input
		mov.b	#0000h, &P2SEL1

		bic.b	#BIT3, &P2DIR
		bis.b	#BIT3, &P2REN
		bis.b	#BIT3, &P2OUT			;Pull up resistor

;----------- Registers ---------------------------------------------------------

		mov.w	#0h, R4
		mov.w	#0h, R5
		mov.w	#0h, R6
		mov.w	#0h, R7

;----------- Port Interrupts --------------------------------------------------

		bic.b	#BIT1, &P4IFG		;Clear SW1 IFG
		bis.b	#BIT1, &P4IES		;High-to-Low IRQ Sensitivity
		bis.b	#BIT1, &P4IE		;Assert local Enable

		bic.b	#BIT3, &P2IFG		;Clear SW2 IFG
		bic.b	#BIT3, &P2IES		;Low-to-High IRQ Sensitivity
		bis.b	#BIT3, &P2IE		;Assert local Enable



;----------- Disable Low Power Mode, Enable Global Interupts -------------------

		bic.b		#LOCKLPM5, &PM5CTL0
		bis.w		#GIE, SR

main:

;----------- BlinkRed ----------------------------------------------------------

BlinkRed:

		mov.w	#03h, R5
		xor.b	#BIT0, &P1OUT

LongDelay:

		call	#DelayOnce
		dec		R5
		cmp		#00h, R5
		jnz		LongDelay



;----------- End BlinkRed ------------------------------------------------------

		jmp		main

;---------- END MAIN -----------------------------------------------------------

;-------------------------------------------------------------------------------
; Delay Subroutine
;-------------------------------------------------------------------------------
DelayOnce:

		mov.w	#0FFFFh, R4

Delay:
		dec		R4
		cmp		#00h, R4
		jnz		Delay
		ret

;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------

Switch1Triggered:

		xor.b	#BIT6, &P6OUT		;Turn on green LED
		bic.b	#BIT1, &P4IFG		;Clear Interrupt Flag
		reti

EndSwitch1Triggered:

;--------- End Switch1Triggered ------------------------------------------------

Switch2Some:

		mov.w	#01h, R5
		mov.w	R5, R7
		xor.b	#BIT6, &P6OUT			;Turn on Green LED

blinkGreen:
		call	#DelayOnce				;Call Delay subroutine
		dec		R7
		cmp		#0h, R7
		jnz		blinkGreen
		xor.b	#BIT6, &P6OUT			;Turn off green LED
		bic.b	#BIT3, &P2IFG			;Clear Interrupt Flag
		reti

EndSwitch2Some:

;----------- End Switch2Some ---------------------------------------------------


;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET



			.sect	".int22"
			.short	Switch1Triggered

			.sect	".int24"
			.short	Switch2Some



            
