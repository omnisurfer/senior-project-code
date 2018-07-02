;this is the PING))) Sensor routine on pin RA4
;Note: This routine will call a 2nd routine, 
;the serial IO in order to output its data
		org		0x400
PING_RA4
		bsf		STATUS,RP0		;-------------
		bcf		STATUS,RP1		;get to bank 1
		bcf		TRISA,4			;make RA4 output
	
		bcf		STATUS,RP0		;get to bank 0
		bcf		STATUS,RP1		;get back to reg 0

		bcf		PORTA,4			;put a zero

		;Time Calculation:
		;256 loops * 3 ops per loop = 768 / 2M ops = 384us per run
		;(768 + 3/outer run) * # outer runs  / 2M = Time in ms

FIRST_DELAY
		movlw	0xff;			;384us 
		movwf	DELAYL			;low bits
		movlw	0x05;
		movwf	DELAYH			;high bits

		CALL	delay_gen		;delay for 1.926ms

		bsf		PORTA,4			;put a one

	
SECOND_DELAY					;aprox 75ms pulse for RA4
		movlw	0xff				
		movwf 	DELAYL			;lower bits
		movlw	0xc3			;dec 195
		movwf	DELAYH			;high bits

		CALL	delay_gen

		clrf	TMR1L			;clear TMR1 Low, 6us
		clrf	TMR1H			;clear TMR1 High, 7us

		bcf		PORTA,4			;cleared, now have 750us until return pulse

		bsf		STATUS,RP0		;get to bank 1
		bcf		STATUS,RP1
		bsf		TRISA,4

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
;		btfss	PORTA,4			;is Pulse not here?
;		goto	WAIT_FOR_PULSE
WAIT_FOR_LOW_PULSE
;		btfsc	PORTA,4			;is Pulse still there?
;		goto	WAIT_FOR_LOW_PULSE

;Get Timer1 data ready for Serial routine
		movlw	0x21			;Identify Sensor
		movwf	STORETYPE

		movf	TMR1L,w			;get Timer1 Low Byte
		movwf	STORELOW		;store Timer1 Low Byte

		movf	TMR1H,w			;get Timer1 High Byte
		movwf	STOREHIGH		;store Timer1 High Byte

		CALL	SER_DATA_OUT

		bcf		STATUS,RP0		;get to bank 0
		bcf		STATUS,RP1		;get back to reg 0
THIRD_DELAY						;aprox 20ms wait
		movlw	0xff;
		movwf	DELAYL			;low bits, using timer regsiters to save space
		movlw	0xc3;
		movwf	DELAYH			;high bits

		CALL	delay_gen

		RETURN					;return for another value

		
