			area Lab6, code, readonly
RS			equ 0x20	; RS connects to P3.5
RW			equ 0x40	; RW connects to P3.6
EN			equ 0x80	; EN connects to P3.7

; Define some constants for player and obstacle positions
PLAYER_START_POSITION    EQU 0x80  ; Top left corner
OBSTACLE_START_POSITION  EQU 0x8E  ; Top right corner

; Flags
OBSTACLE_FLAG            EQU 0x01  ; Set if obstacle is on screen

;;R0
;;R1
;;R2 - LCDCommand
;;R3 - LCDWrite
;;R4 - delay loop
;;R5 - delay loop
;;R6
;;R7
;;R8
;;R9
;;R10 - DNC - obs. flag
;;R11 - DNC - obs. pos.
;;R12 - DNC - player pos.

; Initialize player and obstacle positions
    MOV R12, #PLAYER_START_POSITION
    MOV R11, #OBSTACLE_START_POSITION
    MOV R10, #0x00  ; Initialize the obstacle flag
			export __main

__main		proc	

			
			BL LCDInit
		;MOV R2, R12 ;sending hex code
		;BL LCDCommand
		;MOV R3, #'O'  ; Player position
		;BL LCDData
		
		
GameLoop
    ; Check if a button has been pressed (you'll need to implement this)
    
	LDR R0, =0x40004C00
	
	LDRB R1, [R0, #0x00]
	AND R1, #0x11
	
	CMP R1, #0x01
	BEQ SwitchOne
	
	CMP R1, #0x10
	BNE SwitchTwo

SwitchOne
	CMP R1, R12
	BEQ Skip
	
	SUB R12, #0x40
	
	B Skip
	
SwitchTwo
	CMP R1, R12
	BEQ Skip
	
	ADD R12, #0x40
	
Skip   ; Check if an obstacle is on screen
    CMP R10, #0x01
    BEQ NoObstacle  ; No obstacle on screen, generate one
    ; Move existing obstacle to the left
	
    ; Check for collision and handle accordingly
	CMP R12, R11
	BEQ GameOver
 
	; Check if the obstacle has reached the end of the board
    CMP R11, #0x00
    BEQ RemoveObstacle  ; Obstacle reached the end, remove it

	;no collision, not at end move obs left
	SUBS R11, #0x01
	B UpdateDisplay
	
    

NoObstacle
    ; Generate a new obstacle
    LDR R11, =OBSTACLE_START_POSITION
    ORR R10, #0x01  ; Set obstacle flag
	
	B UpdateDisplay
    ; Move player and obstacle positions UpdateDisplay

RemoveObstacle
    AND R10, #0x02  ; Clear obstacle flag 
	ORR R11, #0x01
	
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
				
delay		function
			MOV R5, #5
loop1		MOV R4, #3
loop2		SUBS R4, #1
			BNE loop2
			SUBS R5, #1
			BNE loop1
			BX LR
			endp
			
			end
