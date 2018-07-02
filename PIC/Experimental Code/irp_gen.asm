;This code reads IR pairs
;
;
	org	0x0450
irp_gen
		bcf		STATUS,RP0		;-------------
		bcf		STATUS,RP1		;get to bank 0
IR1_TEST
		btfsc	PORTC,4		;is PIN clear?
		goto	IR1IS_SET	;no, is set

IR1IS_CLR
		movlw	0xB0
		movwf	STORETYPE
		
		movlw	0x4F		;ASCII O
		movwf	STOREHIGH

		movlw	0x50		;ASCII P
		movwf	STORELOW

		CALL 	SER_DATA_OUT
		
		goto	IR2_TEST

IR1IS_SET
		movlw	0xB0
		movwf	STORETYPE
		
		movlw	0x49		;ASCII I
		movwf	STOREHIGH

		movlw	0x4E		;ASCII N
		movwf	STORELOW

		CALL 	SER_DATA_OUT

IR2_TEST
		btfsc	PORTC,5		;is PIN clear?
		goto	IR2IS_SET	;no, is set

IR2IS_CLR
		movlw	0xB4
		movwf	STORETYPE
		
		movlw	0x4F		;ASCII O
		movwf	STOREHIGH

		movlw	0x50		;ASCII P
		movwf	STORELOW

		CALL 	SER_DATA_OUT
		
		goto	IR_TEST_END

IR2IS_SET
		movlw	0xB4
		movwf	STORETYPE
		
		movlw	0x49		;ASCII I
		movwf	STOREHIGH

		movlw	0x4E		;ASCII N
		movwf	STORELOW

		CALL 	SER_DATA_OUT
IR_TEST_END

		RETURN
