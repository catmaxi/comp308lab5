
.286 
.model small
.stack 100h
.data
.code

; check if we have a special case of a horizontal or vertical line
drawLine:
color EQU ss:[bp+4]
x1 EQU ss:[bp+6]
y1 EQU ss:[bp+8]
x2 EQU ss:[bp+10]
y2 EQU ss:[bp+12]

push bp
mov bp, sp

deltaX equ ss:[bp - 2]
deltaY equ ss:[bp - 4]
slope equ ss:[bp - 6]
y0 equ ss: [bp-8]
y equ ss: [bp-10]
x equ ss: [bp-12]
sub sp, 12

;push bp
;mov bp, sp

mov bx, x2
mov ax, y2
mov cx, x1
mov dx, y1
sub bx, cx	                ; BX = X2 -X1

mov deltaX, bx
jz callv
sub ax, dx                  ; AX = Y2 -Y1
mov deltaY, ax
jz callh

xchg ax, bx

div bx						; BX contains the slope
mov slope, bx
mov dx, bx					; Move slope to DX for loop

mov ax, slope
mov bx, x1
mul bx
mov ax, y1
sub ax, bx					; b = mx1 - y1
mov y0, ax					; y0 contains y-intercept

mov bx, x1
mov cx, y1
mov x, bx
mov y, cx

outer:
mov ax, x2
mov bx, x
cmp ax, bx
jz exit
inner:
mov ax, y
mov bx, y2
cmp ax, bx
jz finishith
mov ax, slope
mul bx						; Multiply x by slope
mov dx, y0
sub dx, bx					; DX contains y(x)
cmp cx, dx					; Check if y = y(x)	
jz callpix
finishith:
mov cx, y
inc cx
mov y, cx
mov ax, y2
cmp cx, ax
jnz inner
mov ax, x
inc ax
mov x, ax
jmp outer

callv:
mov ax, y2
mov bx, y1
mov cx, x1
mov dx, color
push ax
push bx
push cx
push dx
call drawLine_v
mov sp, bp
pop bp
ret 10

callh:
mov ax, x2
mov bx, y1
mov cx, x1
mov dx, color
push ax
push bx
push cx
push dx
call  drawLine_h
mov sp, bp
pop bp
ret 10

callpix:
push cx
push bx
push color
call drawPixel
jmp finishith

exit:
mov sp, bp
pop bp
ret 10

; draw a single pixel specific to Mode 13h (320x200 with 1 byte per color)
drawPixel:
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]

	push	bp
	mov	bp, sp

	push	bx
	push	cx
	push	dx
	push	es

	; set ES as segment of graphics frame buffer
	mov	ax, 0A000h
	mov	es, ax


	; BX = ( y1 * 320 ) + x1
	mov	bx, x1
	mov	cx, 320
	xor	dx, dx
	mov	ax, y1
	mul	cx
	add	bx, ax

	; DX = color
	mov	dx, color

	; plot the pixel in the graphics frame buffer
	mov	BYTE PTR es:[bx], dl

	pop	es
	pop	dx
	pop	cx
	pop	bx

	pop	bp

	ret	6
	

; draw a horizontal line
drawLine_h:
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]
	X2 EQU ss:[bp+10]

	push bp
	mov bp, sp

	push    bx
	push    cx

	; BX keeps track of the X coordinate
	mov	bx, x1

	; CX = number of pixels to draw
	mov	cx, x2
	sub	cx, bx
	inc	cx
	dlh_loop:
		push	y1
		push	bx
		push	color
		call	drawPixel
		add	bx, 1
		loopw	dlh_loop
	dlh_end:

	pop     cx
	pop     bx

	pop bp

	ret 8

; draw a vertical line
drawLine_v:
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]
	y2 EQU ss:[bp+10]

	push bp
	mov bp, sp

	push    bx
	push    cx

	; BX keeps track of the Y coordinate
	mov	bx, y1

	; CX = number of pixels to draw
	mov	cx, y2
	sub	cx, bx
	inc	cx
	dlv_loop:
		push	bx
		push	x1
		push	color
		call	drawPixel
		add	bx, 1
		loopw	dlv_loop
	dlv_end:

	pop     cx
	pop     bx

	pop bp

	ret 8

start:
	; initialize data segment
	mov ax, @data
	mov ds, ax

	; set video mode - 320x200 256-color mode
	mov ax, 4F02h
	mov bx, 13h
	int 10h

	; draw a house

	; ; right wall
	
	; push WORD PTR 190
	; push WORD PTR 110
	; push WORD PTR 260
	; push 0002h
	; call drawLine_v

	; ; ; left wall
	push WORD PTR 190
	push WORD PTR 60
	push WORD PTR 110
	push WORD PTR 60
	push 0001h
	call drawLine




	; mov ah, 0
	; int 16h

	; ; switch back to text mode
	; mov ax, 4f02h
	; mov bx, 3
	; int 10h

	; mov ax, 4C00h
	; int 21h

	; right wall
	
	push WORD PTR 190
	push WORD PTR 260
	push WORD PTR 110
	push WORD PTR 260
	push 0002h
	call drawLine

	; ; top
	push WORD PTR 110
	push WORD PTR 260
	push WORD PTR 110
	push WORD PTR 60
	push 0003h
	call drawLine

	; ; floor
	push WORD PTR 190
	push WORD PTR 260
	push WORD PTR 190
	push WORD PTR 60
	push 0004h
	call drawLine
			
	; ; roof left
	; push WORD PTR 160
	; push WORD PTR 110
	; push WORD PTR 60
	; push WORD PTR 50
	; push 0005h
	; call drawLine

	; ; roof right
	; push WORD PTR 260
	; push WORD PTR 10
	; push WORD PTR 160
	; push WORD PTR 20
	; push 0006h
	; call drawLine

	; prompt for a key
	mov ah, 0
	int 16h

	; switch back to text mode
	mov ax, 4f02h
	mov bx, 3
	int 10h

	mov ax, 4C00h
	int 21h

END start
