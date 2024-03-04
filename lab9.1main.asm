;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;	Benton Weizenegger, EELE 371, Lab 9.1
;	2/8/25
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

;------------ Configure LED2 ---------------------------------------------------
		mov.b	#000h, &P6SEL0			;Initialize LED2 as output
		mov.b	#000h, &P6SEL1

		bis.b	#01000000b, &P6DIR
		bic.b	#01000000b, &P6OUT
;------------ Configure LED1 ---------------------------------------------------
		mov.b	#000h, &P1SEL0			;Initialize LED1 as output
		mov.b	#000h, &P1SEL1

		bis.b	#00000001b, &P1DIR
		bic.b	#00000000b, &P1OUT
;------------ Switch 1 ---------------------------------------------------------
		mov.b	#000h, &P4SEL0			;Initialize S1 as as input
		mov.b	#000h, &P4SEL1

		bic.b	#BIT1, &P4DIR
		bis.b	#BIT1, &P4REN
		bis.b	#BIT1, &P4OUT

;------------ Switch 2 ---------------------------------------------------------
		mov.b	#000h, &P2SEL0			;Initialize S2 as input
		mov.b	#000h, &P2SEL1

		bic.b	#BIT3, &P2DIR
		bis.b	#BIT3, &P2REN
		bis.b   #BIT3, &P2OUT			;Pull-up resistor
;------------ Pin 5/ LED3 ------------------------------------------------------
		mov.b	#000h, &P5SEL0			;Initialize Pin5 as output
		mov.b	#000h, &P5SEL1

		bis.b	#BIT2, &P5DIR
		bic.b	#BIT2, &P5OUT			;Pull-up resistor
;----------- Pin 3 -------------------------------------------------------------
		mov.b	#000h, &P3SEL0			;Initialize Pin3 as input
		mov.b	#000h, &P3SEL1

		bic.b	#BIT7, &P3DIR
		bis.b	#BIT7, &P3REN
		bic.b	#BIT7, &P3OUT			;Pull-down resistor
;


;------------ Disable Low Power Mode -------------------------------------------
		bic.b	#LOCKLPM5, &PM5CTL0


main:

;-------------- Digital Outputs ------------------------------------------------

		xor.b	#BIT2, &P5OUT

		xor.b	#BIT6, &P6OUT		;Toggle LED2
		xor.b	#BIT6, &P6OUT

		xor.b	#BIT0, &P1OUT		;Toggle LED1
		xor.b	#BIT0, &P1OUT
;--------------- Digital Inputs ------------------------------------------------

		mov.w	P4IN, R4			;Test S1 is off(PxIN=1)
		mov.w	P2IN, R5			;Test S2 is off(PxIN=1)
		mov.w	P3IN, R6

		mov.w	P4IN, R4			;Test S1 is on (PxIN=0)
		mov.w	P2IN, R5			;Test S2 is off(PxIN=1)
		mov.w	P3IN, R6

		mov.w	P4IN, R4			;Test S1 is off(PxIN=1)
		mov.w	P2IN, R5			;Test S2 is on (PxIN=0)
		mov.w	P3IN, R6

		mov.w	P4IN, R4			;Test S1 is on (PxIN=0)
		mov.w	P2IN, R5			;Test S2 is on (PxIN=0)
		mov.w	P3IN, R6

		xor.b	#BIT2, &P5OUT

		jmp			main

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
            
