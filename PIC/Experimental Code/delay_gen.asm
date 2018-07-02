;****A simple delay routine for the PIC
;This will be used in many thing to delay
;execution of code
		cblock 0x20
DELAYL
DELAYH
		endc
		org		0x0150
delay_gen
		bcf		STATUS,RP0		;get to bank 0
		bcf		STATUS,RP1		;get back to reg 0
DELAY_LOOP0						;lower bits max delay of 384us (256 loops * 500ns per loop * 3 
								;instructions per loop
		movf	0x01;DELAYL,w
		movwf	TMR0			;low bits, using timer regsiters to save space
		movf	0x01;DELAYH,w
		movwf	TMR2			;high bits

		;Time Calculation:
		;256 loops * 3 ops per loop = 768 / 2M ops = 384us per run
		;(768 + 3/outer run) * # outer runs  / 2M = Time Delayed in ms

	DEC_LOW0
;		decfsz	TMR0			;3 instructions per loop
;		goto	DEC_LOW0

	DEC_HIGH0
;		decfsz	TMR2			;3 more instructions per loop in addition to inner loop
;		goto	DEC_LOW0
		
		RETURN
