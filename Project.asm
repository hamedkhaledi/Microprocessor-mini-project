title (exe) Graphics System Calls 

.model small 
.stack 64   

.data 
     start_col dw   100 
     start_row dw   20
     finish_col dw  228
     finish_row dw  196
     
     start_col_line dw   ?
     start_row_line dw   ?
     finish_col_line dw  ?
     finish_row_line dw  ?
     
     start_col_rec dw   ?
     start_row_rec dw   ?
     finish_col_rec dw  ?
     finish_row_rec dw  ? 
     
     cell_x dw 5
     cell_y dw 4
     cell_color db 1    
     
     cell_x_index dw 0
     cell_y_index dw 0
     cell_x_pos dw 5
     cell_y_pos dw 4 
     
     cell_x_pos_in dw 0
     cell_y_pos_in dw 0
     cell_x_index_out dw 0
     cell_y_index_out dw 0
          
     cell_x_down dw 0
     cell_y_down dw 0
     
     cell_x_right dw 0
     cell_y_right dw 0
     
     cell_x_color_get dw 0 ; for get_color_of_cell (get color of specific cell)
     cell_y_color_get dw 0 
     cell_color_get db 0   
     
     check_cell_x dw 0
     check_cell_y dw 0
     check_is_empty dw 0
     seconds db 0  ;?¦¦ VARIABLE IN DATA SEGMENT.
     
     moving_block_center_x dw 0
     moving_block_center_y dw 0
     moving_block_mode dw 0
     moving_block_color db 0
     moving_block_x dw 0, 0, 0, 0
     moving_block_y dw 0, 0, 0, 0  
     
     check_block_down dw 0 
     check_block_right dw 0 
     check_block_left dw 0
     check_block_rotate dw 0 
     
     rand_num_in dw 0
     rand_num_out dw 0  
     
.code 


main proc far
    mov ax, @data
    mov ds, ax   
    call clear_screen    
    call set_graphic_mode 
    call create_background
   
      
    call gen_new_block
    
    
    mov bx, 0 
for_temp:
    call check_key_pressed
    call check_key_pressed
    call check_key_pressed
    call check_key_pressed 
    mov ah,0c ; clear keyboard buffer
    mov al,0
    int 21h
    call delay
    call mov_down_block
    cmp check_block_down, 1
    je not_gen_new_block_for 
    call clear_lines
    call gen_new_block   
not_gen_new_block_for:
    inc bx   
    cmp bx,45
    jnz for_temp

    
    mov ax, 4c00h ; exit to operating system.
    int 21h    

main endp

;;;;;;;;;;;;;;;;;
clear_screen proc 
    push ax 
    push bx
    push cx  
    push dx 
    
    mov al, 06h ; scroll down
    mov bh, 00h
    mov cx, 0000h
    mov dx, 28ffh
    int 10h
    
    pop dx
    pop cx
    pop bx
    pop ax            
    ret                    
endp clear_screen 

;;;;;;;;;;;;;;;;;
set_graphic_mode proc 
    push ax 
    push bx
    push cx  
    push dx 
    
    mov ah, 00h
    mov al, 13h
    int 10h
     
    pop dx   
    pop cx
    pop bx
    pop ax
    ret
endp set_graphic_mode

;;;;;;;;;;;;;;;;;
create_background proc  
    push ax 
    push bx
    push cx  
    push dx  
    
    mov start_row_line , 20 
    mov start_col_line , 100
    mov finish_col_line , 228
    mov finish_row_line , 196
    
    mov cx, start_col_line
    
back_loop1:   
    mov start_col_line, cx        
    call draw_vertical_line 
    add cx, 16
    cmp cx, finish_col_line
    jle back_loop1         


    mov start_col_line , 100 
    mov dx, start_row_line
    
back_loop2:  
    mov start_row_line, dx          
    call draw_horizontal_line 
    add dx, 16
    cmp dx, finish_row_line
    jle back_loop2
      
    pop dx
    pop cx
    pop bx
    pop ax        
    ret
endp create_background 

;;;;;;;;;;;;;;;;;
draw_vertical_line proc  
    push ax 
    push bx
    push cx  
    push dx
    
    mov ah, 0ch 
    mov al, 8
     
    mov dx, start_row_line  
    mov cx, start_col_line
loop_vertical1:
    int 10h
    inc dx
    cmp dx, finish_row_line
    jnz loop_vertical1 
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret   
endp draw_vertical_line 

;;;;;;;;;;;;;;;;;
draw_horizontal_line proc 

    push ax 
    push bx
    push cx  
    push dx
    
    mov ah, 0ch 
    mov al, 8
     
    mov dx, start_row_line  
    mov cx, start_col_line
loop_horizontal1:
    int 10h
    inc cx
    cmp cx, finish_col_line
    jnz loop_horizontal1 
    
    pop dx
    pop cx
    pop bx
    pop ax    
    ret   
endp draw_horizontal_line   

;;;;;;change color of specific cell;;;;;;;;;;;
color_cell proc   
    push ax 
    push bx
    push cx  
    push dx        
    
    mov ax, cell_x
    mov cx, 16
    mul cx      
    mov bx, start_row
    add ax, bx  
    add ax, 1
    mov start_row_rec, ax
    
    add ax, 15
    mov finish_row_rec, ax
     
    mov ax, cell_y 
    mov cx, 16
    mul cx
    mov bx, start_col
    add ax, bx
    add ax, 1
    mov start_col_rec, ax 
    
    add ax, 15
    mov finish_col_rec, ax   

    call draw_solid_rectangle
    pop dx   
    pop cx
    pop bx
    pop ax
    
    ret
endp color_cell 

;;;;;;;;;;;;;;;;;
draw_solid_rectangle proc

    push ax 
    push bx
    push cx  
    push dx
     
    mov ah, 0ch 
    mov al, cell_color
      
    mov dx, start_row_rec
loop1:
    mov cx, start_col_rec

loop2:
    int 10h
    inc cx
    cmp cx, finish_col_rec
    jnz loop2
    
    inc dx
    cmp dx, finish_row_rec
    jnz loop1
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    
endp draw_solid_rectangle                                
;;;;;;;;;;;;;;;;; 
delay proc   
  push ax
  push bx
  push cx
  push dx 
  
delaying:   
  mov  ah, 2ch
  int  21h      
  cmp  dh, seconds  
  je   delaying     
  mov  seconds, dh
    
  pop dx
  pop cx
  pop bx
  pop ax
  ret
delay endp 
;;;;;;;find center position of a cell;;;;;;;;;; 
find_cell_center proc
    push ax 
    push bx
    push cx    
    push dx
    
    mov ax, cell_x_index
    mov cx, 16
    mul cx      
    mov bx, start_row
    add ax, bx  
    add ax, 8
    mov cell_x_pos, ax
    
    mov ax, cell_y_index 
    mov cx, 16
    mul cx
    mov bx, start_col
    add ax, bx
    add ax, 8
    mov cell_y_pos, ax 
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp find_cell_center 
;;;;;;;find cell from position;;;;;;;;;; 
find_cell_from_pos proc
    push ax 
    push bx
    push cx    
    push dx
    
    xor ax, ax
    xor cx, cx
    xor dx, dx
    
    mov ax, cell_x_pos_in
    sub ax, start_row
    mov cx, 16
    div cx      
    mov cell_x_index_out, ax
    
    xor ax, ax
    xor cx, cx
    xor dx, dx
    
    mov ax, cell_y_pos_in
    sub ax, start_col
    mov cx, 16
    div cx  
    mov cell_y_index_out, ax 
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp find_cell_from_pos 
;;;;;;;;;;move down cell without check;;;;;;;;;;;;;;;;;;;;;;;
move_down_cell proc 
    push ax 
    push bx
    push cx
    push dx

    mov ax, cell_x_down
    mov cell_x, ax  
    mov cell_x_color_get, ax 
    mov ax, cell_y_down
    mov cell_y, ax
    mov cell_y_color_get, ax 
    
    call get_color_of_cell
    mov al, cell_color_get   
    push ax
    mov cell_color,0
    call color_cell   
    inc cell_x
    pop ax  
    mov cell_color,al 
    call color_cell
       
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp move_down_cell    
;;;;;;get color of specific cell;;;;;;;;;;;
get_color_of_cell proc
    push ax 
    push bx
    push cx
    push dx
    

    mov ax, cell_x_color_get
    mov cell_x_index,ax 
    mov ax, cell_y_color_get
    mov cell_y_index,ax
    call find_cell_center 
    
    mov ah, 0dh 
    mov dx, cell_x_pos 
    mov cx, cell_y_pos
    int 10h
    mov cell_color_get, al
     
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp get_color_of_cell    
;;;;;;check a cell;;;;;;;;;;;
check_cell_empty proc
    push ax 
    push bx
    push cx
    push dx
    
    mov check_is_empty, 0
    mov ax, check_cell_x 
    mov bx, check_cell_y 
      
    cmp ax, 11
    jge else_check_cell
    cmp bx, 8
    jge else_check_cell
    cmp ax, 0 
    jl else_check_cell   
    cmp bx, 0 
    jl else_check_cell
    
    mov cell_x_color_get, ax
    mov cell_y_color_get, bx
    call get_color_of_cell 
    mov al, cell_color_get
    cmp al, 0
    jne else_check_cell 
   
    mov check_is_empty, 1 
else_check_cell:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp check_cell_empty 
;;;;;;;check_key_pressed;;;;;;;;;;   ;TODO
check_key_pressed proc 
    push ax 
    push bx
    push cx
    push dx
    
    mov ah, 01h
    int 16h
    jz  done_key_pressed 
    mov ah, 00h
    int 16h  
      
    cmp al, 's'
    jne next1_key_pressed
    call mov_down_block  
next1_key_pressed:
    cmp al, 'd'
    jne next2_key_pressed
    call mov_right_block
next2_key_pressed:  
    cmp al, 'a'
    jne next3_key_pressed
    call mov_left_block

next3_key_pressed:   
    cmp al, 'w'
    jne next4_key_pressed
    call rotate_block

next4_key_pressed:
    cmp al, 'f'
    jne next5_key_pressed
    call mov_to_end

next5_key_pressed:

done_key_pressed:
 
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp check_key_pressed    
;;;;;;;mov down current block;;;;;;;;;;
mov_down_block proc
    push ax 
    push bx
    push cx
    push dx
    
    call is_down_block_empty
    cmp check_block_down, 0
    je mov_down_done
    call mov_down_block_common
mov_down_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp mov_down_block  
;;;;;;;check down is empty;;;;;;;;;; 
is_down_block_empty proc
    push ax 
    push bx
    push cx
    push dx
    
    mov check_block_down, 1
    mov cx, 0
for_down_is_empty:     
    cmp cx, 4
    jge done_for_down_is_empty
    mov si, cx
    add si, cx  
    mov ax, [moving_block_x + si]      
    mov bx, [moving_block_y + si]  
    inc ax
    mov check_cell_x,ax
    mov check_cell_y,bx
    call check_cell_empty 
    inc cx
    cmp check_is_empty, 1
    je  for_down_is_empty
    push cx
    mov cx, 0
for_down2_is_empty:
    cmp cx, 4 
    jge done_for_down2_is_empty
    mov si, cx
    add si, cx   
    inc cx
    cmp ax, [moving_block_x + si]
    jne for_down2_is_empty 
    cmp bx, [moving_block_y + si]
    jne for_down2_is_empty
    pop cx
    jmp for_down_is_empty    
done_for_down2_is_empty: 
    pop cx
    mov check_block_down, 0   
done_for_down_is_empty:    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp is_down_block_empty
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov_down_block_common proc
    push ax 
    push bx
    push cx
    push dx  
    
    mov cx, 0
for1_mov_down_block:     
    cmp cx, 4
    jge done_for1_mov_down_block
    mov si, cx
    add si, cx
    inc cx 
    mov ax, [moving_block_x + si]
    mov bx, [moving_block_y + si]  
    
    mov cell_x,ax
    mov cell_y,bx     
    mov cell_color, 0 
    call color_cell  
    
    jmp for1_mov_down_block      
done_for1_mov_down_block:  
mov cx,0
for2_mov_down_block:     
    cmp cx, 4
    jge done_for2_mov_down_block
    mov si, cx
    add si, cx 
    inc cx    
    inc [moving_block_x + si]
    mov ax, [moving_block_x + si]
    mov bx, [moving_block_y + si]  
    
    mov cell_x,ax
    mov cell_y,bx     
    mov dl, moving_block_color
    mov cell_color, dl 
    call color_cell  
    jmp for2_mov_down_block      
done_for2_mov_down_block:    
    
    add moving_block_center_x, 16 
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp mov_down_block_common
;;;;;;;mov down current block;;;;;;;;;;
rotate_block proc
    push ax 
    push bx
    push cx
    push dx
    
    call is_rotate_available
    cmp check_block_rotate, 0
    je rotate_done
    call rotate_block_common
rotate_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp rotate_block  
;;;;;;;check down is empty;;;;;;;;;; 
is_rotate_available proc
    push ax 
    push bx
    push cx
    push dx
    
    mov check_block_rotate, 1
    mov cx, 0
for_rotate_is_empty:     
    cmp cx, 4
    jge done_for_rotate_is_empty
    mov si, cx
    add si, cx  
    mov ax, [moving_block_x + si]      
    mov bx, [moving_block_y + si]
    
    mov cell_x_index, ax
    mov cell_y_index, bx
    call find_cell_center
    mov dx, moving_block_center_x 
    sub dx, moving_block_center_y
    add dx, cell_y_pos
    mov cell_x_pos_in, dx
                         
    mov cell_x_index, ax
    mov cell_y_index, bx
    call find_cell_center
    mov dx, moving_block_center_y 
    add dx, moving_block_center_x
    sub dx, cell_x_pos
    mov cell_y_pos_in, dx
    
    
    call find_cell_from_pos
    mov ax, cell_x_index_out
    mov bx, cell_y_index_out   
                         
    mov check_cell_x,ax
    mov check_cell_y,bx
    call check_cell_empty 
    inc cx
    cmp check_is_empty, 1
    je  for_rotate_is_empty
    push cx
    mov cx, 0
for_rotate2_is_empty:
    cmp cx, 4 
    jge done_for_rotate2_is_empty
    mov si, cx
    add si, cx   
    inc cx
    cmp ax, [moving_block_x + si]
    jne for_rotate2_is_empty 
    cmp bx, [moving_block_y + si]
    jne for_rotate2_is_empty
    pop cx
    jmp for_rotate_is_empty    
done_for_rotate2_is_empty: 
    pop cx
    mov check_block_rotate, 0   
done_for_rotate_is_empty:    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp is_rotate_available
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rotate_block_common proc
    push ax 
    push bx
    push cx
    push dx  
    
    mov cx, 0
for1_rotate_block:     
    cmp cx, 4
    jge done_for1_rotate_block
    mov si, cx
    add si, cx
    inc cx 
    mov ax, [moving_block_x + si]
    mov bx, [moving_block_y + si]  
    
    mov cell_x,ax
    mov cell_y,bx     
    mov cell_color, 0 
    call color_cell  
    
    jmp for1_rotate_block      
done_for1_rotate_block:  
mov cx,0
for2_rotate_block:     
    cmp cx, 4
    jge done_for2_rotate_block
    mov si, cx
    add si, cx 
    inc cx    
    push si
    mov ax, [moving_block_x + si]
    mov bx, [moving_block_y + si]  
    
    mov cell_x_index, ax
    mov cell_y_index, bx
    call find_cell_center
    mov dx, moving_block_center_x 
    sub dx, moving_block_center_y
    add dx, cell_y_pos
    mov cell_x_pos_in, dx
                         
    mov cell_x_index, ax
    mov cell_y_index, bx
    call find_cell_center
    mov dx, moving_block_center_y 
    add dx, moving_block_center_x
    sub dx, cell_x_pos
    mov cell_y_pos_in, dx
    
    call find_cell_from_pos
    mov ax, cell_x_index_out
    mov bx, cell_y_index_out
    
    pop si
    mov [moving_block_x + si], ax
    mov [moving_block_y + si], bx
    
    mov cell_x,ax
    mov cell_y,bx     
    mov dl, moving_block_color
    mov cell_color, dl 
    call color_cell  
    jmp for2_rotate_block      
done_for2_rotate_block:    
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp rotate_block_common   
;;;;;;;mov right current block;;;;;;;;;; 
mov_right_block proc
    push ax 
    push bx
    push cx
    push dx
    
    call is_right_block_empty
    cmp check_block_right, 0
    je mov_right_done
    call mov_right_block_common
mov_right_done:

    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp mov_right_block   
;;;;;;;check right is empty;;;;;;;;;; 
is_right_block_empty proc
    push ax 
    push bx
    push cx
    push dx
    
    mov check_block_right, 1
    mov cx, 0
for_right_is_empty:     
    cmp cx, 4
    jge done_for_right_is_empty
    mov si, cx
    add si, cx  
    mov ax, [moving_block_x + si]      
    mov bx, [moving_block_y + si]  
    inc bx
    mov check_cell_x,ax
    mov check_cell_y,bx
    call check_cell_empty 
    inc cx
    cmp check_is_empty, 1
    je  for_right_is_empty
    push cx
    mov cx, 0
for_right2_is_empty:
    cmp cx, 4 
    jge done_for_right2_is_empty
    mov si, cx
    add si, cx   
    inc cx
    cmp ax, [moving_block_x + si]
    jne for_right2_is_empty 
    cmp bx, [moving_block_y + si]
    jne for_right2_is_empty
    pop cx
    jmp for_right_is_empty    
done_for_right2_is_empty: 
    pop cx
    mov check_block_right, 0   
done_for_right_is_empty:    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp is_right_block_empty
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov_right_block_common proc
    push ax 
    push bx
    push cx
    push dx  
    
    mov cx, 0
for1_mov_right_block:     
    cmp cx, 4
    jge done_for1_mov_right_block
    mov si, cx
    add si, cx
    inc cx 
    mov ax, [moving_block_x + si]
    mov bx, [moving_block_y + si]  
    
    mov cell_x,ax
    mov cell_y,bx     
    mov cell_color, 0 
    call color_cell  
    
    jmp for1_mov_right_block      
done_for1_mov_right_block:  
mov cx,0
for2_mov_right_block:     
    cmp cx, 4
    jge done_for2_mov_right_block
    mov si, cx
    add si, cx 
    inc cx    
    inc [moving_block_y + si]
    mov ax, [moving_block_x + si]
    mov bx, [moving_block_y + si]  
    
    mov cell_x,ax
    mov cell_y,bx     
    mov dl, moving_block_color
    mov cell_color, dl 
    call color_cell  
    jmp for2_mov_right_block      
done_for2_mov_right_block:    
    
    add moving_block_center_y, 16
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp mov_right_block_common  
;;;;;;;mov left current block;;;;;;;;;; 
mov_left_block proc
    push ax 
    push bx
    push cx
    push dx
    
    call is_left_block_empty
    cmp check_block_left, 0
    je mov_left_done
    call mov_left_block_common
mov_left_done:

    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp mov_left_block   
;;;;;;;check right is empty;;;;;;;;;; 
is_left_block_empty proc
    push ax 
    push bx
    push cx
    push dx
    
    mov check_block_left, 1
    mov cx, 0
for_left_is_empty:     
    cmp cx, 4
    jge done_for_left_is_empty
    mov si, cx
    add si, cx  
    mov ax, [moving_block_x + si]      
    mov bx, [moving_block_y + si]  
    dec bx
    mov check_cell_x,ax
    mov check_cell_y,bx
    call check_cell_empty 
    inc cx
    cmp check_is_empty, 1
    je  for_left_is_empty
    push cx
    mov cx, 0
for_left2_is_empty:
    cmp cx, 4 
    jge done_for_left2_is_empty
    mov si, cx
    add si, cx   
    inc cx
    cmp ax, [moving_block_x + si]
    jne for_left2_is_empty 
    cmp bx, [moving_block_y + si]
    jne for_left2_is_empty
    pop cx
    jmp for_left_is_empty    
done_for_left2_is_empty: 
    pop cx
    mov check_block_left, 0   
done_for_left_is_empty:    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp is_left_block_empty
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov_left_block_common proc
    push ax 
    push bx
    push cx
    push dx  
    
    mov cx, 0
for1_mov_left_block:     
    cmp cx, 4
    jge done_for1_mov_left_block
    mov si, cx
    add si, cx
    inc cx 
    mov ax, [moving_block_x + si]
    mov bx, [moving_block_y + si]  
    
    mov cell_x,ax
    mov cell_y,bx     
    mov cell_color, 0 
    call color_cell  
    
    jmp for1_mov_left_block      
done_for1_mov_left_block:  
mov cx,0
for2_mov_left_block:     
    cmp cx, 4
    jge done_for2_mov_left_block
    mov si, cx
    add si, cx 
    inc cx    
    dec [moving_block_y + si]
    mov ax, [moving_block_x + si]
    mov bx, [moving_block_y + si]  
    
    mov cell_x,ax
    mov cell_y,bx     
    mov dl, moving_block_color
    mov cell_color, dl 
    call color_cell  
    jmp for2_mov_left_block      
done_for2_mov_left_block:    
    
    
    sub moving_block_center_y, 16
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp mov_left_block_common   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov_to_end proc
    push ax 
    push bx
    push cx
    push dx
     
mov_to_end_while: 
    call mov_down_block
    cmp check_block_down, 1
    je mov_to_end_while   
    
    pop dx
    pop cx
    pop bx
    pop ax
    RET
endp mov_to_end
;;;;;;;;;;;;;;generate a rand no using the system time;;;;;;;;;;;;;;;;;;;;;;; 
rand_gen proc       
    push ax 
    push bx
    push cx
    push dx 
    
    MOV AH, 00h  ; interrupts to get system time        
    INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
    
    mov  ax, dx
    xor  dx, dx
    mov  cx, rand_num_in    
    div  cx       ; here dx contains the remainder of the division - from 0 to 9
    
    mov rand_num_out, dx
    
    pop dx
    pop cx
    pop bx
    pop ax
    RET
endp rand_gen
;;;;;;;;;;;;generate a new block;;;;;;;;;;;;;;;;; 
gen_new_block proc          
    push ax 
    push bx
    push cx
    push dx 
    
    mov rand_num_in, 5
    call rand_gen
    mov ax, rand_num_out
    
    
    cmp ax,0
    jnz next1_new_block 
    call new_block1_conf
    jmp done_gen_new_block
next1_new_block:
    
    cmp ax,1
    jnz next2_new_block 
    call new_block2_conf
    jmp done_gen_new_block
next2_new_block:
    
    cmp ax,2
    jnz next3_new_block 
    call new_block3_conf
    jmp done_gen_new_block
next3_new_block:
    
    cmp ax,3
    jnz next4_new_block 
    call new_block4_conf
    jmp done_gen_new_block
next4_new_block:
 
    call new_block5_conf
    
done_gen_new_block:       
    pop dx
    pop cx
    pop bx
    pop ax
    RET
endp gen_new_block   
;;;;;;;;;;;;generate a new block;;;;;;;;;;;;;;;;; 
new_block1_conf proc         
    push ax 
    push bx
    push cx
    push dx                  
    
    mov moving_block_mode, 0
    mov moving_block_color, 11
    mov cell_color, 11 
    mov rand_num_in, 5
    call rand_gen
    mov ax, rand_num_out 
    
    mov [moving_block_x], 0  
    mov [moving_block_y], ax  
    mov cell_x, 0
    mov cell_y, ax
    call color_cell 
    inc ax    
    
    
    mov cell_x_index, 0
    mov cell_y_index, ax
    call find_cell_center    
    mov bx, cell_x_pos      
    add bx, 8
    mov moving_block_center_x, bx
    mov bx, cell_y_pos  
    add bx, 8
    mov moving_block_center_y, bx
    
    mov [moving_block_x + 2], 0  
    mov [moving_block_y + 2], ax  
    mov cell_x, 0
    mov cell_y, ax
    call color_cell 
    inc ax 
             
      
    mov [moving_block_x + 4], 0  
    mov [moving_block_y + 4], ax  
    mov cell_x, 0
    mov cell_y, ax
    call color_cell 
    inc ax 
    mov [moving_block_x + 6], 0  
    mov [moving_block_y + 6], ax  
    mov cell_x, 0
    mov cell_y, ax
    call color_cell     
    
    pop dx
    pop cx
    pop bx
    pop ax
    RET
endp new_block1_conf
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
new_block2_conf proc         
    push ax 
    push bx
    push cx
    push dx                  
    
    mov moving_block_mode, 1
    mov moving_block_color, 14
    mov cell_color, 14
     
    mov rand_num_in, 7
    call rand_gen
    mov ax, rand_num_out
    
    mov [moving_block_x], 0  
    mov [moving_block_y], ax  
    mov cell_x, 0
    mov cell_y, ax
    call color_cell   
    
    mov cell_x_index, 0
    mov cell_y_index, ax
    call find_cell_center    
    mov bx, cell_x_pos      
    add bx, 8
    mov moving_block_center_x, bx
    mov bx, cell_y_pos  
    add bx, 8
    mov moving_block_center_y, bx
    
    
    mov [moving_block_x + 2], 1  
    mov [moving_block_y + 2], ax  
    mov cell_x, 1
    mov cell_y, ax
    call color_cell 
    inc ax  
    mov [moving_block_x + 4], 0  
    mov [moving_block_y + 4], ax  
    mov cell_x, 0
    mov cell_y, ax
    call color_cell 
    mov [moving_block_x + 6], 1  
    mov [moving_block_y + 6], ax  
    mov cell_x, 1
    mov cell_y, ax
    call color_cell     
    
    pop dx
    pop cx
    pop bx
    pop ax
    RET
endp new_block2_conf
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
new_block3_conf proc         
    push ax 
    push bx
    push cx
    push dx                  
    
    mov moving_block_mode, 2
    mov moving_block_color, 4
    mov cell_color, 4
     
    mov rand_num_in, 7
    call rand_gen
    mov ax, rand_num_out
    
    mov [moving_block_x], 0  
    mov [moving_block_y], ax  
    mov cell_x, 0
    mov cell_y, ax
    call color_cell 
    mov [moving_block_x + 2], 1  
    mov [moving_block_y + 2], ax  
    mov cell_x, 1
    mov cell_y, ax
    call color_cell  
    
    mov cell_x_index, 1
    mov cell_y_index, ax
    call find_cell_center    
    mov bx, cell_x_pos      
    mov moving_block_center_x, bx
    mov bx, cell_y_pos  
    mov moving_block_center_y, bx
    
    mov [moving_block_x + 4], 2  
    mov [moving_block_y + 4], ax  
    mov cell_x, 2
    mov cell_y, ax
    call color_cell 
    inc ax
    mov [moving_block_x + 6], 2  
    mov [moving_block_y + 6], ax  
    mov cell_x, 2
    mov cell_y, ax
    call color_cell     
    
    pop dx
    pop cx
    pop bx
    pop ax
    RET
endp new_block3_conf
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
new_block4_conf proc         
    push ax 
    push bx
    push cx
    push dx                  
    
    mov moving_block_mode, 3
    mov moving_block_color, 10
    mov cell_color, 10
     
    mov rand_num_in, 7
    call rand_gen
    mov ax, rand_num_out
    
    mov [moving_block_x], 0  
    mov [moving_block_y], ax  
    mov cell_x, 0
    mov cell_y, ax
    call color_cell 
    mov [moving_block_x + 2], 1  
    mov [moving_block_y + 2], ax  
    mov cell_x, 1
    mov cell_y, ax
    call color_cell   
    inc ax
    mov [moving_block_x + 4], 1  
    mov [moving_block_y + 4], ax  
    mov cell_x, 1
    mov cell_y, ax
    call color_cell 
    
    
    mov cell_x_index, 1
    mov cell_y_index, ax
    call find_cell_center    
    mov bx, cell_x_pos      
    mov moving_block_center_x, bx
    mov bx, cell_y_pos  
    mov moving_block_center_y, bx
    
    mov [moving_block_x + 6], 2  
    mov [moving_block_y + 6], ax  
    mov cell_x, 2
    mov cell_y, ax
    call color_cell     
    
    pop dx
    pop cx
    pop bx
    pop ax
    RET
endp new_block4_conf
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
new_block5_conf proc         
    push ax 
    push bx
    push cx
    push dx                  
    
    mov moving_block_mode, 4
    mov moving_block_color, 13
    mov cell_color, 13
     
    mov rand_num_in, 6
    call rand_gen
    mov ax, rand_num_out
    
    mov [moving_block_x], 0  
    mov [moving_block_y], ax  
    mov cell_x, 0
    mov cell_y, ax
    call color_cell     
    inc ax
    mov [moving_block_x + 2], 0  
    mov [moving_block_y + 2], ax  
    mov cell_x, 0
    mov cell_y, ax
    call color_cell
    
    mov cell_x_index, 0
    mov cell_y_index, ax
    call find_cell_center    
    mov bx, cell_x_pos      
    mov moving_block_center_x, bx
    mov bx, cell_y_pos  
    mov moving_block_center_y, bx
  
       
    mov [moving_block_x + 4], 1  
    mov [moving_block_y + 4], ax  
    mov cell_x, 1
    mov cell_y, ax
    call color_cell   
    inc ax
    mov [moving_block_x + 6], 0  
    mov [moving_block_y + 6], ax  
    mov cell_x, 0
    mov cell_y, ax
    call color_cell     
    
    pop dx
    pop cx
    pop bx
    pop ax
    RET
endp new_block5_conf
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc clear_lines 
    push ax 
    push bx
    push cx
    push dx
    
    mov bx,10
    
clear_lines_for1:
    cmp bx,0
    jl done_clear_lines_for1
    mov cx,0
clear_lines_for2:        
    mov check_cell_x, bx
    mov check_cell_y, cx    
    call check_cell_empty 
    cmp check_is_empty, 1  
    je done_clear_lines_for2 
    
    inc cx
    cmp cx, 8
    jl clear_lines_for2
    mov cx, 0
clear_lines_for3:  
    mov cell_x, bx
    mov cell_y, cx
    mov cell_color, 0
    call color_cell  
    
    mov ax, bx
clear_lines_for4: 
    dec ax            
    mov cell_x_down, ax
    mov cell_y_down, cx
    call move_down_cell
    cmp ax, 0
    jg clear_lines_for4
     
    inc cx
    cmp cx, 8
    jl clear_lines_for3  
done_clear_lines_for2:          
    dec bx
    jmp clear_lines_for1
done_clear_lines_for1:
    pop dx
    pop cx
    pop bx
    pop ax
    RET    
endp clear_lines  
;;;;;;;;;;;;;;;;;;;;;
end main                            

