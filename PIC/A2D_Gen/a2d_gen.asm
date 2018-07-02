;This code is for general a2d conversions for most of the sensors
;we will use. 

#include <p16F690.inc>
	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOD_OFF & _IESO_OFF & _FCMEN_OFF)

	cblock 0x20
A2DCH					;identifies which A2D ch to use
						;MAKE SURE THIS IS AN ANALOG SOURCE 
						;THAT IS SELECTED! IF A2D CH selected is on
						;a pin that is configured as a digi i/o it		
						;can burn the chip!
	endc
		
	org 0
a2d_sub
	bcf		STATUS,RP0	;
	bcf		STATUS,RP1	;get to Bank 0
	movlw	A2DCH
	movwf	ADCON0		;configure A2D for Channel 0 (RA0), Left justified, and turn on the A2D module
	nop					;wait 5uS for A2D amp to settle and capacitor to charge.
	nop					;wait 1uS
	nop					;wait 1uS
	nop					;wait 1uS
	nop					;wait 1uS
	bsf		ADCON0,GO	;start conversion
	btfss	ADCON0,GO	;this bit will change to zero when the conversion is complete
	goto	$-1			;keep waiting until the conversion is completed

;Setup Data for serial_io
		movlw	0x21			;Identify Sensor, probably use A2DCH value for this...
		movwf	STORETYPE

		movf	ADRESH,w		;get AD High Byte
		movwf	STOREHIGH		;store AD High Byte

		bsf		STATUS,RP0		;
		bcf		STATUS,RP1		;get to Bank 1 for low byte

		movf	ADRESL,w		;get AD Low Byte
		movwf	STOREHIGH		;store AD Low Byte

		CALL	SER_DATA_OUT	;send the data

		RETURN
	
