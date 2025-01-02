					AREA    Timing_Code, CODE, READONLY
					ALIGN
					THUMB
					EXPORT  Systick_Start_asm
					EXPORT  Systick_Stop_asm
					EXPORT	SysTick_Handler

					EXTERN	ticks

SysTick_Handler		FUNCTION
				
					PUSH {LR}
					LDR  R0, =ticks
					LDR  R1, [R0]
					ADDS R1, #1
					STR	 R1, [R0]			; ticks += 1
					POP	 {PC}
								
					ENDFUNC

Systick_Start_asm 	FUNCTION
	
					PUSH {LR}
					
					LDR  R0, =ticks
					MOVS R1, #0
					STR  R1, [R0]			; ticks = 0
					
					LDR  R0, =0xE000E014
					MOVS R1, #249
					STR	 R1, [R0]			; SysTick Reload Value = 249
					
					LDR  R0, =0xE000E018
					MOVS R1, #0
					STR  R1, [R0]			; SysTick Current Value = 0
					
					LDR  R0, =0xE000E010
					LDR  R1, [R0]
					MOVS R2, #7				; 0111
					ORRS R1, R2				; Set CLKSOURCE, TICKINT, ENABLE for SysTick CSR
					STR  R1, [R0]
					
					POP  {PC}
					
					ENDFUNC

Systick_Stop_asm 	FUNCTION
		
					PUSH {LR}
					LDR  R0, =0xE000E010
					LDR	 R1, [R0]
					MOVS R2, #1
					BICS R1, R2				; ENABLE of SysTick CSR = 0
					STR  R1, [R0]			; disable SysTick
					LDR  R1, =ticks
					LDR  R0, [R1]			
					POP  {PC}
						
					ENDFUNC

					END
