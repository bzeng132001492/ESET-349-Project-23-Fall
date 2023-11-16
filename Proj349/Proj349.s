		area proj349, code, readonly

__main		proc	

			BL LCDInit
			
			MOV R3, #'S'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			; ADD INSTRUCTIONS TO SEND REMAINING DATA TO THE LCD
			MOV R3, #'U'			; Character 'U'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R3, #'C'			; Character 'C'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R3, #'C'			; Character 'C'	
			BL LCDData				; Send character in R3 to LCD

			MOV R3, #'E'			; Character 'E'	
			BL LCDData				; Send character in R3 to LCD

			MOV R3, #'S'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD

			MOV R3, #'S'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R2, #0xC7			; New Line
			BL LCDCommand

			MOV R3, #'F'			; Character 'F'	
			BL LCDData				; Send character in R3 to LCD

			MOV R3, #'A'			; Character 'A'	
			BL LCDData				; Send character in R3 to LCD

			MOV R3, #'I'			; Character 'I'	
			BL LCDData				; Send character in R3 to LCD

			MOV R3, #'L'			; Character 'L'	
			BL LCDData				; Send character in R3 to LCD

			MOV R3, #'U'			; Character 'U'	
			BL LCDData				; Send character in R3 to LCD

			MOV R3, #'R'			; Character 'R'	
			BL LCDData				; Send character in R3 to LCD

			MOV R3, #'E'			; Character 'E'	
			BL LCDData				; Send character in R3 to LCD

stay		B stay					; Remain here after completion
			endp
				
				
LCDInit		function
					
			LDR R0, =0x40004C20		; P3: control pins
			LDR R1, =0x40004C21		; P4: data or commands 		
			MOV R2, #0xE0			; 1110 0000 
			STRB R2, [R0, #0x04]	; outputs pins for EN: 3.7, RW: 3.6, RS: 3.5
			MOV R2, #0xFF
			STRB R2, [R1, #0x04]	; All of Port 4 as output pins to LCD
			
			PUSH {LR}		
			MOV R2, #0x38			; 2 lines, 7x5 characters, 8-bit mode		 
			BL LCDCommand			; Send command in R2 to LCD

			MOV R2, #0x0E			; TURN ON THE DISPLAY AND THE CURSOR
			BL LCDCommand
			
			MOV R2, #0x01			; CLEAR DISPLAY
			BL LCDCommand
			
			MOV R2, #0x06			; MOVE CURSOR RIGHT
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
			STRB R3, [R1, #0x02]
			MOV R2, #0x20			; RS = 1, command register selected, RW = 0, write to LCD
			ORR R2, EN
			STRB R2, [R0, #0x02]	; EN = 1
			PUSH {LR}
			BL delay
			
			MOV R2, #0x20
			STRB R2, [R0, #0x02]	; EN = 0, RW = 0, and RS = 1	
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

		END