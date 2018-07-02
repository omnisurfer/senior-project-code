;******************************************************************************
;Software License Agreement                                         
;                                                                    
;The software supplied herewith by Microchip Technology             
;Incorporated (the "Company") is intended and supplied to you, the  
;Company’s customer, for use solely and exclusively on Microchip    
;products. The software is owned by the Company and/or its supplier,
;and is protected under applicable copyright laws. All rights are   
;reserved. Any use in violation of the foregoing restrictions may   
;subject the user to criminal sanctions under applicable laws, as   
;well as to civil liability for the breach of the terms and         
;conditions of this license.                                        
;                                                                    
;THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES,  
;WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED  
;TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A       
;PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,  
;IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR         
;CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.       
; *******************************************************************

; PICkit 2 Lesson 12 - Table lookup
;
; This shows using a table lookup function to implement a 
; binary to gray code conversion.  The Pot is read by the A2D, 
; The high order 4 bits then are converted to Gray Code and
; displayed on the LEDs.
;

#include <p16F690.inc>
	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOD_OFF & _IESO_OFF & _FCMEN_OFF)

	cblock 0x20
temp
	endc

	org 0	
Start
	bsf	STATUS,RP0	; select Register Page 1
	movlw	0xFF
	movwf	TRISA		; Make PortA all input
	clrf	TRISC		; Make PortC all output
	movlw	0x10		; A2D Clock Fosc/8
	movwf	ADCON1
	bcf	STATUS,RP0	; back to Register Page 0

	bcf	STATUS,RP0	; address Register Page 2
	bsf	STATUS,RP1	
	movlw	0xFF		; we want all Port A pins Analoga
	movwf	ANSEL
	bcf	STATUS,RP0	; address Register Page 0
	bcf	STATUS,RP1
	
	movlw	0x01
	movwf	ADCON0		; configure A2D for Channel 0 (RA0), Left justified, and turn on the A2D module
MainLoop
	bsf	ADCON0,GO	; start A2D conversion
	btfss	ADCON0,GO	; wait until the conversion is complete
	goto	$-1

	swapf	ADRESH,w	; read the A2D, move the high nybble to the low part
	call	BinaryToGrayCode ; Convert to Gray Code
	movwf	PORTC		; into the low order nybble on Port C
	goto	MainLoop
	
		
; Convert 4 bit binary to 4 bit Gray code
; 
	org	0xf7	; force table to cross a page boundary
BinaryToGrayCode
	andlw	0x0F		; mask off invalid entries
	movwf	temp
	movlw	high TableStart	; get high order part of the beginning of the table
	movwf	PCLATH
	movlw	low TableStart	; load starting address of table
	addwf	temp,w		; add offset
	btfsc	STATUS,C	; did it overflow?
	incf	PCLATH,f	; yes: increment PCLATH
	movwf	PCL		; modify PCL
TableStart
	retlw	b'0000'	; 0
	retlw	b'0001'	; 1
	retlw	b'0011'	; 2
	retlw	b'0010'	; 3
	retlw	b'0110'	; 4
	retlw	b'0111'	; 5
	retlw	b'0101'	; 6
	retlw	b'0100'	; 7
	retlw	b'1100'	; 8
	retlw	b'1101' ; 9
	retlw	b'1111'  ; 10
	retlw	b'1110'  ; 11
	retlw	b'1010'  ; 12
	retlw	b'1011'  ; 13
	retlw	b'1001'  ; 14
	retlw	b'1000'  ; 15
	end
