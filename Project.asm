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
     
     seconds db 0  ;?¦¦ VARIABLE IN DATA SEGMENT.
.code 


main proc far
    mov ax, @data
    mov ds, ax   
    call clear_screen    
    call set_graphic_mode 
    call color_cell
    call create_background
    mov bx, 0    
    
for_temp:
    mov cell_color,0
    push bx  
    call delay
    call color_cell   
    pop bx 
    push bx
    mov cell_x , bx 
    mov cell_color,1 
    call color_cell   
    pop bx    
    inc bx  
    cmp bx,11
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

;;;;;;;;;;;;;;;;;
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
shift_rectangle proc
    mov ah, 0ch 
    mov al, 0
    mov dx, start_row_rec
    mov cx, start_col_rec 
loop3:   
    int 10h
    inc dx
    cmp dx, finish_row_rec
    jnz loop3
              
              
    mov al, 1
    mov dx, start_row_rec
    mov cx, finish_col_rec 
loop4:
    int 10h    
    inc dx
    cmp dx, finish_row_rec
    jnz loop4         
    
    inc start_col_rec
    inc finish_col_rec    
    
    ret                        
endp shift_rectangle                                

;;;;;;;;;;;;;;;;; 


delay proc  
delaying:   
;GET SYSTEM TIME.
  mov  ah, 2ch
  int  21h      ;?¦¦ RETURN SECONDS IN DH.
;CHECK IF ONE SECOND HAS PASSED. 
  cmp  dh, seconds  ;?¦¦ IF SECONDS ARE THE SAME...
  je   delaying     ;    ...WE ARE STILL IN THE SAME SECONDS.
  mov  seconds, dh  ;?¦¦ SECONDS CHANGED. PRESERVE NEW SECONDS.
  ret
delay endp 
;;;;;;;;;;;;;;;;;
   
end main