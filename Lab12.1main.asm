;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;	Benton Weizenegger, EELE 371, Lab 12.1
;	3/3/14
;	TB0: (1/32768)(1/8)(2^12)
;	TB1: (1/32768)(1/2/8)(2^12)
;
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
		bic.b	#00000001b, &P1OUT

		mov.b	#0000h, &P6SEL0			;Initialize LED2 as output
		mov.b	#0000h, &P6SEL1

		bis.b	#01000000b, &P6DIR
		bic.b	#01000000b, &P6OUT
;-------------------------------------------------------------------------------
;------- Timers B0 and B1 ------------------------------------------------------

		bis.w	#TBCLR, &TB0CTL
		bis.w 	#TBSSEL__ACLK, &TB0CTL
		bis.w	#MC__CONTINUOUS, &TB0CTL		;Continuous
		bis.w	#CNTL_1, &TB0CTL				;12-bit count length
		bis.w	#ID__8, &TB0CTL					;divide by 8

		bis.w	#TBCLR, &TB1CTL
		bis.w 	#TBSSEL__ACLK, &TB1CTL
		bis.w	#MC__CONTINUOUS, &TB1CTL		;Continuous
		bis.w	#CNTL_1, &TB1CTL				;12-bit count length
		bis.w	#ID__2, &TB1CTL					;divide by 2
		bis.w	#TBIDEX__8, &TB1EX0				;Divide by 8

		bis.w	#TBIE, &TB0CTL					;Enable overflow interupt
    	bic.w	#TBIFG, &TB0CTL					;Clear interupt flag

    	bis.w	#TBIE, &TB1CTL
   		bic.w	#TBIFG, &TB1CTL

		bis.w	#GIE, SR
   		bic.b	#LOCKLPM5, &PM5CTL0

main:
		jmp 	main

;-------------------------------------------------------------------------------
; Interupt Service Routines
;-------------------------------------------------------------------------------

;--------- Timer 0 -------------------------------------------------------------

TimerB0_1s:

		xor.b		#BIT0, &P1OUT
		bic.w		#TBIFG, &TB0CTL
		reti

EndTimerB0_1s:


;--------- Timer 0 END ---------------------------------------------------------



;--------- Timer 1 -------------------------------------------------------------

TimerB1_2s:


		xor.b		#BIT6, &P6OUT
		bic.w		#TBIFG, &TB1CTL
		reti

EndTimerB1_2s:

;--------- Timer 1 END ---------------------------------------------------------

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
            
            .sect	".int42"
            .short	TimerB0_1s

            .sect	".int40"
            .short	TimerB1_2s
