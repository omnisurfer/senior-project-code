;*********TMR1 Gate control test
;
;This code is ment to test the TMR1 Gate control setup for the PING
;sensor. By holding the value on RA4, this will enable to counter.
;The high bits will be monitored.
;CODE TEST OK

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
;	Setup PORTA for digi I/O
;	First set PORTA pin RA4 as an output
;	Write a '1' to this pin - !!!CHECK TO SEE IF THIS CAN BE DONE!
;	Hold for 5us
;	Remove '1' from this pin
;	Clear Timer1 registers to 0000h
;	Enable TG1 as active high
;	Set PORTA pin RA4 as TG1
;	Wait (perform other tasks)
;	Check TG1 if it is low	- changed to endless display of lower byte
;	If low get Timer1 high byte and low byte
;		Else check back later
;	Store value in memory

#include <p16F690.inc>
	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOD_OFF & _IESO_OFF & _FCMEN_OFF)
	cblock	0x20
STORELOW
STOREHIGH
	endc


		org		0
PULSE_ROUTINE					;Get PORTA ready for PIN RA4 to be out
		bcf		STATUS,RP0		;-------------	
		bsf		STATUS,RP1		;get to bank 2
		clrf	ANSEL			;make PORTA all digi I/Os		
CONT_END						;TEST CODE FOR PING CYCLING!!	
		bsf		STATUS,RP0		;-------------
		bcf		STATUS,RP1		;get to bank 1
		clrf	TRISC			;make PORTC all out
		movlw	b'01110001'		;internal clock, 2MHz OSC, 1MHz system, 1us per tick
		movwf	OSCCON
PULSE_AGAIN						;For test around loop last bank is 0
		movlw	b'00000000'		;make PORTA all out
		movwf	TRISA

		
		bcf		STATUS,RP0		;get to bank 0
		bcf		STATUS,RP1		;get back to reg 0
		movlw	b'00000000'		;put a '0' on the port for transition
		movwf	PORTA

PULSE_DELAY_LOOP0				;aprox 1.9275ms '0' "pulse" for RA4
		movlw	0xff;
		movwf	TMR0			;low bits, using timer regsiters to save space
		movlw	0x05;
		movwf	TMR2			;high bits

	DEC_LOW0
		decfsz	TMR0			;3 instructions per loop
		goto	DEC_LOW0

	DEC_HIGH0
		decfsz	TMR2			;3 more instructions per loop in addition to inner loop
		goto	DEC_LOW0


		movlw	b'00010000'		;put a '1' on the port
		movwf	PORTA			;1us
		
PULSE_DELAY_LOOP1				;aprox 20.046ms pulse for RA4
		movlw	0xff			;256		
		movwf	TMR0			;low bits
		movlw	0x9f			;dec 159
		movwf	TMR2			;high bits

	DEC_LOW1
		decfsz	TMR0			;3 instructions per loop
		goto	DEC_LOW1

	DEC_HIGH1
		decfsz	TMR2			;3 more instructions per loop in addition to inner loop
		goto	DEC_LOW1		

		;Time Calculation:
		;256 loops * 3 ops per loop = 768 / 2M ops = 384us per run
		;(768 + 3/outer run) * 159 outer runs =  / 2M = 61.2945ms

		;Clr TMR1 Registers
		clrf	TMR1L			;clear TMR1 Low, 6us
		clrf	TMR1H			;clear TMR1 High, 7us

		movlw	b'00000000'		;clear RA4
		movwf	PORTA			;cleared, now have 750us until return pulse, 5us - 7us

		bsf		STATUS,RP0		;get to bank 1
		bcf		STATUS,RP1
		movlw	b'00111111'		
		movwf	TRISA			;make RA4 input

TMR1_SETUP		;get TMR1 ready	
		bcf		STATUS,RP0
		bsf		STATUS,RP1		;get to bank 2
								;setup CM2CON1 regsiter - already in bank 1
		movlw	b'00000010'		;set TMR1 to be gated by RA4
		movwf	CM2CON1

		bcf		STATUS,RP1		;get to bank 0
		movlw	b'11000001'		;Active High, Gated, max prescale (later 1us per tic), internal clock, TMR1 active
		movwf	T1CON

;TEST OUTPUT ROUTINE HERE
WAIT_FOR_PULSE
		btfss	PORTA,4			;is Pulse not here?
		goto	WAIT_FOR_PULSE
WAIT_FOR_LOW_PULSE
		btfsc	PORTA,4			;is Pulse still there?
		goto	WAIT_FOR_LOW_PULSE

DISPLAY_TIMER1
		movf	TMR1L,w			;endlessly display whatever is in TMR1L
		movwf	PORTC			;so long as RA4 is High, TMR1L will increment

PULSE_DELAY_LOOP2				;
		movlw	0x86			;205us delay until next measurment
		movwf	TMR0			;low bits

	DEC_LOW2
		decfsz	TMR0			;3 instructions per loop
		goto	DEC_LOW2

		goto	PULSE_ROUTINE
		end
