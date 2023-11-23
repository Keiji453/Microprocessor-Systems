;********************************************************************
;* Keypad to LED Output Program                                     *
;* This program takes the values from the keypad on the bench and   *
;* outputs a different LED colour based on the key pressed          *
;* Author: Joauqin Kataoka                                          *
;********************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		        INCLUDE 'derivative.inc'
;********************************************************************
;* Code section                                                     *
;********************************************************************	 
            ORG $3000
;********************************************************************
;* Actual Code Starts Here                                          *
;******************************************************************** 
            ORG $4000
Entry:
_Startup:                         ;Data Direction Register -> determines whether pin is In or Out
            BSET  DDRP,%11111111  ;Configures all pins of port P for output.
            BSET  DDRE,%00010000  ;Configure only pin PE4 for output (PE4 is keypad clock)
            BCLR  PORTE,%00010000 ;Enables Keypad
                                  ;Clears pin PE4? PE4 -> 0
Loop:       LDAA  PTS   ;Loads Acc.A with value from Keypad
            LSRA        ;Shift Right Acc.a
            LSRA        ;      _"_
            LSRA        ;      _"_
            LSRA        ;      _"_
            STAA  PTP   ;Store Acc.A value to LED2
            BRA   Loop  ;Branch Unconditionally to start of loop.
            SWI         ;Software Interupt.(Break to monitor)
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
