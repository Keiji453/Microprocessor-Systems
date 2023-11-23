;*****************************************************************
;*        EEBot Movement demo program                            *
;* This program has the motor controls needed for future labs    *
;* Author: JKataoka                                              *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc'
		        ORG $4000 
Entry:
_Startup:
;************************************************************
;* Motor Control *Section 1                                 *
;************************************************************          
            BSET  DDRA,%00000011  ;Intializes Motor Direction Ports for output
            BSET  DDRT,%00110000  ;Intializes Motor Power Ports for Output
            JSR   STARFWD
            JSR   PORTFWD
            JSR   STARON
            JSR   PORTON
            JSR   STARREV
            JSR   PORTREV
            JSR   STAROFF
            JSR   PORTOFF
            BRA   *
           

;subroutine section          
STARON      LDAA  PTT         ;GET CURRENT PORT VALUES
            ORAA  #%00100000  ;PT5 STAR 0 FORWARD, 1 REVERSE
            STAA  PTT         ;UPDATE PORT VALUES
            RTS
          
STAROFF     LDAA  PTT         ;GET CURRENT PORT VALUES
            ANDA  #%11011111  ;PT5 STAR 0 FORWARD, 1 REVERSE
            STAA  PTT         ;UPDATE PORT VALUES
            RTS
          
STARFWD     LDAA  PORTA       ;GET CURRENT PORT VALUES
            ANDA  #%11111101  ;PA1 STAR 0 forward, 1 reverse
            STAA  PORTA       ;UPDATE PORT VALUES
            RTS
          
STARREV     LDAA  PORTA       ;GET CURRENT PORT VALUES
            ORAA  #%00000010  ;PA1 STAR 0 forward, 1 reverse
            STAA  PORTA         ;UPDATE PORT VALUES
            RTS
          
PORTON      LDAA  PTT         ;GET CURRENT PORT VALUES
            ORAA  #%00010000  ;PT4 PORT 0 OFF, 1 ON
            STAA  PTT         ;UPDATE PORT VALUES
            RTS
PORTOFF     LDAA  PTT         ;GET CURRENT PORT VALUES
            ANDA  #%11101111  ;PT4 PORT 0 OFF, 1 ON
            STAA  PTT         ;UPDATE PORT VALUES
            RTS

PORTFWD     LDAA  PORTA       ;GET CURRENT PORT VALUES
            ANDA  #%11111110  ;PA0 PORT 0 FWD, 1 REV
            STAA  PORTA       ;UPDATE PORT VALUES
            RTS
            
PORTREV     LDAA  PORTA       ;GET CURRENT PORT VALUES
            ORAA  #%00000001  ;PA0 PORT 0 FWD, 1 REV
            STAA  PORTA   ;In the manual Port H is used to emulated Port A
            RTS


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
