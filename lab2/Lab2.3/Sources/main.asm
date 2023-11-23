;********************************************************************
;* Endless Beeping Program                                          *
;* This program just endlessly sounds the buzzer on the trainer     *
;* board.                                                           *
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
            LDAA  #%10000000      ;Loads Acc.A with bit mask for PP7
        
MainLoop    STAA  PTP         ;Sends high signal to port P, PP7 because of mask
            LDX   #$1FFF      ;Starts loop counter (8191) 
                              ;Delay Loop controls frequency of Beeps (F = 1/T)
Delay       DEX               ;Decrement X   : 1 clk
            BNE   Delay       ;Branch X != 0 : 3 clk/1clk at end
            EORA  #%10000000  ;XOR MSB of A (if 1 -> 0, else -> 1)
            BRA   MainLoop    ;Branch to MainLoop
            SWI               ;Software Interupt.(Break to monitor)
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
