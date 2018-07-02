;This code is for general a2d conversions for most of the sensors
;we will use. 
	cblock 0x26
A2DCH					;identifies which A2D ch to use
						;MAKE SURE THIS IS AN ANALOG SOURCE 
						;THAT IS SELECTED! IF A2D CH selected is on
						;a pin that is configured as a digi i/o it		
						;can burn the chip!
A2DCON
	endc
		
	org 0x0350
a2d_sub
	bcf		STATUS,RP0	;
	bcf		STATUS,RP1	;get to Bank 0
	movf	A2DCH,w		;get which analog ch
	movwf	ADCON0		;configure A2D for Channel, Left justified
	bsf		ADCON0,0	;turn on A2D
	nop					;wait 5us for A2D amp to settle and capacitor to charge.
	nop					;wait 1uS
	nop					;wait 
	nop					;wait 2uS
	nop					;wait 
	nop					;3us
	nop
	nop					;4us
	nop
	nop					;5us
	nop
	nop					;6us
	bsf		ADCON0,GO	;start conversion
	btfss	ADCON0,GO	;this bit will change to zero when the conversion is complete
	goto	$-1			;keep waiting until the conversion is completed

;Setup Data for serial_io
		movf	A2DCH,w			;Identify Sensor, probably use A2DCH value for this...
		movwf	STORETYPE

		movf	ADRESH,w		;get AD High Byte
		movwf	STOREHIGH		;store AD High Byte

		bsf		STATUS,RP0		;
		bcf		STATUS,RP1		;get to Bank 1 for low byte

		movf	ADRESL,w		;get AD Low Byte
		movwf	STOREHIGH		;store AD Low Byte

		CALL	SER_DATA_OUT	;send the data

		RETURN
	
