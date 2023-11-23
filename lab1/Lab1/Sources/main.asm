;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
; This program does unsigned multiplication between 2, 1 byte values MULIPLICAND and MULTIPLIER
; the values are stored in the 2 byte location PRODUCT.
		INCLUDE 'derivative.inc'
		          ORG $3000 
MULTIPLICAND  FCB 05;SETS MULTIPLCAND VARIABLE TO VALUE  
MULTIPLIER    FCB 08;SETS MULTIPLIER VARAIBLE TO VALUE
PRODUCT       RMB 2 ;CREATES SPACE IN MEMORY MEANT TO STORE MULTIPLCATION
              ORG $4000
Entry:
_Startup:
              LDAA  MULTIPLICAND;LOADS ACCUMULATOR A WITH MULTIPLICAND VALUE
              LDAB  MULTIPLIER  ;LOADS ACCUMULCATOR B WITH MULTIPLIER VALUE
              MUL               ;MULTIPLIES VALUE OF A WITH B STORES ACROSS A:B   
              STD   PRODUCT 
              SWI

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
