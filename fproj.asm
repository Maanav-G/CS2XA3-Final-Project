%include "simple_io.inc"

global asm_main
extern rperm

section .data

	line: times 81 db 0
	line18: db "..+------+"
	line17: db "..+-----+."
	line16: db "...+----+."
	line15: db "...+---+.."
	line14: db "....+--+.."
	line13: db "....+-+..."
	line12: db ".....++..."
	line11: db ".....+...."
	line28: db "  +------+"
	line27: db "  +-----+ "
	line26: db "   +----+ "
	line25: db "   +---+  "
	line24: db "    +--+  "
	line23: db "    +-+   "
	line22: db "     ++   "
	line21: db "      +   "
	line08: db "  +      +"
	line07: db "  +     + "
	line06: db "   +    + "
	line05: db "   +   +  "
	line04: db "    +  +  "
	line03: db "    + +   "
	line02: db "     ++   "
	line01: db "      +   "

	msg1: db "if you want to swap, enter a,b",10,0
	msg2: db "if you want to end, enter 0: ",0
	msg3: db "program done",10,0
	msg4: db 10,"incorrect input, redo",10,0
	msg5: db "swappin box ",0
	msg6: db " with a box ",0

section .bss
	array: resq 8

section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


asm_main:	
	enter	0,0
	saveregs

	mov	rdi, array     ;1st param for rperm
	mov	rsi, qword 8   ;2nd param for rperm
	call rperm

	;; now the array 'array' is randomly initialzed


asm_main_while_loop:
	mov rdi,array 		;rdi = x
	call display
	mov rax,msg1
	call print_string
	mov rax,msg2
	call print_string
	call read_char
	cmp al,'0'
	je asm_main_done
	cmp al,'1'
	jl asm_main_incorrect
	cmp al,'8'
	jg asm_main_incorrect
	; save it to rbx
	mov rbx,rax
	call read_char
	cmp al,','
	jne asm_main_incorrect
	call read_char
	cmp al,'1'
	jl asm_main_incorrect
	cmp al,'8'
	jg asm_main_incorrect
	cmp rax,rbx
	je asm_main_incorrect
	; save it in rdx
	mov rdx,rax
	mov rax,msg5
	call print_string
	mov rax,rbx
	call print_char
	mov rax,msg6
	call print_string
	mov rax,rdx
	call print_char
	call print_nl
	sub bl,'0'
	sub dl,'0'
	; we use al as a1
	; we use ah as b1
	; we use rcx as counter
	; we use rsi for save address of array
	xor rcx,rcx
	mov rsi,array


asm_main_while_for:
	cmp [rsi],bl
	je asm_main_while_for_a1
	cmp [rsi],dl
	je asm_main_while_for_b1
	jmp asm_main_while_for_update


asm_main_while_for_a1:
	mov al,cl
	jmp asm_main_while_for_update


asm_main_while_for_b1:
	mov ah,cl


asm_main_while_for_update:
	add rsi,8
	inc rcx
	cmp rcx,8
	jl asm_main_while_for
	movzx rbx,al
	shl rbx,3 ; rbx = rbx * 8 
	xor rdx,rdx
	mov dl,ah
	shl rdx,3 ; rdx = rdx * 8 
	mov rsi,array
	add rsi,rbx
	mov rdi,array
	add rdi,rdx
	; swap
	mov rax,[rsi]
	mov rbx,[rdi]
	mov [rsi],rbx
	mov [rdi],rax
	call clear_input
	jmp asm_main_while_loop


asm_main_incorrect:
	call clear_input
	mov rax,msg4
	call print_string
	jmp asm_main_while_loop


asm_main_done:
	mov rax,msg3
	call print_string
	restoregs
	leave
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


display:	
	enter	0,0
	saveregs
	; rdi x
	; for i in range(9,0,-1):
        ; line = create_line(x,i-1)
        ;  print(line)
	mov rcx,9


display_loop:
	mov rbx,line
	mov byte [rbx],0
	mov rsi,rcx
	dec rsi ; i-1
	call create_line
	call print_string
	call print_nl
	loop display_loop
	restoregs
	leave
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


create_line:	
	enter	0,0
	saveregs
	; rdi x
	; rsi level
	;for i in range(0,8):
        ;line = add2line(line,x[i],level)
	mov rdx,rsi ; level
	mov rbx,rdi ; save x in rbx :)
	mov rdi,line ; rdi = address of line :)
	xor rcx,rcx ; rcx = 0


create_line_loop:
	mov rax,rcx
	shl rax,3 ; rax = rax * 8 :)
	mov rsi,rbx
	add rsi,rax ; rsi = x[i]
	mov rsi,[rsi]
	call add2line
	inc rcx ; i++
	cmp rcx,8
	jl create_line_loop
	mov rax,line ; return line
	restoregs
	leave
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


add2line:	
	enter	0,0
	saveregs
	; rdi line
	; rsi size
	; rdx level
	cmp rdx,1
	je add2line_if1
	jg add2line_if2
	; else :)
	cld
	xor rax,rax
	mov rcx,81
	repne scasb 
	dec rdi
	mov al,' '
	mov rcx,5
	rep stosb
	mov rax,rsi
	add al,'0' ; convert to digit
	stosb
	mov al,' '
	mov rcx,4
	rep stosb
	mov al,0
	stosb ; append 0 to end :)
	jmp add2line_done


add2line_if1:
	cmp rsi,8
	je add2line_if1_8
	cmp rsi,7
	je add2line_if1_7
	cmp rsi,6
	je add2line_if1_6
	cmp rsi,5
	je add2line_if1_5
	cmp rsi,4
	je add2line_if1_4
	cmp rsi,3
	je add2line_if1_3
	cmp rsi,2
	je add2line_if1_2
	; else :)
	mov rsi,line11
	call append_to_end
	jmp add2line_done


add2line_if1_8:
	mov rsi,line18
	call append_to_end
	jmp add2line_done


add2line_if1_7:
	mov rsi,line17
	call append_to_end
	jmp add2line_done


add2line_if1_6:
	mov rsi,line16
	call append_to_end
	jmp add2line_done


add2line_if1_5:
	mov rsi,line15
	call append_to_end
	jmp add2line_done


add2line_if1_4:
	mov rsi,line14
	call append_to_end
	jmp add2line_done


add2line_if1_3:
	mov rsi,line13
	call append_to_end
	jmp add2line_done


add2line_if1_2:
	mov rsi,line12
	call append_to_end
	jmp add2line_done


add2line_if2:
	cmp rsi,rdx
	jl add2line_if2_if
	je add2line_if2_elseif
	; else here :)
	cmp rsi,8
	je add2line_if2_else_8
	cmp rsi,7
	je add2line_if2_else_7
	cmp rsi,6
	je add2line_if2_else_6
	cmp rsi,5
	je add2line_if2_else_5
	cmp rsi,4
	je add2line_if2_else_4
	cmp rsi,3
	je add2line_if2_else_3
	cmp rsi,2
	je add2line_if2_else_2
	; else_else here :)
	mov rsi,line01
	call append_to_end
	jmp add2line_done


add2line_if2_else_8:
	mov rsi,line08
	call append_to_end
	jmp add2line_done


add2line_if2_else_7:
	mov rsi,line07
	call append_to_end
	jmp add2line_done


add2line_if2_else_6:
	mov rsi,line06
	call append_to_end
	jmp add2line_done


add2line_if2_else_5:
	mov rsi,line05
	call append_to_end
	jmp add2line_done


add2line_if2_else_4:
	mov rsi,line04
	call append_to_end
	jmp add2line_done


add2line_if2_else_3:
	mov rsi,line03
	call append_to_end
	jmp add2line_done


add2line_if2_else_2:
	mov rsi,line02
	call append_to_end
	jmp add2line_done


add2line_if2_if:
	cld
	xor rax,rax
	mov rcx,81
	repne scasb 
	dec rdi
	mov al,' '
	mov rcx,10
	rep stosb
	mov al,0
	stosb ; append 0 to end :)
	jmp add2line_done


add2line_if2_elseif:
	cmp rsi,8
	je add2line_if2_elseif_8
	cmp rsi,7
	je add2line_if2_elseif_7
	cmp rsi,6
	je add2line_if2_elseif_6
	cmp rsi,5
	je add2line_if2_elseif_5
	cmp rsi,4
	je add2line_if2_elseif_4
	cmp rsi,3
	je add2line_if2_elseif_3
	cmp rsi,2
	je add2line_if2_elseif_2
	; else here :)
	mov rsi,line21
	call append_to_end
	jmp add2line_done


add2line_if2_elseif_8:
	mov rsi,line28
	call append_to_end
	jmp add2line_done


add2line_if2_elseif_7:
	mov rsi,line27
	call append_to_end
	jmp add2line_done


add2line_if2_elseif_6:
	mov rsi,line26
	call append_to_end
	jmp add2line_done


add2line_if2_elseif_5:
	mov rsi,line25
	call append_to_end
	jmp add2line_done


add2line_if2_elseif_4:
	mov rsi,line24
	call append_to_end
	jmp add2line_done


add2line_if2_elseif_3:
	mov rsi,line23
	call append_to_end
	jmp add2line_done


add2line_if2_elseif_2:
	mov rsi,line22
	call append_to_end


add2line_done:
	mov rax,rdi ; return line
	restoregs
	leave
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


append_to_end:	
	enter	0,0
	saveregs
	; rdi des
	; rsi ser
	xor rax,rax
	mov rcx,81
	repne scasb 
	dec rdi
	mov rcx,10
	cld
	rep movsb 
	; add 0 to end
	mov [rdi],al
	restoregs
	leave
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


clear_input:	
	enter	0,0
	saveregs


clear_input_loop:
	call read_char
	cmp al,10
	jne clear_input_loop
	restoregs
	leave
	ret

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;