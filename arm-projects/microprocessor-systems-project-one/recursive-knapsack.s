			AREA MyData, DATA, READWRITE
W_Capacity  EQU 50   
SIZE        EQU 3
	
profit      DCD 60, 100, 120
weight      DCD 10, 20, 30

			AREA MyCode, CODE, READONLY
			EXPORT main
				
addfive		ADDS R0, R5
			BX   LR

addsix		ADDS R0, R6
			BX   LR

max			CMP  R5, R6				; R0 = (R5 >= R6) ? R0 + R5 : R0 + R6
			BGE  addfive
			BLT  addsix				

basecase    POP  {PC}				; if (n == 0 || W == 0)

knapsack	PUSH {LR}				; to enable recursion (call stack)
			CMP  R3, #0				; if (W == 0)
			BEQ  basecase			; return 0;
			CMP  R4, #0				; if (n == 0)
			BEQ  basecase			; return 0;
			
			SUBS R4, #1				; n--
			LSLS R5, R4, #2			; multiply with 4, because each of our words are 4 byte
			LDR  R5, [R2, R5]		; weight[n-1]
			CMP  R5, R3				; if (weight[n-1] >  W)
			BGT  knapsack			; knapsack(W, n-1)
			
			PUSH {R0, R3, R4, R5}	; to preserve the state before the recursive steps
			BL   knapsack			; knapsack(W, n-1)
			MOVS R6, R0				; R6 = knapsack(W, n-1)
			POP  {R0, R3, R4, R5}	; return to the before state for next recursion
			PUSH {R0, R3, R4, R5}	; save the state
			SUBS R3, R5				; set W as W - weight[n-1] for next recursive call
			BL   knapsack			; knapsack(W - weight[n-1], n-1)
			MOVS R7, R0				; R7 = knapsack(W - weight[n-1], n-1)
			POP	 {R0, R3, R4, R5}	; return to the before state
			LSLS R5, R4, #2			; multiply with 4, because each of our words are 4 byte
			LDR  R5, [R1, R5]		; profit[n-1]
			ADDS R5, R7				; R5 = profit[n-1] + knapsack(W - weight[n-1], n-1)
			BL   max				; R0 += max(R5, R6)
			POP  {PC}

main 		MOVS R0, #0				; value
			LDR  R1, =profit		; profit
			LDR  R2, =weight		; weight
			MOVS R3, #W_Capacity	; W
			MOVS R4, #SIZE			; n
			BL   knapsack			; knapsack(W, n)
			B    .					; while (1)
			
			END