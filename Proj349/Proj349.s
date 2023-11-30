			area Lab6, code, readonly
RS			equ 0x20	; RS connects to P3.5
RW			equ 0x40	; RW connects to P3.6
EN			equ 0x80	; EN connects to P3.7

; Define some constants for player and obstacle positions
PLAYER_START_POSITION    EQU 0x80  ; Top left corner
OBSTACLE_START_POSITION  EQU 0x8F  ; Top right corner

; Initialize player and obstacle positions
    MOV R12, #0x80 ;PLAYER_START_POSITION
    MOV R11, #0x8F;OBSTACLE_START_POSITION
    MOV R10, #0x00  ; Initialize the obstacle flag
;;R0
;;R1
;;R2 - LCDCommand
;;R3 - LCDWrite
;;R4 - 
;;R5 - 
;;R6 - Obs lane
;;R7 - Button press 
;;R8 - Holding button adress
;;R9
;;R10 - DNC - obs. flag
;;R11 - DNC - obs. pos.
;;R12 - DNC - player pos.


			export __main

__main		proc	

			
			BL LCDInit
			
		MOV R2, #0x80 ;sending hex code
		BL LCDCommand
		MOV R3, #'O'  ; Player position
		BL LCDData
		mov r3, #0
            		
;stay B stay	
GameLoop
    ; Check if a button has been pressed (you'll need to implement this)
    BL GameDelay
	
	LDR R8, =0x40004C00
	
	LDRB R7, [R8, #0x00]
	AND R7, #0x11
	
	CMP R7, #0x01
	BEQ SwitchOne
	
	CMP R7, #0x10
	BNE SwitchTwo
	

; LCD Screen address
	; 1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16
	; 80 81 82 83 84 85 86 87 88 89 8A 8B 8C 8D 8E 8F
	; C0 C1 .......

	; Update player position based on button press

SwitchOne
	;move character left
	CMP R12, #0x80
	BEQ Skip
	
	SUB R12, #0x40
	
	B Skip
	
SwitchTwo
	CMP R12, #0xC0
	BEQ Skip
	
	ADD R12, #0x40
	
Skip   ; Check if an obstacle is on screen
	
	AND R6, R10, #0x01 ;throws the masked obs. flag into R6
	
    CMP R6, #0x01
    BNE NoObstacle  ; No obstacle on screen, generate one
    ; Move existing obstacle to the left

    ; Check for collision and handle accordingly
	CMP R12, R11
	BEQ GameOver
 
	; Check if the obstacle has reached the end of the board
    CMP R11, #0x80
    BEQ RemoveObstacle  ; Obstacle reached the end, remove it

	CMP R11, #0xC0
    BEQ RemoveObstacle  ; Obstacle reached the end, remove it

	;no collision, not at end move obs left
	SUBS R11, #0x01
	B UpdateDisplay
	
    

NoObstacle
    ; Generate a new obstacle
    LDR R11, =OBSTACLE_START_POSITION
    ORR R10, #0x01  ; Set obstacle flag
	
	AND R6, R10, #0x02 ; Throws the masked obstacle lane position value into register 6
	
	CMP R6, #0x02 ; R6 is not important and can be overwritten
	BNE UpdateDisplay
	
	ADD R11, #0x40 ; Makes obstacle spawn in right row

	
	B UpdateDisplay
    ; Move player and obstacle positions UpdateDisplay

RemoveObstacle
    AND R10, #0x02  ; Clear obstacle flag 
	EOR R10, #0x02  ; Toggle the Lane Position to change spawn lane
	
    B UpdateDisplay

; Function to update display with player and obstacle positions
UpdateDisplay
    ; Use LCD functions to display player and obstacle positions
    ; Example:
	MOV R2, R12 ;sending hex code
	BL LCDCommand
    MOV R3, #'O'  ; Player position
    BL LCDData
	MOV R2, R11 ;sending hex code
	BL LCDCommand
    MOV R3, #'X'  ; Obstacle position
    BL LCDData
    ; Additional LCD updates as needed
    ; Add delays and other necessary logic
    ; ...

    ; Return to the GameLoop
    B GameLoop
			
GameOver
    ; Game over logic here
	B GameOver
	endp				
				
LCDInit		function
					
			LDR R0, =0x40004C20		; P3: control pins
			LDR R1, =0x40004C21		; P4: data or commands 		
			MOV R2, #0xE0			; 1110 0000 
			STRB R2, [R0, #0x04]	; outputs pins for EN, RW, RS
			MOV R2, #0xFF
			STRB R2, [R1, #0x04]	; All of Port 4 as output pins to LCD
			
			PUSH {LR}		
			MOV R2, #0x38			; 2 lines, 7x5 characters, 8-bit mode		 
			BL LCDCommand			; Send command in R2 to LCD

			; ADD INSTRUCTIONS TO TURN ON THE DISPLAY AND THE CURSOR,
					MOV R2, #0X0E ;sending hex code
					BL LCDCommand
			; CLEAR DISPLAY AND MOVE CURSOR RIGHT
					MOV r2, #0X01
					BL LCDCommand
					MOV R2, #0X06
					BL LCDCommand
					

			
			
			
			POP {LR}			
			BX LR
			endp
				
LCDCommand	function				; R2 brings in the command byte
			STRB R2, [R1, #0x02]
			MOV R2, #0x00			; RS = 0, command register selected, RW = 0, write to LCD
			ORR R2, #EN
			STRB R2, [R0, #0x02]	; EN = 1
			PUSH {LR}
			BL delay
			
			MOV R2, #0x00
			STRB R2, [R0, #0x02]	; EN = 0 and RS = RW = 0	
			POP {LR}
			BX LR
			endp				
				
LCDData		function				; R3 brings in the character byte
			
			; COMPLETE THIS FUNCTION, REFER TO LCDCommand and TABLE 3 on HANDOUT
					STRB R3, [R1, #0X02]
					MOV R2, #0xA0			
					;ORR R2, EN
					STRB R2, [R0, #0x02]	; EN = 1
					PUSH {LR}
					BL delay
					
					MOV R3, #0x20
					STRB R3, [R0, #0x02]	
					POP {LR}
					BX LR
					
			endp
				
delay function
		PUSH {R4, R5}
		MOV R5, #50
Loop1 	MOV R4, #0xFF
Loop2 	SUBS R4, #1
		BNE Loop2
		SUBS R5, #1
		BNE Loop1
		POP {R5, R4}
		BX LR
		endp

GameDelay function ; Is here bc you do not want game to update too fast
		PUSH {R4, R5}
		MOV R5, #5000
loop1 	MOV R4, #0XFF
loop2 	SUBS R4, #1
		BNE loop2
		SUBS R5, #1
		BNE loop1
		POP {R5, R4}
		BX LR
		endp

		end
