.286 
.model small
.stack 100h
.data
.code

fibonacci:
  x equ ss:[bp + 4] 
  
  push bp
  mov bp, sp
  
  r1 equ ss:[bp - 2]
  r2 equ ss:[bp - 4]
  sub sp, 4

  mov ax, x
  cmp ax, 0
  je fibonacci_0
  cmp ax, 1
  je fibonacci_1 
  
  ;; defualt 
  mov ax, x
  sub ax, 1
  push ax 
  call fibonacci
  mov r1, ax 
  mov ax, x 
  sub ax, 2
  push ax
  call fibonacci
  mov r2, ax 

  mov ax, r1
  add ax, r2 
  
  mov sp, bp 
  pop bp
  ret 2 
fibonacci_0:
  mov ax, 0
  mov sp, bp
  pop bp 
  ret 2 
fibonacci_1:
  mov ax, 1
  mov sp, bp
  pop bp 
  ret 2

start:


  push 6
  call fibonacci

  add ax, 48

  mov dx, ax
  mov ah, 02h
  int 21h  

  mov ax, 4C00h
  int 21h

END start