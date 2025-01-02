					AREA    Sorting_Code, CODE, READONLY
					ALIGN
					THUMB
					EXPORT  ft_lstsort_asm

ft_lstsort_asm 		FUNCTION
	
					PUSH {R0-R1, LR}
					MOVS R7, #0				; unsorted_tail = 0 as NULL
					LDR  R4, [SP]			; pointer to the list (address of t_list *)
					LDR  R4, [R4]			; Value of head
					CMP  R4, #0				; isEmpty
					BNE	 do_loop
					POP  {R0-R1, PC}
			
do_loop				LDR  R4, [SP]			; current = pointer to the list (address of t_list *)
					LDR  R4, [R4]			; current = head
					LDR  R5, [R4, #4]		; next = current->next
					MOVS R6, #0				; swapped = 0
					BL   while_cond
					MOVS R7, R4
					CMP	 R6, #1
					BEQ  do_loop
					POP  {R0-R1, PC}

while_cond			PUSH {LR}
					CMP  R5, R7				; if (next != unsorted_tail)
					BNE	 while_loop
					POP	 {PC}
					
while_loop			LDR  R1, [R5]			; next->num
					LDR  R0, [R4]			; current->num
					PUSH {R7}				; we need one more register here, so we borrow R7
					LDR  R7, [SP, #12]		; R7 = compare_func
					BLX  R7					; compare_func(current->num, next->num)
					POP  {R7}				; R7 = unsorted_tail again
					
					BL   swap_cond
					MOVS R4, R5				; current = current->next
					LDR  R5, [R5, #4]		; next = next->next
					CMP  R5, R7				; if (next != unsorted_tail)
					BNE  while_loop
					POP  {PC}				; break

swap_cond			PUSH {LR}
					CMP	 R0, #0				; if (!compare_func(current->num, next->num))
					BEQ  swap				; we need to swap current and next
					POP  {PC}
					
swap				PUSH {R7}				; we need one more register here, so we borrow R7
					LDR  R7, [R4]			; temp1 = current->num
					LDR  R6, [R5]			; temp2 = next->num
					STR  R7, [R5]
					STR  R6, [R4]
					POP  {R7}				; R7 = unsorted_tail again
					MOVS R6, #1				; swapped = 1
					POP  {PC}

					END