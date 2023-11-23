;********************************************************************
;* Switch to LED Output Program                                     *
;* This program takes values from toggle switches on a trainer      *
;* board and outputs a relevant LED colour                          *
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
_Startup:
            LDAA  #$FF  ;Load Acc.A with 1111 1111
            STAA  DDRH  ;Stores value of Acc.A to Port H.
                        ;In this case this configures all pins of H to output
            STAA  PERT  ;
           
Loop:       LDAA  PTT   ;Loads Acc.A with pin value of port T
            STAA  PTH   ;Sends read values from port T to port H
            BRA   Loop  ;Unconditionally branches back to start of loop.
            SWI         ;Software Interupt.(Break to monitor)
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
