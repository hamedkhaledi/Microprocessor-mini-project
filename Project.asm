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
     
     is_down_empty db 0
     cell_x_down dw 0
     cell_y_down dw 0
     
     cell_x_color_get dw 0 ; for get_color_of_cell (get color of specific cell)
     cell_y_color_get dw 0 
     cell_color_get db 0   
     
     check_cell_x dw 0
     check_cell_y dw 0
     check_is_empty dw 0
     seconds db 0  ;?¦¦ VARIABLE IN DATA SEGMENT.
     
.code 


main proc far
    mov ax, @data
    mov ds, ax   
    call clear_screen    
    call set_graphic_mode 
    call create_background
    mov bx, 0    
    
    mov cell_x, 0
    mov cell_y, 4
    mov cell_color, 1  
    call color_cell  
    
    mov cell_x, 5
    mov cell_y, 4
    mov cell_color, 3  
    call color_cell

    mov cell_y_down, 4 

for_temp:  
    call delay 
    call move_down_cell   
    inc bx   
    mov cell_x_down, bx
    cmp bx,20
    jnz for_temp

    mov ax, 4c00h ; exit to operating system.
    int 21h    

main endp

;;;;;;;;;;;;;;;;;
clear_screen proc
    mov al, 06h ; scroll down
    mov bh, 00h
    mov cx, 0000h
    mov dx, 28ffh
    int 10h
                 
    ret                    
endp clear_screen 

;;;;;;;;;;;;;;;;;
set_graphic_mode proc
    mov ah, 00h
    mov al, 13h
    int 10h 
    
    ret
endp set_graphic_mode

;;;;;;;;;;;;;;;;;
create_background proc  

    mov start_row_line , 20 
    mov start_col_line , 100
    mov finish_col_line , 228
    mov finish_row_line , 196
    
    mov cx, start_col_line
    
back_loop1:   
    mov start_col_line, cx 
    push cx        
    call draw_vertical_line 
    pop cx
    add cx, 16
    cmp cx, finish_col_line
    jle back_loop1         


    mov start_col_line , 100 
    mov dx, start_row_line
    
back_loop2:  
    mov start_row_line, dx  
    push dx        
    call draw_horizontal_line 
    pop dx
    add dx, 16
    cmp dx, finish_row_line
    jle back_loop2  
        
    ret
endp create_background 

;;;;;;;;;;;;;;;;;
draw_vertical_line proc 
    mov ah, 0ch 
    mov al, 8
     
    mov dx, start_row_line  
    mov cx, start_col_line
loop_vertical1:
    int 10h
    inc dx
    cmp dx, finish_row_line
    jnz loop_vertical1 

    ret   
endp draw_vertical_line 

;;;;;;;;;;;;;;;;;
draw_horizontal_line proc 
    mov ah, 0ch 
    mov al, 8
     
    mov dx, start_row_line  
    mov cx, start_col_line
loop_horizontal1:
    int 10h
    inc cx
    cmp cx, finish_col_line
    jnz loop_horizontal1 

    ret   
endp draw_horizontal_line   

;;;;;;change color of specific cell;;;;;;;;;;;
color_cell proc   
    push ax 
    push bx
    push cx         
    
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
    pop cx
    pop bx
    pop ax
    
    ret
endp color_cell 

;;;;;;;;;;;;;;;;;
draw_solid_rectangle proc 
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
 
    pop cx
    pop bx
    pop ax
    ret
endp find_cell_center 

;;;;;;;;;;;;;;;;;
move_down_cell proc ;todo
    push ax 
    push bx
    push cx
    push dx
    
    
    mov ax, cell_x_down  
    mov check_cell_x, ax
    inc check_cell_x  
    
    mov ax, cell_y_down  
    mov check_cell_y, ax
    
    call check_cell_empty
    cmp  check_is_empty, 0
    je   done       
    
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
done:       
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
;;;;;;;;;;;;;;;;;
end main