;*****Main
;This is the main PIC routine that will setup the PIC, call the data
;aquirement routines, and manage which sensors to use

#include <p16F690.inc>
	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _IESO_OFF & _FCMEN_OFF)

		org		0x0000
Init_PIC					
		bsf		STATUS,RP0		;-------------
		bcf		STATUS,RP1		;get to bank 1
		movlw	b'01110001'		;internal clock, 2MHz OSC, 1MHz system, 1us per tick
		movwf	OSCCON

Init_PORTA
		bsf		STATUS,RP0		;-------------
		bcf		STATUS,RP1		;get to bank 1
		movlw	b'00000100'		;TRISA2 must remain IN for A2D, TRISA1 & TRISA3 out for now
		movwf	TRISA

Init_PORTB
		movlw	b'00110000'		;TRISB5 must remain IN for A2D, TRISB6 out for now, 
								;TRISB7 & 5 USUART to controls
		movwf	TRISB

Init_PORTC
		movlw	b'11111111' 	;All PORTC is input
		movwf	TRISC		

Init_USUART						;get USUART running
		bsf		STATUS,RP0		;get to bank 1
		bcf		STATUS,RP1		
		movlw	b'00100000'		;8 bit, tx enabled, Async, Low Speed
		movwf	TXSTA
		movlw	b'00000000'		;Non-invert data, 8-bit gen, no interrupts, no auto baud detect
		movwf	BAUDCTL
		movlw	b'00110011'		;Should give 2.4k baud, for 8 bit mode
		movwf	SPBRG

		bcf		STATUS,RP0		;get to bank 0
		movlw	b'10010000'		;port enabled, 8-bit, cont rec
		movwf	RCSTA

Init_A2D		
		bsf		STATUS,RP0
		bcf		STATUS,RP1	;Get to Bank 1
		movlw	b'01110000'		;Setup A2D Clock Fosc/2
		movwf	ADCON1

		bcf		STATUS,RP0
		bsf		STATUS,RP1	;Get to Bank 2
		movlw	b'11110100' ;ANS7 - 0
		movwf	ANSEL		;RC3, RC2, RC1, RC0, RA2, RA1
		movlw	b'00000111'	;ANS11 - 8
		movwf	ANSELH		;RB4, RC7, RC8

TEST0
		CALL	PING_RA4
	
		movlw	0x90		;ANCH04, Servo 0 Voltage
		movwf	A2DCH
		CALL	a2d_sub

		movlw	0x94		;ANCH05, Servo 2 Voltage
		movwf	A2DCH
		CALL	a2d_sub

		movlw	0x98		;ANCH06, Servo 4 Voltage
		movwf	A2DCH
		CALL	a2d_sub

		movlw	0x9C		;ANCH07, Servo 6 Voltage
		movwf	A2DCH
		CALL	a2d_sub

		movlw	0xA0		;ANCH08, Servo 8 Voltage
		movwf	A2DCH
		CALL	a2d_sub

		movlw	0xA4		;ANCH09, Servo 10 Voltage
		movwf	A2DCH
		CALL	a2d_sub

		movlw	0xA8		;ANCH09, Servo 10 Voltage
		movwf	A2DCH
		CALL	a2d_sub

		movlw	0x88		;ANCH09, Servo 10 Voltage
		movwf	A2DCH
		CALL	a2d_sub

		CALL	irp_gen

			movlw	0xff				
			movwf 	DELAYL			;lower bits
			movlw	0xff			;dec 195
			movwf	DELAYH			;high bits
			CALL	delay_gen
			CALL	delay_gen
			CALL	delay_gen
			CALL	delay_gen
			CALL	delay_gen

		goto	TEST0
								;note: must explicit org & no end statment
								;CALL BEFORE THE CODE IS INCLUDED!! 
								;Between this code and the included code is where
								;the sensor calls should occur

#include<ping_ra4.asm>			;including the ping sensor asm
#include<a2d_gen.asm>			;a2d sensor readings
#include<delay_gen.asm>			;standard delay routine
#include<serial_io.asm>			;the serial IO asm
#include<irp_gen.asm>

		end

