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
; PICkit 2 Lesson 9 - Timer 0
;
; Lesson 9 shows how to configure and use the Timer0 peripheral to
; implementn the delay function used in earlier lessons.

#include <p16F690.inc>
	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOD_OFF & _IESO_OFF & _FCMEN_OFF)

	cblock	0x20
Display
Delay1
Timer
	endc
	cblock 0x30
TEST
	endc

	org 0
Start
	bsf	STATUS,RP0
	movlw	b'00000111'	; configure Timer0.  Sourced from the Processor clock;
	movwf	OPTION_REG	; Maximum Prescaler 1/256
	clrf	TRISC		; Make PortC all output
	clrf	Display
	clrf	Delay1
	clrf	TEST
	bcf	STATUS,RP0

MainLoop								;~1 sec period
	incf	Display,1					; increment display variable directly
	movf	Display,w					; send to the LEDs
	movwf	PORTC
	;test init
	movlw	0x02						;more delay scalar, about 1 sec with 1MHz system clk and max prescale in option_reg
	movwf	Delay1						;1 run = ~65.536ms added or subtracted

InnerLoop
	decfsz Delay1,f
	goto CoreLoop						;skip only if zero
	goto MainLoop
	
CoreLoop						;~256us per cyle * 256 cyles = ~65.536ms period per run - clock is 1MHz
	btfss	INTCON,T0IF			;wait here until Timer0 rolls over
	goto	CoreLoop			;cont if not zero
	bcf	INTCON,T0IF				;flag must be cleared in software		
	goto InnerLoop	

end								


;ForeverLoop
;	btfss	INTCON,T0IF	; wait here until Timer0 rolls over
;	goto	ForeverLoop
;	bcf	INTCON,T0IF	; flag must be cleared in software
;	incf	Display,f	; increment display variable
;	movf	Display,w	; send to the LEDs
;	movwf	PORTC
;	goto	ForeverLoop
;	end
