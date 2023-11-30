; Lab 6 - 16x2 LCD display

			area Lab6, code, readonly
RS			equ 0x20	; RS connects to P3.5
RW			equ 0x40	; RW connects to P3.6
EN			equ 0x80	; EN connects to P3.7
LO			equ 0x8F
RO			equ 0xCF
obstacleFlag DCD OBSTACLE_NONE
BUTTON_FLAG_ADDR    	EQU 0x20004000   ; Address where the button press flag is stored
PLAYER_POSITION     	DCD 0
OBSTACLE_POSITION	DCD 0
COUNTER 		DCD 0
			export __main

__main		proc	

			
			BL LCDInit
			
			MOV R3, #'O'			; Character 'O'	
			BL LCDData				; Send character in R3 to LCD
			
gameloop
		; Check for user input and handle player movement
    		LDR R0, =BUTTON_FLAG_ADDR
   		LDR R1, [R0]
    		CMP R1, #1
    		BEQ handleButtonPress

		; Spawn obstacle
    		BL spawnObstacle

    		; Move obstacle towards the player
    		BL moveObstacle

    		; Check for collision
    		BL checkCollision

    		; Update display and delay
    		BL updateDisplay
    		
		BL delay

    		B gameLoop
buttonpress
		; Toggle player position between 0x80 and 0xC0
    		LDR R0, [PLAYER_POSITION]   ; Load the current player position
    		CMP R0, #0xC0               ; Compare with 0xC0
    		BEQ setPlayerPosition0x80   ; If equal, set player position to 0x80
    		MOV R1, #0xC0               ; If not equal, set R1 to 0xC0
		
setPlayerPosition0x80
		MOV R1, #0x80               ; Set R1 to 0x80

updatePlayerPositionAndDisplay
    		STR R1, [PLAYER_POSITION]   ; Update the player position
spawnObstacle
    		; Check if an obstacle is already present
    		CMP R0, #OBSTACLE_NONE
    		BNE obstacleAlreadyPresent  ; Branch if an obstacle is already present

      		; Generate a random number (0 or 1) to choose the obstacle position
    		MOV R0, #2          ; Number of positions (0 and 1)
    		BL Rand             ; Call a subroutine to get a random number (0 or 1)
    		CMP R0, #0
   		BEQ setObstacleTopRight   ; If 0, set obstacle position to top right
    		B setObstacleBottomRight  ; If 1, set obstacle position to bottom right

setObstacleTopRight
    		; Set obstacle position to top right (e.g., 0xC0)
    		MOV R1, L0
    		STR R1, [OBSTACLE_POSITION]
    		BX LR

setObstacleBottomRight
    		; Set obstacle position to bottom right (e.g., 0x80)
    		MOV R1, R0
    		STR R1, [OBSTACLE_POSITION]
    		BX LR
obstacleSpawned
    		; Set the obstacle flag to indicate that an obstacle is present
    		LDR R1, =OBSTACLE_TOP_RIGHT
    		STR R1, [obstacleFlag]
      		BX LR
Rand
    		; Load the current counter value
    		LDR R0, [COUNTER]

    		; Increment the counter
    		ADD R0, R0, #1
    		STR R0, [COUNTER]

    		; Generate either 1 or 0 by taking modulo 2
    		AND R0, R0, #1

    		; The result is in R0 (either 1 or 0)

    		BX LR
moveObstacle
		; Load the current obstacle position
    		LDR R0, [OBSTACLE_POSITION]

   		; Decrement the obstacle position
    		SUB R0, R0, #1
    		STR R0, [OBSTACLE_POSITION]

    		BX LR
checkCollision
    		; Load player and obstacle positions
    		LDR R0, [playerPosition]
    		LDR R1, [obstaclePosition]

    		; Compare player and obstacle positions
    		CMP R0, R1

    		; Branch if equal (collision detected)
    		BEQ stay

    		BX LR
updateDisplay

		; Display player position
    		LDR R0, [playerPosition]
    		BL LCDData

    		; Display obstacle position
    		LDR R0, [obstaclePosition]
    		BL LCDData

   		BX LR

stay		B stay					; Remain here after completion
			endp
				
buttonpress				
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
			ORR R2, EN
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
			MOV R5, #50
loop1		MOV R4, #0xFF
loop2		SUBS R4, #1
			BNE loop2
			SUBS R5, #1
			BNE loop1
			BX LR
			endp
			
			end
