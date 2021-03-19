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
;  Date:  14.03.21                                                            *
;  File Version: XC, PIC-as 2.31                                              *
;                                                                             *
;  Authors: Andrès Juan Duràn Valencia and Juan Sebastian Mosquera Cifuentes  *                                                            *
;  University: Universidad de Ibaguè                                          *
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

RETROCEDER MACRO
BCF MIA
BCF MDA
BSF MIR
BSF MDR
BSF LR
BCF LAI
BCF LAD
ENDM

G_IZQ MACRO
BCF MIA
BSF MDA
BCF MIR
BCF MDR
BCF LR
BSF LAI
BCF LAD
ENDM
 
G_DER MACRO
BSF MIA
BCF MDA
BCF MIR
BCF MDR
BCF LR
BCF LAI
BSF LAD
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

;AVANZAR
BTFSC S_IZQ
GOTO STP ;Si es 1
BTFSS S_CEN
GOTO STP ;Si es 0
BTFSC S_DER
GOTO STP ; Si es 1
AVANZAR
GOTO MAIN

;DETENER
STP:
BTFSS S_IZQ
GOTO RET ; Si es 0
BTFSS S_CEN
GOTO RET ; Si es 0
BTFSS S_DER
GOTO RET ; Si es 0
DETENER
GOTO MAIN
    
;RETROCEDER
RET:
BTFSC S_IZQ
GOTO GIZQ ; Si es 1
BTFSC S_CEN
GOTO GIZQ ; Si es 1
BTFSC S_DER
GOTO GIZQ ; Si es 1
RETROCEDER
GOTO MAIN
    
;GIRO_IZQUIERDA
GIZQ:
BTFSS S_IZQ
GOTO GDER ; Si es 0
BTFSC S_DER
GOTO GDER ; Si es 1
G_IZQ
GOTO MAIN
    
;GIRO_DERECHA    
GDER:
BTFSC S_IZQ
GOTO MAIN ; Si es 1
BTFSS S_DER
GOTO MAIN ; Si es 0
G_DER
GOTO MAIN

END resetVec


