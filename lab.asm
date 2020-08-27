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


	; Draline line general
	drawLine:
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]
	x2 EQU ss:[bp+10]
	y2 EQU ss:[bp+12]

	push bp
	mov bp, sp

	push    bx
	push    cx

	; BX keeps track of the X coordinate
	mov	bx, x1
	
	; deltaX
	mov ax, x2
	; mov dx, x1
	sub ax, x1
	
	; deltaY
	mov bx, y2
	sub bx, y1
	

	max_int:
	cmp ax, bx
	jae if_x_ge_y

	;else
	mov cx, bx
	jmp finish_max_int

	if_x_ge_y:
	mov cx, ax
	; jmp finish_max_int

	finish_max_int:
	
		; if both are equal then we can run the loop
	cmp ax, bx
	je preloop
	
	; if at least one of them is zero then we can just run the loop
	mov dx, ax
	and dx, bx
	not dx
	
	cmp dx, 1
	je preloop
	
	;else
	; then we have to set both of them equal to the max
	mov ax, cx
	mov bx, cx

	
	preloop:

	; div cx
	; mov dx, ax
	; mov ax, bx
	; div cx
	; mov bx, ax
	; mov ax, dx
	
	mov ax, 0
	mov bx, 1
	


	; CX = number of pixels to draw
	; mov bx, x1
	; mov	cx, x2
	; sub	cx, bx
	inc	cx

	push cx
	push bx
	push ax
	push y2
	push x2
	push y1
	push x1
	push color
	

	dl_loop:
		
		call loopfun
		; mov dx, total
		; sub dx, cx
		; push ax
		; mov ax, dx
		; mov bx, deltaY
		; mul bx
		; mov dx, ax
		; pop ax
		; mov ax, y1
		; add ax, dx
		
		; push ax
		
		
		;mov bx, dx
		; mov dx, total
		; sub dx, cx
		; push ax
		; mov ax, dx
		; mul bx
		; mov dx, ax
		; pop ax
		; mov ax, x1
		; add ax, dx
		; pop dx
		; pop bx
		; push ax


		; mov dx, total
		; sub dx, cx
		; push ax
		; mov ax, dx
		; mov bx, deltaX
		; mul bx
		; mov dx, ax
		; pop ax
		; mov ax, x1
		; add ax, dx
		
		; push ax
		
		; pop ax
		; pop bx
		; push ax
		; push bx

		; mov ax, dx
		; mov bx, bx


		; push	color
		; call	drawPixel

		; sub cx, 1
		; cmp cx, 150
		; jne dl_loop

		;loopw	dl_loop
	dl_end:

	pop cx
	pop cx 
	pop cx
	pop     cx
	pop     bx

	pop bp

	ret 10
	

	
	; loop function
	loopfun:
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]
	x2 EQU ss:[bp+10]
	y2 EQU ss:[bp+12]
	deltaX EQU ss:[bp+14]
	deltaY EQU ss:[bp+16]
	total EQU ss:[bp+18]
	push bp
	mov bp, sp

	mov cx, total

	loop_begin:
	
	mov cx, 0
	

	; mov dx, 100
	; sub dx, cx
	; push ax
	; mov ax, dx
	; mov bx, 1
	; mul bx
	; mov dx, ax
	; pop ax
	; mov ax, y1
	; add ax, dx
	mov ax, 1
	mul cx
	mov bx, y1
	add ax, bx
		
	push ax

	; mov dx, 100
	; sub dx, cx
	; push ax
	; mov ax, dx
	; mov bx, 1
	; mul bx
	; mov dx, ax
	; pop ax
	; mov ax, x1
	; add ax, dx
	mov ax, 0
	mul cx
	mov bx, x1
	add ax, bx
		
	push ax
	push color
	
	call drawPixel
	
	add cx, 1
	cmp cx, 100
	jne loop_begin
	
	loopend:



	pop bp
	ret 16

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
	push WORD PTR 100
	push WORD PTR 0
	push WORD PTR 1
	push WORD PTR 110
	push WORD PTR 160
	push WORD PTR 110
	push WORD PTR 60
	
	push 0003h
	call drawLine

	; left wall
	; push WORD PTR 190
	; push WORD PTR 110
	; push WORD PTR 60
	; push 0001h
	; call drawLine_v

	; ; right wall
	; push WORD PTR 190
	; push WORD PTR 110
	; push WORD PTR 260
	; push 0002h
	; call drawLine_v

	; ; top
	; push WORD PTR 260
	; push WORD PTR 110
	; push WORD PTR 60
	; push 0003h
	; call drawLine_h

	; ; floor
	; push WORD PTR 260; left wall
	; push WORD PTR 190
	; push WORD PTR 110
	; push WORD PTR 60
	; push 0001h
	; call drawLine_v

	; ; right wall
	; push WORD PTR 190
	; push WORD PTR 110
	; push WORD PTR 260
	; push 0002h
	; call drawLine_v

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