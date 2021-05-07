; LCD.s
; Student names: Alex Koo, Anthony Do
; Last modification date: change this to the last modification date or look very silly

; Runs on TM4C123
; Use I2C3 to send data to SSD1306 128 by 64 pixel oLED

; As part of Lab 7, students need to implement I2C_Send2

      EXPORT   I2C_Send2
      PRESERVE8
      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      ALIGN
		  
I2C3_MSA_R  EQU 0x40023000
I2C3_MCS_R  EQU 0x40023004
I2C3_MDR_R  EQU 0x40023008
; sends two bytes to specified slave
; Input: R0  7-bit slave address
;        R1  first 8-bit data to be written.
;        R2  second 8-bit data to be written.
; Output: 0 if successful, nonzero (error code) if error

; Assumes: I2C3 and port D have already been initialized and enabled
I2C_Send2
;; --UUU-- 
; 1) wait while I2C is busy, wait for I2C3_MCS_R bit 0 to be 0
	PUSH {R3,R4}
I2C_LABEL1
	LDR R3,=I2C3_MCS_R
	LDR R4, [R3]
	AND R4,R4,#0x01
	CMP R4, #0x01
	BEQ I2C_LABEL1
; 2) write slave address to I2C3_MSA_R, 
;     MSA bits7-1 is slave address
;     MSA bit 0 is 0 for send data
	LSL R0, #1
	AND R0, R0, #0xFE
	LDR R3,=I2C3_MSA_R
	STR R0, [R3]
; 3) write first data to I2C3_MDR_R
	LDR R3,=I2C3_MDR_R
	STR R1,[R3]
; 4) write 0x03 to I2C3_MCS_R,  send no stop, generate start, enable
; add 4 NOPs to wait for I2C to start transmitting
	MOV R3, #0x03
	LDR R4,=I2C3_MCS_R
	STR R3,[R4]
	NOP
	NOP
	NOP
	NOP
I2C_LABEL2
	LDR R3,=I2C3_MCS_R
	LDR R4, [R3]
	AND R4,R4,#0x01
	CMP R4, #0x01
	BEQ I2C_LABEL2
; 6) check for errors, if any bits 3,2,1 I2C3_MCS_R is high 
	LDR R3,=I2C3_MCS_R
	LDR R4, [R3]
	LSL R4, #1
	AND R4, R4, #0x07
	CMP R4, #0x00
	BEQ I2C_NO_ERROR
	
	;    b) if error return R0 equal to bits 3,2,1 of I2C3_MCS_R, error bits
	AND R0, R0, #0x00
	ORR R0,R4
	;    a) if error set I2C3_MCS_R to 0x04 to send stop 
	LDR R3,=I2C3_MCS_R
	MOV R4, #0x04
	STR R4, [R3]
	B I2C_END_FUNCTION

I2C_NO_ERROR
; 7) write second data to I2C3_MDR_R
	LDR R3,=I2C3_MDR_R
	STR R2,[R3]
; 8) write 0x05 to I2C3_MCS_R, send stop, no start, enable
; add 4 NOPs to wait for I2C to start transmitting
	MOV R3, #0x05
	LDR R4,=I2C3_MCS_R
	STR R3,[R4]
	NOP
	NOP
	NOP
	NOP
	
; 9) wait while I2C is busy, wait for I2C3_MCS_R bit 0 to be 0
I2C_LABEL3
	LDR R3,=I2C3_MCS_R
	LDR R4, [R3]
	AND R4,R4,#0x01
	CMP R4, #0x01
	BEQ I2C_LABEL3
; 10) return R0 equal to bits 3,2,1 of I2C3_MCS_R, error bits
;     will be 0 is no error
	LDR R4, [R3]
	LSL R4, #1
	AND R3, R3, #0x07
	CMP R4, #0x00
	BEQ I2C_NO_ERROR_2
	
	AND R0, R0, #0x00
	ORR R0,R4
	
	LDR R3,=I2C3_MCS_R
	MOV R4, #0x04
	STR R4,[R3]
	B I2C_END_FUNCTION

I2C_NO_ERROR_2
	MOV R0, #0x00

I2C_END_FUNCTION
	POP{R3,R4}
        

    BX  LR                          ;   return


    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file
 