;*********PING Sensor Test code
;
;This code sets the PING sensor up by sending a 5us pulse on pin T1G
;as an output, then changed to the input of Timer1Gate to time how long
;the return pulse is comming back. This pulse is between 115us to 18.5ms
;Note the PIC clock rate is set at 1MHz, and Timer1 is set so that it increments 
;every cycle or every 1us until TG1 goes low (it is inverted to be active high).
;The counter is 16 bits with a maximum count time of 65.536ms
;
;The general flow is as follows:
;	First set PORTA pin RA4 as an output
;	Write a '1' to this pin - !!!CHECK TO SEE IF THIS CAN BE DONE! - Seems like it can...hope don't burn anything
;	Hold for 5us
;	Remove '1' from this pin
;	Clear Timer1 registers to 0000h
;	Enable TG1 as active high
;	Set PORTA pin RA4 as TG1
;	Wait (perform other tasks)
;	Check TG1 if it is low
;	If low get Timer1 high byte and low byte
;		Else check back later
;	Store value in memory


#include <p16F690.inc>
	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOD_OFF & _IESO_OFF & _FCMEN_OFF)

;store values here
	cblock 0x20
TEMP0
	endc

;begin program code
	org 0
PING_SETUP					;Get PORTA ready for PIN RA4 to be out
	bsf		STATUS,RP0		;change registers I need to in Bank 1, 01
	movlw	b'00000000'		;RA4 as output
	movwf	TRISA
	clrf	TRISC			;make all of PORTC output
	bcf		STATUS,RP0		;get back to bank 0, 00
	movlw	b'00010000'		;put a '1' on the port
	movwf	PORTA			;1us
	nop						;2us
	nop						;3us
	movlw	b'00000000'		;clear it 4us
	movwf	PORTA			;cleared, now have 750us until return pulse, 5us
	clrf	PORTC			;clear PORTC just in case

	;get timer1 registers ready
	clrf	TMR1L			;clear low bits
	clrf	TMR1H			;clear high bits

	;setup CM2CON1 regsiter	
	bsf		STATUS,RP1		;get into bank 2, 10
	movlw	b'00000010'		;set TMR1 to be gated by RA4
	movwf	CM2CON1

	;setup TMR1CON regsiter
	bcf		STATUS,RP1		;get into bank 0
	movlw	b'11110001'		;Active High, Gated, max prescale (later 1us per tic), internal clock, TMR1 active
	movwf	T1CON
	
	;change RA4 to input
	bcf		STATUS,RP1		;get back to bank 1, 01
	bsf		STATUS,RP0
	movlw	b'00010000'		
	movwf	TRISA	

;	bcf		STATUS,RP0		;get back to bank 0, 00
;Wait0	BTFSS	PORTA,4		;wait until return pulse goes high
;		goto	Wait0		;execute if false
;Wait1	BTFSC	PORTA,4		;wait for return pulse to go low
;		goto	Wait1		;execute if false
	
	;keep displaying whatever is in lower half of TMR1L for test purposes
Loop
	movf	TMR1L,w
	movwf	PORTC
	goto	Loop
	end
	

	
