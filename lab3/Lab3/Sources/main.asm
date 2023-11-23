;*****************************************************************
;*        EEBot A/D Voltage and Bumper Detection Program         *
;* This program is a program that reads the Analog to Digital    *
;* converter from the analog pot on the EEbot and outputs the    *
;* the value on the LCD. It also relays the status of the        *
;* bumper switches.                                              *
;* Author: JKataoka                                              *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 
;*****************************************************************
;* Displaying battery voltage and bumper states (s19c32)         *
;*****************************************************************
; Definitions
LCD_DAT     EQU   PORTB   ;LCD data port, bits - PB7,...,PB0
LCD_CNTR    EQU   PTJ     ;LCD control port, bits - PE7(RS),PE4(E)
LCD_E       EQU   $80     ;LCD E-signal pin
LCD_RS      EQU   $40     ;LCD RS-signal pin

BUMPER_BOW  EQU   %00000100     ;Pin-code for Bow Bumper
BUMPER_STERN  EQU %00001000     ;Pin-code for Stern Bumper

; Variable/data section
            ORG   $3850
TEN_THOUS   RMB   1       ;10,000 digit
THOUSANDS   RMB   1       ;1,000 digit
HUNDREDS    RMB   1       ;100 digit
TENS        RMB   1       ;10 digit
UNITS       RMB   1       ;1 digit
NO_BLANK    RMB   1       ;Used in ’leading zero’ blanking by BCD2ASC
; Code section
            ORG   $4000
Entry:
_Startup:
            LDS   #$4000          ;initialize the stack pointer
            JSR   initAD          ;initialize ATD converter
            JSR   initLCD         ;initialize LCD
            JSR   clrLCD          ;clear LCD & home cursor
            
            LDX   #msg1           ;display msg1
            JSR   putsLCD         ;    "
            LDAA  #$C0            ;move LCD cursor to the 2nd row
            JSR   cmd2LCD
            LDX   #msg2           ;display msg2
            JSR   putsLCD         ;    "
            
lbl         MOVB  #$90,ATDCTL5    ;r.just., unsign., sing.conv., mult., ch0, start conv.
            BRCLR ATDSTAT0,$80,*  ;wait until the conversion sequence is complete
            
            LDAA  ATDDR4L           ;load the ch4 result into AccA
            LDAB  #39              ;AccB = 39
            MUL                    ;AccD = 1st result x 39
            ADDD  #600             ;AccD = 1st result x 39 + 600

            JSR   int2BCD         ;Converts battery voltage to binary coded decimal
            JSR   BCD2ASC         ;Converts the BCD Value of voltage reading to ASCII
            
            LDAA  #$8F            ;move LCD cursor to the 1st row, end of msg1
            JSR   cmd2LCD         ; "

            LDAA  TEN_THOUS       ;output the TEN_THOUS ASCII character
            JSR   putcLCD         ;           "
           
            LDAA  THOUSANDS       ;output the THOUSANDS ASCII character
            JSR   putcLCD
            
            LDAA  #'.'            ;output the decimal ASCII character
            JSR   putcLCD
            
            LDAA  HUNDREDS        ;output the HUNDREDS ASCII character
            JSR   putcLCD    
            
            LDAA  #$CF            ;move LCD cursor to the 2nd row, end of msg2
            JSR   cmd2LCD         ;         "

            BRCLR PORTAD0,BUMPER_BOW,bowON  ;Branch if clear *Checks specifically bumper pin
            LDAA  #$31            ;output ’1’ if bow sw OFF
            BRA   bowOFF
bowON       LDAA  #$30            ;output ’0’ if bow sw ON
bowOFF      JSR   putcLCD

            LDAA  #' '            ;output a space ASCII character
            JSR   putcLCD

            BRCLR PORTAD0,#BUMPER_STERN,sternON
            LDAA  #$31            ;output ’1’ if stern sw OFF
            BRA   sternOFF
sternON     LDAA  #$30            ;output ’0’ if stern sw ON
sternOFF    JSR   putcLCD
            JMP lbl
msg1 dc.b "Battery volt ",0
msg2 dc.b "Sw status ",0
; Subroutine section
;*******************************************************************
;* Initialization of the LCD: 4-bit data width, 2-line display,    *
;* turn on display, cursor and blinking off. Shift cursor right.   *
;*******************************************************************
initLCD     BSET  DDRB,%11111111  ; configure pins PB7 to PB0 for output *Had to change to account for pins on HCS9C32
            BSET  DDRJ,%11000000  ; configure pins PJ7,PJ6 for output
            LDY   #2000           ; wait for LCD to be ready
            JSR   del_50us        ; -"-
            LDAA  #$28            ; set 4-bit data, 2-line display
            JSR   cmd2LCD         ; -"-
            LDAA  #$0C            ; display on, cursor off, blinking off
            JSR   cmd2LCD         ; -"-
            LDAA  #$06            ; move cursor right after entering a character
            JSR   cmd2LCD         ; -"-
            RTS
;*******************************************************************
;* Clear display and home cursor *
;*******************************************************************
clrLCD      LDAA  #$01            ; clear cursor and return to home position
            JSR   cmd2LCD         ; -"-
            LDY   #40             ; wait until "clear cursor" command is complete
            JSR   del_50us        ; -"-
            RTS
;*******************************************************************
;* ([Y] x 50us)-delay subroutine. E-clk=41,67ns. *
;*******************************************************************
del_50us:   PSHX            ;2 E-clk - Push X onto Stack
eloop:      LDX   #30       ;2 E-clk -
iloop:      PSHA            ;2 E-clk |
            PULA            ;3 E-clk |
          
            PSHA            ;2 E-clk |Roughly 50us delay
            PULA            ;3 E-clk |about 47.5us delay
            PSHA            ;2 E-clk |exact number of added
            PULA            ;3 E-clk |E-clks would need to be
            PSHA            ;2 E-clk |about 22.33 E-clk
            PULA            ;3 E-clk |
            PSHA            ;2 E-clk |
            PULA            ;3 E-clk |
            NOP             ;1 E-clk |
            NOP             ;1 E-clk |
            NOP             ;1 E-clk |
                      
            PSHA            ;2 E-clk | 50us
            PULA            ;3 E-clk |
            NOP             ;1 E-clk |
            NOP             ;1 E-clk |
            DBNE  X,iloop   ;3 E-clk -
            DBNE  Y,eloop   ;3 E-clk
            PULX            ;3 E-clk - Get Value of X back from stack
            RTS             ;5 E-clk
;*******************************************************************
;* This function sends a command in accumulator A to the LCD *
;*******************************************************************
cmd2LCD:    BCLR  LCD_CNTR,LCD_RS ; select the LCD Instruction Register (IR)
            JSR   dataMov         ; send data to IR
            RTS
            
;*******************************************************************
;* This function puts value from acc X to LCD                      *
;*******************************************************************            
putsLCD     LDAA  1,X+      ; get one character from the string
            BEQ   donePS    ; reach NULL character?
            JSR   putcLCD
            BRA   putsLCD
donePS      RTS
;*******************************************************************
;* This function outputs the character in accumulator in A to LCD *
;*******************************************************************
putcLCD     BSET  LCD_CNTR,LCD_RS ; select the LCD Data register (DR)
            JSR   dataMov         ; send data to DR
            RTS
dataMov     BSET  LCD_CNTR,LCD_E  ; pull the LCD E-sigal high
            STAA  LCD_DAT         ; send the upper 4 bits of data to LCD
            BCLR  LCD_CNTR,LCD_E  ; pull the LCD E-signal low to complete the write oper.
            LSLA                  ; match the lower 4 bits with the LCD data pins
            LSLA                  ; -"-
            LSLA                  ; -"-
            LSLA                  ; -"-
            BSET  LCD_CNTR,LCD_E  ; pull the LCD E signal high
            STAA  LCD_DAT         ; send the lower 4 bits of data to LCD
            BCLR  LCD_CNTR,LCD_E  ; pull the LCD E-signal low to complete the write oper.
            LDY   #1              ; adding this delay will complete the internal
            JSR   del_50us        ; operation for most instructions
            RTS
;*******************************************************************
;* This function Converts Integer in Acc A to Binary Coded Decimal *
;*******************************************************************
int2BCD     XGDX                  ;Save the binary number into .X
            LDAA  #0              ;Clear the BCD_BUFFER
            STAA  TEN_THOUS
            STAA  THOUSANDS
            STAA  HUNDREDS
            STAA  TENS
            STAA  UNITS


            CPX   #0               ;Check for a zero input
            BEQ   CON_EXIT         ;and if so, exit

            XGDX                   ;Not zero, get the binary number back to .D as dividend
            LDX   #10              ;Setup 10 (Decimal!) as the divisor
            IDIV                   ;Divide: Quotient is now in .X, remainder in .D
            STAB  UNITS            ;Store remainder
            CPX   #0               ;If quotient is zero,
            BEQ   CON_EXIT         ;then exit

            XGDX                   ;else swap first quotient back into .D
            LDX   #10              ;and setup for another divide by 10
            IDIV
            STAB  TENS
            CPX   #0
            BEQ   CON_EXIT

            XGDX                   ;Swap quotient back into .D
            LDX   #10              ;and setup for another divide by 10
            IDIV
            STAB  HUNDREDS
            CPX   #0
            BEQ   CON_EXIT

            XGDX                   ;Swap quotient back into .D
            LDX   #10              ;and setup for another divide by 10
            IDIV
            STAB  THOUSANDS
            CPX   #0
            BEQ   CON_EXIT

            XGDX                   ;Swap quotient back into .D
            LDX   #10              ;and setup for another divide by 10
            IDIV
            STAB  TEN_THOUS

CON_EXIT    RTS                    ;We’re done the conversion
;*******************************************************************
;* This function Converts Binary Coded Decimal to ASCII Value      *
;*******************************************************************
BCD2ASC     LDAA  #0               ;Initialize the blanking flag
            STAA  NO_BLANK

C_TTHOU     LDAA  TEN_THOUS        ;Check the ’ten_thousands’ digit
            ORAA  NO_BLANK
            BNE   NOT_BLANK1

ISBLANK1    LDAA  #' '             ;It’s blank
            STAA  TEN_THOUS        ;so store a space
            BRA   C_THOU           ;and check the ’thousands’ digit

NOT_BLANK1  LDAA  TEN_THOUS        ;Get the ’ten_thousands’ digit
            ORAA  #$30             ;Convert to ascii
            STAA  TEN_THOUS
            LDAA  #$1              ;Signal that we have seen a ’non-blank’ digit
            STAA  NO_BLANK

C_THOU      LDAA  THOUSANDS        ;Check the thousands digit for blankness
            ORAA  NO_BLANK         ;If it’s blank and ’no-blank’ is still zero
            BNE   NOT_BLANK2

ISBLANK2    LDAA  #' '             ;Thousands digit is blank
            STAA  THOUSANDS        ;so store a space
            BRA   C_HUNS           ;and check the hundreds digit

NOT_BLANK2  LDAA  THOUSANDS        ;(similar to ’ten_thousands’ case)
            ORAA  #$30
            STAA  THOUSANDS
            LDAA  #$1
            STAA  NO_BLANK

C_HUNS      LDAA  HUNDREDS         ;Check the hundreds digit for blankness
            ORAA  NO_BLANK         ;If it’s blank and ’no-blank’ is still zero
            BNE   NOT_BLANK3

ISBLANK3    LDAA  #' '             ;Hundreds digit is blank
            STAA  HUNDREDS         ;so store a space
            BRA   C_TENS           ;and check the tens digit

NOT_BLANK3  LDAA  HUNDREDS         ;(similar to ’ten_thousands’ case)
            ORAA  #$30
            STAA  HUNDREDS
            LDAA  #$1
            STAA  NO_BLANK
C_TENS      LDAA  TENS             ;Check the tens digit for blankness
            ORAA  NO_BLANK         ;If it’s blank and ’no-blank’ is still zero
            BNE   NOT_BLANK4

ISBLANK4    LDAA  #' '             ;Tens digit is blank
            STAA  TENS             ;so store a space
            BRA   C_UNITS          ;and check the units digit

NOT_BLANK4  LDAA  TENS             ;(similar to ’ten_thousands’ case)
            ORAA  #$30
            STAA  TENS

C_UNITS     LDAA  UNITS            ;No blank check necessary, convert to ascii.
            ORAA  #$30
            STAA  UNITS

            RTS                    ;We’re done

;*******************************************************************
;* This function Intiates the A/D Converter                        *
;*******************************************************************
initAD      MOVB  #$C0,ATDCTL2      ;power up AD, select fast flag clear
            JSR   del_50us            ;wait for 50 us
            MOVB  #$00,ATDCTL3       ;8 conversions in a sequence
            MOVB  #$85,ATDCTL4       ;res=8, conv-clks=2, prescal=12
            BSET  ATDDIEN,$0C        ;configure pins AN03,AN02 as digital inputs
            RTS

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
