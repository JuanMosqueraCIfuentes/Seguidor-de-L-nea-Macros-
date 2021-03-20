;******************************************************************************
;      ___           ___           ___           ___           ___            *
;     /  /\         /  /\         /__/\         /__/\         /  /\           *
;    /  /:/_       /  /::\       |  |::\       |  |::\       /  /::\          *
;   /  /:/ /\     /  /:/\:\      |  |:|:\      |  |:|:\     /  /:/\:\         *
;  /  /:/_/::\   /  /:/~/::\   __|__|:|\:\   __|__|:|\:\   /  /:/~/::\        *
; /__/:/__\/\:\ /__/:/ /:/\:\ /__/::::| \:\ /__/::::| \:\ /__/:/ /:/\:\       *
; \  \:\ /~~/:/ \  \:\/:/__\/ \  \:\~~\__\/ \  \:\~~\__\/ \  \:\/:/__\/       *
;  \  \:\  /:/   \  \::/       \  \:\        \  \:\        \  \::/            *
;   \  \:\/:/     \  \:\        \  \:\        \  \:\        \  \:\            *
;    \  \::/       \  \:\        \  \:\        \  \:\        \  \:\           *
;     \__\/         \__\/         \__\/         \__\/         \__\/           *
;                                                                             *
;******************************************************************************
;                                                                             *
;                                                                             *
;                                Description                                  *
;                                                                             *
;									      *
;******************************************************************************
;                                                                             *
;  Filename: Line Follower Robot in Assembly Language with MACROS                         *
;  Date:  19.03.21                                                            *
;  File Version: XC, PIC-as 2.31                                              *
;                                                                             *
;  Authors: Andres Juan Duran Valencia and Juan Sebastian Mosquera Cifuentes  *                                                            *
;  University: Universidad de Ibague                                          *
;                                                                             *
;******************************************************************************
;                                                                             *
;    FDEVICE: P16F877A                                                        *
;                                                                             *
;******************************************************************************

PROCESSOR 16F877A

#include <xc.inc>

; CONFIGURATION WORD PG 144 datasheet

CONFIG CP=OFF ; PFM and Data EEPROM code protection disabled
CONFIG DEBUG=OFF ; Background debugger disabled
CONFIG WRT=OFF
CONFIG CPD=OFF
CONFIG WDTE=OFF ; WDT Disabled; SWDTEN is ignored
CONFIG LVP=ON ; Low voltage programming enabled, MCLR pin, MCLRE ignored
CONFIG FOSC=XT
CONFIG PWRTE=ON
CONFIG BOREN=OFF
PSECT udata_bank0

max:
DS 1 ;reserve 1 byte for max

tmp:
DS 1 ;reserve 1 byte for tmp
PSECT resetVec,class=CODE,delta=2

resetVec:
    PAGESEL INISYS ;jump to the main routine
    goto INISYS

#define S_IZQ PORTB,0
#define S_CEN PORTB,1
#define S_DER PORTB,2
#define MIA PORTD,0
#define MIR PORTD,1
#define MDA PORTD,2
#define MDR PORTD,3
#define LR PORTD,4
#define LAI PORTD,5
#define LAD PORTD,6

PSECT code

AVANZAR MACRO
BSF MIA
BSF MDA
BCF MIR
BCF MDR
BCF LR
BCF LAI
BCF LAD
ENDM
 
DETENER MACRO
BCF MIA
BCF MDA
BCF MIR
BCF MDR
BSF LR
BCF LAI
BCF LAD
ENDM
 
GIRO_IZQUIERDA MACRO
BCF MIA
BSF MDA
BCF MIR
BCF MDR
BCF LR
BSF LAI
BCF LAD
ENDM
 
GIRO_DERECHA MACRO
BSF MIA
BCF MDA
BCF MIR
BCF MDR
BCF LR
BCF LAI
BSF LAD
ENDM

 RETROCEDER MACRO
BCF MIA
BCF MDA
BSF MIR
BSF MDR
BSF LR
BCF LAI
BCF LAD
ENDM
 
INISYS: 
    ;Cambio a Banco N1
    BCF STATUS, 6
    BSF STATUS, 5 ; Banco1
    ; Modificar TRIS
    BSF TRISB, 0    ; S_IZQ = PortB0 <- entrada
    BSF TRISB, 1    ; S_CEN = PortB1 <- entrada
    BSF TRISB, 2    ; S_DER = PortB2 <- entrada
    BCF TRISD, 0    ; MIA = PortD0 <- salida
    BCF TRISD, 1    ; MIR = PortD1 <- salida
    BCF TRISD, 2    ; MDA = PortD2 <- salida
    BCF TRISD, 3    ; MDR = PortD3 <- salida
    BCF TRISD, 4    ; LR = PortD4 <- salida
    BCF TRISD, 5    ; LAI = PortD5 <- salida
    BCF TRISD, 6    ; LAD = PortD6 <- salida
    ; Regresar a banco 0

    BCF STATUS, 5 ; Banco0
    
MAIN:
AVANCE:
 BTFSC S_IZQ
 GOTO STOP ;SI ES 1
 BTFSS S_CEN ;SI ES 0
 GOTO STOP ;SI ES 0
 BTFSC S_DER ;SI ES 1
 GOTO STOP ;SI ES 1
 AVANZAR ;SI ES 0
 GOTO MAIN
 
 STOP:
 BTFSS S_IZQ
 GOTO GIZQ ;SI ES 0
 BTFSS S_CEN ;SI ES 1
 GOTO GIZQ ;SI ES 0
 BTFSS S_DER ;SI ES 1
 GOTO GIZQ ;SI ES 0
 DETENER ;SI ES 1
 GOTO MAIN

GIZQ:
 BTFSS S_IZQ
 GOTO GDER ;SI ES 0
 BTFSC S_DER ;SI ES 1
 GOTO GDER ;SI ES 1
 GIRO_IZQUIERDA ;SI ES 0
 GOTO MAIN

 GDER:
 BTFSC S_IZQ
 GOTO RET ;SI ES 1
 BTFSS S_DER ;SI ES 0
 GOTO RET ;SI ES 0
 GIRO_DERECHA ;SI ES 1
 GOTO MAIN

 RET:
 BTFSC S_IZQ
 GOTO MAIN ;SI ES 1
 BTFSC S_CEN ;SI ES 0
 GOTO MAIN ;SI ES 1
 BTFSC S_DER ;SI ES 0
 GOTO MAIN ;SI ES 1
 RETROCEDER ;SI ES 0
 GOTO MAIN 
 
    END resetVec


