;This is test code for the Serial Ports on the PIC microcontroller
;for now all it will do is send a predefined byte
;
#include <p16F690.inc>
	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOD_OFF & _IESO_OFF & _FCMEN_OFF)
		cblock	0x120
STORETYPE						;place for data type identifier
STORELOW						;place for data low byte
STOREHIGH						;place for data high byte
		endc

		org 0
Init_PIC
		bsf		STATUS,RP0		;-------------
		bcf		STATUS,RP1		;get to bank 1
		movlw	b'01110001'		;internal clock, 2MHz OSC, 1MHz system, 1us per tick
		movwf	OSCCON

Init_Serial						;get ASYNC running
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


DATA_INIT
		movlw	0x21
		movwf	STORETYPE
		movlw	0x41
		movwf	STOREHIGH
		movlw	0x42
		movwf	STORELOW

;TEST CODE
AGAIN	CALL	SER_DATA_OUT

		goto	AGAIN



		org	0792				;right now about as far away as I can get with direct addressing
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
		goto	WAIT0
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
		end
	
