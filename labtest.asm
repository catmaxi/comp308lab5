mov bx, dx
mov ax, di
sub bx, cx ; BX = X2 - X1
jz short .dlf_vertloop
sub ax, si ; AX = Y2 - Y1
jz short .dlf_horzloop
finit ; initialize FPU
; make sure we are drawing along the right axis, so that our slope is <= 1
cmp ax, bx
ja short .dlf_yorient ; (Y2 - Y1) > (X2 - X1) ? If so, change axis of drawing
fild WORD PTR[bp+12] ; ST(0) = Y1(floating point value on FPU stack)
fld st(0) ; ST(1) = ST(0) = Y1
fisubr WORD PTR[bp+8] ; ST(0) = Y2 - Y1
fild WORD PTR[bp+10] ; ST(0) = X2
fisub WORD PTR[bp+14] ; ST(0) = X2 - X1
fdiv ; ST(0) = (X2 - X1)/(Y2 - Y1)(slope), ST(1) = Y1

add cx, 1 ; next X
fadd st(0), st(1) ; calculate next Y (prev Y + slope)
fist WORD PTR[bp-14] ; overwrite stack argument Y
mov [bp-12], cx ; overwrite stack argument X
call draw_pixel