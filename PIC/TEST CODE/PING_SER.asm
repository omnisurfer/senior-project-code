;*****PING With Serial Data Return Test
;This code is to test how data return the ping sensor 
;witht the serial port code

#include <p16F690.inc>
	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _IESO_OFF & _FCMEN_OFF)
	org 0
Init_PIC					
		bsf		STATUS,RP0		;-------------
		bcf		STATUS,RP1		;get to bank 1
		movlw	b'01110001'		;internal clock, 2MHz OSC, 1MHz system, 1us per tick
		movwf	OSCCON

Init_USUART						;get USUART running
		bsf		STATUS,RP0		;get to bank 1
		bcf		STATUS,RP1		
		movlw	b'00100000'		;8 bit, tx enabled, Async, Low Speed
		movwf	TXSTA
		movlw	b'00000000'		;Non-invert data, 8-bit gen, no interrupts, no auto baud detect
		movwf	BAUDCTL
		movlw	b'00110011'		;hex for 51 which should give 2.4k baud, for 16 bit mode
		movwf	SPBRG

		bcf		STATUS,RP0		;get to bank 0
		movlw	b'10010000'		;port enabled, 8-bit, cont rec
		movwf	RCSTA

TEST0
		CALL 	PING_RA4
		;CALL	SER_DATA_OUT
		goto	TEST0
								;note: must explicit org & no end statment

#include<ping_ra4.asm>			;including the ping sensor asm
#include<serial_io.asm>			;the serial IO asm


		end

