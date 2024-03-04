;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;	Benton Weizenegger, EELE 371, Lab 11.2
;	2/29/24
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

;-------- Registers ------------------------------------------------------------

		mov.w		#0h, R4
		mov.w		#0h, R5
		mov.w		#0h, R6
		mov.w		#0h, R7
		mov.w		#0h, R8

;------- Inputs --------------------------------------------------------------

		mov.b	#0000h, &P4SEL0			;Initialize S1 as as input
		mov.b	#0000h, &P4SEL1

		bic.b	#BIT1, &P4DIR
		bis.b	#BIT1, &P4REN
		bis.b	#BIT1, &P4OUT			;Pull up resistor


		mov.b	#0000h, &P2SEL0			;Initialize S2 as as input
		mov.b	#0000h, &P2SEL1

		bic.b	#BIT3, &P2DIR
		bis.b	#BIT3, &P2REN
		bis.b	#BIT3, &P2OUT			;Pull up resistor

;------- Outputs ------------------------------------------------------------------

		mov.b	#0000h, &P1SEL0			;Initialize LED1 as output
		mov.b	#0000h, &P1SEL1

		bis.b	#00000001b, &P1DIR
		bic.b	#00000001b, &P1OUT

		mov.b	#000h, &P6SEL0			;Initialize LED2 as output
		mov.b	#000h, &P6SEL1

		bis.b	#01000000b, &P6DIR
		bic.b	#01000000b, &P6OUT

		mov.b	#0000h, &P3SEL0			;Initialize Pin3.0:3 as output
		mov.b	#0000h, &P3SEL1

		bis.b	#1111b, &P3DIR
		mov.b	#0000b, &P3OUT

;------- Interrupts ------------------------------------------------------------

		bic.b	#BIT1, &P4IFG		;Clear SW1 IFG
		bic.b	#BIT1, &P4IES		;Low-to-High IRQ Sensitivity
		bis.b	#BIT1, &P4IE		;Assert local Enable

		bic.b	#BIT3, &P2IFG		;Clear SW2 IFG
		bic.b	#BIT3, &P2IES		;Low-to-High IRQ Sensitivity
		bis.b	#BIT3, &P2IE		;Assert local Enable



		bic.b		#LOCKLPM5, &PM5CTL0
		bis.w		#GIE, SR
;---------- END INIT -----------------------------------------------------------



main:



;----------- BlinkGreen ----------------------------------------------------------

BlinkGreen:

		mov.w	#03h, R5
		xor.b	#BIT6, &P6OUT

LongDelay:

		call	#DelayOnce
		dec		R5
		cmp		#00h, R5
		jnz		LongDelay



;----------- End BlinkGreen ------------------------------------------------------

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

;---------- END MAIN -----------------------------------------------------------

;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------

;--------- Switch1 ISR ---------------------------------------------------------
Switch1Released:

		cmp		#1111b, R6
		jeq		BlinkRed			;Blink Red if R6==1111b
		jl		Add1				;Otherwise add 1

BlinkRed:
		mov.w	#0FFFFh, R7			;R7 as counter
		xor.b	#BIT0, &P1OUT
RedDelay:
		dec		R7
		cmp		#0h, R7
		jnz		RedDelay
		jz		OffRed

Add1:
		add.b	#01b, R6			;Add 1

		jmp		EndWhile
OffRed:
		xor.b	#BIT0, &P1OUT
EndWhile:

		mov.b	R6, &P3OUT			;Move R6 into P3OUT
		bic.b	#BIT1, &P4IFG		;Clear Interrupt Flag
		reti

EndSwitch1Released:

;-------------------------------------------------------------------------------
;--------- Switch2 ISR ---------------------------------------------------------
Switch2Released:


		cmp		#0010b, R6
		jge		Decrement				;Decrement 2 if R6 >= 0010b
		jl		BlinkRed2

BlinkRed2:
		mov.w	#0FFFFh, R8				;R8 as counter
		xor.b	#BIT0, &P1OUT
RedDelay2:
		dec		R8
		cmp		#0h, R8
		jnz		RedDelay2
		jz		OffRed2

Decrement:
		sub.b	#0010b, R6				;Subtract 2
		jmp		EndWhile2
OffRed2:
		xor.b	#BIT0, &P1OUT

EndWhile2:
		mov.b	R6, &P3OUT				;Move R6 into P3OUT
		bic.b	#BIT3, &P2IFG			;Clear Interrupt Flag
		reti

EndSwitch2Released:
;-------------------------------------------------------------------------------

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
			.short	Switch1Released

			.sect	".int24"
			.short	Switch2Released
