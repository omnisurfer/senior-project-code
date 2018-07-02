;this is the PING))) Sensor routine on pin RA4
;Note: This routine will call a 2nd routine, 
;the serial IO in order to output its data
		org		0x0250
PING_RA4
		movlw	0x00
		bcf		STATUS,RP0		;-------------	
		bsf		STATUS,RP1		;get to bank 2
		bcf		ANSEL,3			;Disable Analog on Pin RA4
		bsf		STATUS,RP0		;-------------
		bcf		STATUS,RP1		;get to bank 1
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
		movwf	PORTA
	
PULSE_DELAY_LOOP1				;aprox 75ms pulse for RA4
		movlw	0xff			;256		
		movwf	TMR0			;low bits
		movlw	0xff;0xc3			;dec 195
		movwf	TMR2			;high bits

	DEC_LOW1
		decfsz	TMR0			;3 instructions per loop
		goto	DEC_LOW1

	DEC_HIGH1
		decfsz	TMR2			;3 more instructions per loop in addition to inner loop
		goto	DEC_LOW1		

		;Time Calculation:
		;256 loops * 3 ops per loop = 768 / 2M ops = 384us per run
		;(768 + 3/outer run) * 195 outer runs  / 2M = 75.1725ms

		;Clr TMR1 Registers
		clrf	TMR1L			;clear TMR1 Low, 6us
		clrf	TMR1H			;clear TMR1 High, 7us

		movlw	b'00000000'		;clear RA4
		movwf	PORTA			;cleared, now have 750us until return pulse

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

WAIT_FOR_PULSE
		btfss	PORTA,4			;is Pulse not here?
		goto	WAIT_FOR_PULSE
WAIT_FOR_LOW_PULSE
		btfsc	PORTA,4			;is Pulse still there?
		goto	WAIT_FOR_LOW_PULSE

;Get Timer1 data ready for Serial routine
		movlw	0x21			;Identify Sensor
		movwf	STORETYPE

		movf	TMR1L,w			;get Timer1 Low Byte
		movwf	STORELOW		;store Timer1 Low Byte

		movf	TMR1H,w			;get Timer1 High Byte
		movwf	STOREHIGH		;store Timer1 High Byte

		CALL	SER_DATA_OUT

PULSE_DELAY_LOOP2				;aprox 1.9275ms '0' "pulse" for RA4
		movlw	0xff;
		movwf	TMR0			;low bits, using timer regsiters to save space
		movlw	0x15;
		movwf	TMR2			;high bits

	DEC_LOW0a
		decfsz	TMR0			;3 instructions per loop
		goto	DEC_LOW0a

	DEC_HIGH0a
		decfsz	TMR2			;3 more instructions per loop in addition to inner loop
		goto	DEC_LOW0a

		RETURN					;return for another value
		;goto	PING_RA4
		
