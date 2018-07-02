;Serial Storage Variables		
		cblock	0x120
STORETYPE						;place for data type identifier
STORELOW						;place for data low byte
STOREHIGH						;place for data high byte
		endc

;Serial Port Routin Orgs Here
		org	0790				;right now about as far away as I can get with direct addressing
								;will have to revise sometime later
SER_DATA_OUT
;1st BYTE, ascii check
		bcf		STATUS,RP0		;make sure in bank 0
		bcf		STATUS,RP1
		movlw	0xFB			;load ascii check
		movwf	TXREG			;send byte to TXREG
		bsf		STATUS,RP0		;get to bank 1
WAIT0
		btfss	TXSTA,1			;wait for data to TX
		goto	WAIT0			;could use $-1, PC-1, but kinda hard to follow
		bcf		STATUS,RP0		;get back to bank 0

;2nd BYTE, ascii check
		movwf	TXREG			;put data in reg
		bsf		STATUS,RP0		;get to bank 1
WAIT1							
		btfss	TXSTA,1			;again wait for byte to TX
		goto	WAIT1
		bcf		STATUS,RP0

;3rd BYTE, data type
		movfw	STORETYPE		;load data type from reg storetype, ASCII ! for test
								;interesting note: you can actually get addys from value locations by 
								;moving the label as a literal it seems...
		movwf	TXREG			;put data in reg
		bsf		STATUS,RP0		;get to bank 1
WAIT2
		btfss	TXSTA,1
		goto	WAIT2
		bcf		STATUS,RP0

;4th BYTE, data high byte
		movfw	STOREHIGH		;load HIGH Byte
		movwf	TXREG			;put data in reg
		bsf		STATUS,RP0		;get to bank 1
WAIT3
		btfss	TXSTA,1
		goto	WAIT3
		bcf		STATUS,RP0

;5th BYTE, data low byte
		movfw	STORELOW		;load LOW BYTE
		movwf	TXREG			;put data in reg
		bsf		STATUS,RP0		;get to bank 1
WAIT4
		btfss	TXSTA,1
		goto	WAIT4
		bcf		STATUS,RP0

;6th BYTE, end of data byte
		movlw	0x24			;load ascii $
		movwf	TXREG			;put data in reg
		bsf		STATUS,RP0		;get to bank 1
WAIT5
		btfss	TXSTA,1
		goto	WAIT5
		bcf		STATUS,RP0

		RETURN

