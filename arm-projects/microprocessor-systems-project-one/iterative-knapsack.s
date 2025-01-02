			AREA MyData, DATA, READWRITE
W_Capacity  EQU 50   
SIZE        EQU 3
	
profit      DCD 60, 100, 120
weight      DCD 10, 20, 30
dp			SPACE 4 * W_Capacity

			AREA MyCode, CODE, READONLY
			EXPORT main
				
pushsix		LSLS R4, #2
			STR  R6, [R3, R4]
			LSRS R4, #2
			BX   LR

pushseven	LSLS R4, #2
			STR  R7, [R3, R4]
			LSRS R4, #2
			BX   LR

max			CMP  R6, R7				; load the bigger one to the [R3, R4 * 4]
			BGE  pushsix
			BLT  pushseven

dpw			SUBS R6, R4, R6			; w - weight[i]
			LSLS R6, #2				; multiply with 4, because each of our words are 4 byte
			LSLS R7, R5, #2			; multiply with 4, because each of our words are 4 byte
			LDR  R6, [R3, R6]		; dp[w - weight[i]]
			LDR  R7, [R1, R7]		; profit[i]
			ADDS R6, R7				; dp[w - weight[i]] + profit[i]
			LSLS R7, R4, #2			; multiply with 4, because each of our words are 4 byte
			LDR  R7, [R3, R7]		; dp[w]
			BL   max				; dp[w] = max(dp[w], dp[w - weight[i]] + profit[i])
			POP  {PC}

dpw_cond	PUSH {LR}				; save the end of the if statement
			LSLS R6, R5, #2			; multiply with 4, because each of our words are 4 byte
			LDR  R6, [R2, R6]		; weight[i]
			CMP  R6, R4				; weight[i] <= w
			BLE  dpw				; execute the code inside the if statement
			POP  {PC}				; else go to the end of the if statement

fori		BL forw_temp			; if we execute for loop at least one or not
			ADDS R5, #1				; i++
			CMP  R5, #SIZE			; i < n
			BLT  fori				; if (i < n) execute outer for loop one more time
			MOVS R5, #SIZE			; reset n, for each outer for loop (actually we don't need that, but it provide us more clean code)
			POP  {PC}				; go back to knapsack body

forw  		BL   dpw_cond			; go to the if condition in the inner loop
			SUBS R4, #1				; w--
			CMP  R4, #0				; w >= 0 
			BGE  forw				; if (w >= 0) execute inner for loop one more time
			MOVS R4, #W_Capacity	; reset w, for each outer for loop
			POP  {PC}				; go back to fori
			
fori_temp 	PUSH {LR}				; return of fori, outer for loop
			CMP  R5, #SIZE			; i < n
			BLT  fori				; if so, enter theloop
			POP  {PC}				; if not, don't execute for loop
			
forw_temp 	PUSH {LR}				; return of forw, inner for loop
			CMP  R4, #0				; w >= 0
			BGE  forw				; if so, enter loop
			POP  {PC}				; if not, don't execute for loop

knapsack	PUSH {LR}				; to enable recursion (call stack)
			BL fori_temp			; if we execute for loop at least one or not
			MOVS R6, #W_Capacity	; R6 = W
			LSLS R6, #2				; multiply with 4, because each of our words are 4 byte
			LDR  R0, [R3, R6]		; value = dp[W]
			POP  {PC}				; go back to main

main		MOVS R0, #0				; value
			LDR  R1, =profit		; profit
			LDR  R2, =weight		; weight
			LDR  R3, =dp			; dp
			MOVS R4, #W_Capacity	; w
			MOVS R5, #0				; i, I don't use i-1 approach, I start i from 0 and use i instead of i-1
			BL	 knapsack			; knapsack
			B 	 .					; while (1)
			
			END