.286 
.model small
.stack 100h
.data
.code

; check if we have a special case of a horizontal or vertical line
drawLine:
color EQU ss:[bp+4]
y2 EQU ss:[bp+6]
x2 EQU ss:[bp+8]
y1 EQU ss:[bp+10]
x1 EQU ss:[bp+12]
push bp
mov bp, sp
mov bx, x2
mov ax, y2
mov cx, x1
mov si, y1
sub bx, cx	                ; BX = X2 -X1
jz  drawLine_h
sub ax, si                  ; AX = Y2 -Y1
jz drawLine_v
finit                           ; initialize FPU
; make sure we are drawing along the right axis, so that our slope is <= 1
cmp ax, bx 
;ja short .dlf_yorient		; (Y2 -Y1) > (X2 -X1) ? If so, change axis of drawing
fild WORD PTR [bp+12]           ; ST(0) = Y1(floating point value on FPU stack)
fld st(0)                   ; ST(1) = ST(0) = Y1
fisubr WORD PTR[bp+8]          ; ST(0) = Y2 -Y1
fild WORD PTR[bp+10]         ; ST(0) = X2
fisub WORD PTR[bp+14]         ; ST(0) = X2 -X1    
fdiv
; ST(0) = (X2 -X1)/(Y2 -Y1)(slope), ST(1) = Y1
add cx, 1                   ; next X
fadd st(0), st(1)            	; calculate next Y (prevY + slope)
fist WORD PTR[bp-14]         ; overwrite stack argument Y
mov [bp-12], cx
pop bp             ; overwrite stack argument X
call drawPixel

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
	y2 EQU ss:[bp+12]

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


; draw a right increasing diagonal line
drawLine_d1:
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]
	x2 EQU ss:[bp+10]

	push bp
	mov bp, sp

	push    bx
	push    cx
	push	dx

	; BX keeps track of the X coordinate,
	; DX keeps track of the Y coordinate
	mov	bx, x1
	mov	dx, y1

	; CX = number of pixels to draw
	mov	cx, x2
	sub	cx, bx
	inc	cx
	dld1_loop:
		push	dx
		push	bx
		push	color
		call	drawPixel
		add	bx, 1
		sub	dx, 1
		loopw	dld1_loop
	dld1_end:

	pop	dx
	pop     cx
	pop     bx

	pop bp

	ret 8


; draw a right decreasing diagonal line
drawLine_d2:
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]
	x2 EQU ss:[bp+10]

	push bp
	mov bp, sp

	push    bx
	push    cx
	push	dx

	; BX keeps track of the X coordinate,
	; DX keeps track of the Y coordinate
	mov	bx, x1
	mov	dx, y1

	; CX = number of pixels to draw
	mov	cx, x2
	sub	cx, bx
	inc	cx
	dld2_loop:
		push	dx
		push	bx
		push	color
		call	drawPixel
		add	bx, 1
		add	dx, 1
		loopw	dld2_loop
	dld2_end:

	pop	dx
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

	; left wall
	push WORD PTR 190
	push WORD PTR 110
	push WORD PTR 60
	push 0001h
	call drawLine

	; right wall
	push WORD PTR 190
	push WORD PTR 110
	push WORD PTR 260
	push 0002h
	call drawLine

	; top
	push WORD PTR 260
	push WORD PTR 110
	push WORD PTR 60
	push 0003h
	call drawLine

	; floor
	push WORD PTR 260
	push WORD PTR 190
	push WORD PTR 60
	push 0004h
	call drawLine
			
	; roof left
	push WORD PTR 160
	push WORD PTR 110
	push WORD PTR 60
	push 0005h
	call drawLine

	; roof right
	push WORD PTR 260
	push WORD PTR 10
	push WORD PTR 160
	push 0006h
	call drawLine

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