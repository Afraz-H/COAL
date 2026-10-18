[org 0x0100]
jmp start

title:		db 'VIEWPORT DISPLAY', 0
sumStatus:	db 'Total Matches Found:    | Viewport Status: ACTIVE', 0
paragraph:	db 'The cat walked into the garden, and the cat saw another cat sitting beside a tree. The cat slowly approached the cat, but the cat ran away. The cat chased the cat around the garden until the cat got tired. Finally, the cat sat down, and the cat watched the birds flying above the garden.', 0
key: 		db 'cat', 0

clrscn:
	push es
	push ax
	push cx
	push di

	mov ax, 0xb800
	mov es, ax
	xor di, di
	mov ax, 0x0720
	mov cx, 2000
	
	cld
	rep stosw 

	pop di
	pop cx
	pop ax
	pop es
	ret

strlen:
	push bp
	mov bp, sp
	push es
	push cx
	push di

	;[bp + 6] = DS
	;[bp + 4] = strOffset
	
	les di, [bp + 4]
	mov cx, 0xFFFF
	xor al, al
	repne scasb
	mov ax, 0xFFFF
	sub ax, cx
	dec ax

	pop di
	pop cx
	pop es
	pop bp
	ret 4

printTitle:
	push bp
	mov bp, sp
	push es
	push ax
	push cx
	push si
	push di

	;[bp + 10] = Col
	;[bp + 8]  = Row
	;[bp + 6]  = Attribute
	;[bp + 4]  = StrOffset
	
	push ds
	mov ax, [bp + 4]
	push ax
	call strlen
	cmp ax, 0
	jz exit
	
	mov cx, ax
	mov dx, ax
	
	mov ax, 0xB800
	mov es, ax
	shr dx, 1
	sub word [bp + 10], dx
	mov al, 80
	mul byte [bp + 8]
	add ax, [bp + 10]
	shl ax, 1
	mov di, ax
	mov si, [bp + 4]
	mov ah, [bp + 6]
	cld
	
next: 	
	lodsb
	stosw
	loop next

exit:
	pop di
	pop si
	pop cx
	pop ax
	pop es
	pop bp
	ret 8	

printPara:
	push bp
	mov bp, sp
	push es
	push ax
	push cx
	push si
	push di

	mov ax, 0xB800
	mov es, ax
	mov si, [bp + 4]
	mov cx, [bp + 10]
	mov bx, [bp + 8]
	mov ah, [bp + 6]

	;[bp + 10] = Col
	;[bp + 8]  = Row
	;[bp + 6]  = Attribute
	;[bp + 4]  = StrOffset

loop1:
	lodsb
	cmp al, 0
	je done

	push ax
	push dx
	mov ax, bx
	mov dx, 80
	mul dx
	add ax, cx
	shl ax, 1
	mov di, ax
	pop dx
	pop ax

	stosw
	inc cx
	cmp cx, 70
	jl loop1

	mov cx, [bp + 10]
	inc bx
	jmp loop1

done:
	pop di
	pop si
	pop cx
	pop ax
	pop es
	pop bp
	ret 8
	
drawVP:
	push bp
	mov bp, sp
	push es
	push ax
	push bx
	push di
	push cx
	push dx

	;[bp + 4] = EndRow
	;[bp + 6] = EndCol
	;[bp + 8] = StartCol
	;[bp + 10] = StartRow

	mov ax, 0xB800
	mov es, ax

	mov ax, [bp + 10]
	mov dx, 80
	mul dx
	add ax, [bp + 8]
	shl ax, 1
	mov di, ax

	mov cx, [bp + 6]
	mov ax, 0x07C9
	mov [es:di], ax
	add di, 2
	sub cx, 2

l1:
	mov al, 0xCD
	mov [es:di], ax
	add di, 2
	loop l1

	mov al, 0xBB
	mov [es:di], ax

	mov ax, [bp + 10]
	mov dx, 80
	mul dx
	add ax, [bp + 8]
	shl ax, 1
	mov di, ax

	mov cx, [bp + 4]
	dec cx
	mov al, 0xBA
	mov ah, 0x07

l2:
	add di, 160
	mov [es:di], ax
	loop l2

	mov al, 0xC8
	mov [es:di], ax

	mov cx, [bp + 6]
	sub cx, 2

l3:
	add di, 2
	mov al, 0xCD
	mov [es:di], ax
	loop l3

	add di, 2
	mov al, 0xBC
	mov [es:di], ax

	mov ax, [bp + 10]
	mov dx, 80
	mul dx
	add ax, [bp + 8]
	mov bx, [bp + 6]
	dec bx
	add ax, bx
	shl ax, 1
	mov di, ax

	mov cx, [bp + 4]
	sub cx, 2
	mov al, 0xBA
	mov ah, 0x07

l4:
	add di, 160
	mov [es:di], ax
	loop l4

	pop dx
	pop cx
	pop di
	pop bx
	pop ax
	pop es
	pop bp
	ret 8


scroll_window_up:
	push bp
	mov bp, sp
	push es
	push ds
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	cmp word [bp + 12], 0
	je done2
	
	mov ax, 0xB800
	mov es, ax
	mov ds, ax

	; [bp + 12] = Times
	; [bp + 10] = Top Row
	; [bp + 8]  = Left Col
	; [bp + 6]  = Bottom Row
	; [bp + 4]  = Right Col

scrollOuter:
	mov bx, [bp + 10]
	inc bx

scroll:
	mov dx, [bp + 6]
	dec dx
	cmp bx, dx
	jg clearLine

	mov ax, bx
	push dx
	mov dx, 80
	mul dx
	add ax, [bp + 8]
	shl ax, 1
	mov si, ax
	pop dx

	mov ax, bx
	dec ax
	push dx
	mov dx, 80
	mul dx
	add ax, [bp + 8]
	shl ax, 1
	mov di, ax
	pop dx

	mov cx, [bp + 4]
	sub cx, [bp + 8]
	inc cx

	cld
	rep movsw
	inc bx
	jmp scroll

clearLine:
	mov ax, [bp + 6]
	dec ax
	mov dx, 80
	mul dx
	add ax, [bp + 8]
	shl ax, 1
	mov di, ax

	mov cx, [bp + 4]
	sub cx, [bp + 8]
	inc cx

	mov ax, 0x0720
	cld
	rep stosw
	dec word [bp + 12]
	cmp word [bp + 12], 0
	jne scrollOuter

done2:
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop ds
	pop es
	pop bp
	ret 10

find_and_highlight:
	push bp
	mov bp, sp
	sub sp, 8
	push es
	push ds
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	; [bp + 14] = TopRow
	; [bp + 12] = LeftCol
	; [bp + 10] = BottomRow	
	; [bp + 8]  = RightCol
	; [bp + 6]  = SubString
	; [bp + 4]  = Attribute
	; [bp - 2]  = SubStr len
	; [bp - 4]  = CurrCol
	; [bp - 6]  = TempDI
	; [bp - 8]  = Count

	push ds
	mov ax, [bp + 6]
	push ax
	call strlen
	cmp ax, 0
	je done3
	mov [bp - 2], ax

	mov ax, 0xB800
	mov es, ax
	mov bx, [bp + 14]
	mov word [bp - 8], 0
	cld
	
findOuter:
	cmp bx, [bp + 10]
	ja done3

	mov ax, [bp + 12]
	mov [bp - 4], ax
	
sizeCheck:
	mov ax, [bp + 8]
	sub ax, [bp - 4]
	cmp ax, [bp - 2]
	jb nextRow

	mov ax, bx
	mov dx, 80
	mul dx
	add ax, [bp - 4]
	shl ax, 1
	mov di, ax

	mov [bp - 6], di
	mov si, [bp + 6]
	mov cx, [bp - 2]

compare:
	cmpsb
	jne nextCol
	inc di
	dec cx
	jnz compare
	
	mov di, [bp - 6]
	mov cx, [bp - 2]
	inc word [bp - 8]

highlight:
	mov al, [bp + 4]
	mov [es:di + 1], al
	add di, 2
	loop highlight

nextCol:
	inc word [bp - 4]
	jmp sizeCheck

nextRow:
	inc bx
	jmp findOuter	

done3:
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	mov ax, [bp - 8]
	pop ds
	pop es
	mov sp, bp
	pop bp
	ret 12


printNum:
	push bp
	mov bp, sp
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	push ds
	mov ax, [bp + 4]
	push ax
	call strlen
	cmp ax, 0
	jz exit2
	
	mov bx, ax
	mov cx, ax
	mov dx, ax
	
	mov ax, 0xB800
	mov es, ax
	shr dx, 1
	sub word [bp + 10], dx
	mov al, 80
	mul byte [bp + 8]
	add ax, [bp + 10]
	shl ax, 1
	mov di, ax
	mov si, [bp + 4]
	mov ah, [bp + 6]
	cld
	
next2: 	
	lodsb
	stosw
	loop next2

	mov ax, [bp + 12]
	mov bx, 10
	mov cx, 0
	sub di, 56

countDigits:
	mov dx, 0
	div bx
	push dx
	inc cx
	cmp ax, 0
	jne countDigits

printCount:
	pop dx
	add dl, '0'
	mov dh, 0x04
	mov [es:di], dx
	add di, 2
	loop printCount

exit2:
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	pop bp
	ret 10


start:
	call clrscn

	push word 3	;StartRow
	push word 8	;StartCol
	push word 65	;EndCol
	push word 19	;EndRow
	call drawVP

	push word 40	;CenterCol
	push word 2	;Row
	push word 0x1E	;Attirbute
	mov ax, title	;text
	push ax
	call printTitle

	push word 11	;StartCol
	push word 4	;StartRow
	push word 0x07	;Attribute
	mov ax, paragraph
	push ax
	call printPara
	
	push word 0	;NTimes
	push word 4	;TopRow
	push word 11	;FirstCol
	push word 20	;BottomRow
	push word 71	;LastCol
	call scroll_window_up

	push word 4     ; TopRow
	push word 11    ; LeftCol
	push word 20    ; BottomRow
	push word 71    ; RightCol
	mov ax, key
	push ax         ; SubString offset
	push word 0xCE  ; Highlight attribute
	call find_and_highlight

	push ax		;Count
	push word 40	;CenterCol
	push word 23	;Row
	push word 0x0E	;Attirbute
	mov ax, sumStatus;text
	push ax
	call printNum

mov ax, 0x4C00
int 0x21
