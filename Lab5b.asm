.286 
.model small
.stack 100h
.data
.code

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

	; set ES as segment of graphisi frame buffer
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

	; plot the pixel in the graphisi frame buffer
	mov	BYTE PTR es:[bx], dl

	pop	es
	pop	dx
	pop	cx
	pop	bx

	pop	bp

	ret	6
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]
	x2 EQU ss:[bp+10]

; draw a horizontal line







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
		sub	dx, 1 ; This is the difference
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
		add	dx, 1 ; This is the difference
		loopw	dld2_loop
	dld2_end:

	pop	dx
	pop     cx
	pop     bx

	pop bp

	ret 8
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


drawLine:
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]
	x2 EQU ss:[bp+10]
	y2 EQU ss:[bp+12]

	mov bx, x2
	mov cx, x1
	mov ax, y2
	mov dx, y1
	; sub bx, cx ; BX = X2 - X1
	push cx
	push dx
	push ax
	mov cx, color
	push cx
	call drawLine_v
	; sub ax, dx ; AX = Y2 - Y1
	; jz drawLine_h
	; finit ; initialize FPU
	; ; make sure we are drawing along the right axis, so that our slope is <= 1
	; cmp ax, bx
	; ; ja short drawLine_d1 ; (Y2 - Y1) > (X2 - X1) ? If so, change axis of drawing
	; fild WORD PTR[bp+12] ; ST(0) = Y1(floating point value on FPU stack)
	; fld st(0) ; ST(1) = ST(0) = Y1
	; fisubr WORD PTR[bp+8] ; ST(0) = Y2 - Y1
	; fild WORD PTR[bp+10] ; ST(0) = X2
	; fisub WORD PTR[bp+14] ; ST(0) = X2 - X1
	; fdiv ; ST(0) = (X2 - X1)/(Y2 - Y1)(slope), ST(1) = Y1

	; add cx, 1 ; next X
	; fadd st(0), st(1) ; calculate next Y (prev Y + slope)
	; fist WORD PTR[bp-14] ; overwrite stack argument Y
	; mov [bp-12], cx ; overwrite stack argument X
	; call drawPixel

	ret 10



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
	push WORD PTR 60
	push WORD PTR 110
	push WORD PTR 60
	push 0001h
	call drawLine


	; push WORD PTR 190
	; push WORD PTR 110
	; push WORD PTR 60
	; push 0001h
	; call drawLine_v

	; ; right wall
	push WORD PTR 190
	push WORD PTR 260
	push WORD PTR 110
	push WORD PTR 260
	push 0001h
	call drawLine

	; ; top
	; push WORD PTR 260
	; push WORD PTR 110
	; push WORD PTR 60
	; push 0003h
	; call drawLine_h

	; ; floor
	; push WORD PTR 260
	; push WORD PTR 190
	; push WORD PTR 60
	; push 0004h
	; call drawLine_h
			
	; ; roof left
	; push WORD PTR 160
	; push WORD PTR 110
	; push WORD PTR 60
	; push 0005h
	; call drawLine_d1

	; ; roof right
	; push WORD PTR 260
	; push WORD PTR 10
	; push WORD PTR 160
	; push 0006h
	; call drawLine_d2

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
		sub	dx, 1 ; This is the difference
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
		add	dx, 1 ; This is the difference
		loopw	dld2_loop
	dld2_end:

	pop	dx
	pop     cx
	pop     bx

	pop bp

	ret 8