[org 0x0100]
	jmp start
	
trap_bool: DW 0
flag: db 0
oldISR: dd 0
strStk:db 'Stack'
strFlg:db 'Flags'
stkInd:db '+0+2+4+6'
myName: db 'Hafiz Muhammad Hamza','      L12-4013      ','Copyrights 2013 HaZa','All Rights Reserved '
cmd: db 'CMD > '
strline: db '________________________________________________________________________________'
m2DS1: db '0 1   2 3   4 5   6 7   8 9   A B   C D   E F'
m1DS2: db 'DS:0000  DS:0008  DS:0010  DS:0018  DS:0020  DS:0028  DS:0030  DS:0038  DS:0040  DS:0048  '
m2DS2: db 'DS:0000   DS:0010   DS:0020   DS:0030   DS:0040   '
regNames: db 'CS        IP        BP        SP        AX        BX        CX        DX        SI        DI        DS        ES        SS        FS                              '
flagBits:db'OF DF IF SF ZF AF PF CF '

clearScreen:
	mov ax , 0xB800
	mov es , ax
	mov di , 0
	mov ax , 0x0720
	mov cx , 2000
		
	rep stosw
	
	ret
	
printNum:			;[BP+8]=y-coordinate  [BP+6]=x-coordinate  [BP+4]=number
	push bp
	mov bp , sp
	push ax
	push bx
	push cx
	push dx
	push di
	push es
	
	mov di , 80
	mov ax , [bp+8]
	mul di
	mov di , ax
	add di , [bp+6]
	shl di , 1
	add di , 8
	
	mov ax , 0xB800
	mov es , ax
	mov ax , [bp+4]
	mov bx , 16
	mov cx , 4
	nextDigit:
		mov dx , 0
		div bx
		add dl , 0x30
		cmp dl , 0x39
		jbe noAlphabet
		add dl , 7
		
		noAlphabet:
			mov dh , 0x0A
			mov [es:di] , dx
			sub di , 2
			loop nextDigit
	
	pop es
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
	
printStr:
	
	push bp
	mov bp , sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push es
	
	mov ax , 0xB800
	mov es , ax
	
	mov di , 80
	mov ax , [bp+10]
	mul di
	mov di , ax
	add di , [bp+8]
	shl di , 1
	
	mov si , [bp+6]
	mov cx , [bp+4]
	mov ah , 0x07
	
	nextChar:
		mov al , [si]
		mov [es:di] , ax
		add di , 2
		inc si
		loop nextChar
		
	pop es
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 8
	
keyboardISR:
	push ax
	in al , 0x60
	
	cmp al , 0x43			;F9
	jnz skip
	add byte [cs:flag] , al
	mov word [cs:trap_bool],0
	skip:
	
	cmp al , 0x44
	jnz KBquit
	add byte [cs:flag] , al
	mov word [cs:trap_bool],1
	
	KBquit:
	pop ax
	jmp far [cs:oldISR]
			

ISR3:
	
	mov word [cs:trap_bool],0
	iret

trapISR:
	
	push bp
	mov bp , sp
	push sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push ds
	push es
	push ss
	push fs
	
	sti					;waiting for keyboard interrupt
	
	push cs
	pop ds
	mov byte [flag] , 0
	call clearScreen
	
	;****************** PRINTING BOXES AND JUNK**********************
	
	push 0xB800
	pop es
	mov ax , 0x077C
	mov di , 892
	mov cx , 11
	straightLine:
		stosw
		add di , 158
		loop straightLine
		
	mov di , 2838
	mov cx , 6
	straightLine2:
		stosw
		add di , 158
		loop straightLine2
	
	push 4
	push 0
	push strline
	push 80
	call printStr			
	
	push 6
	push 0
	push strline
	push 46
	call printStr
	
	push 16
	push 0
	push strline
	push 80
	call printStr	

	push 23
	push 0
	push strline
	push 80
	call printStr	
	
	mov di , 3000
	mov cx , 20
	mov si , myName
	mov ah , 0x8B
	prtName:
		lodsb
		stosw
		loop prtName
	
	mov di , 3160
	mov cx , 20
	mov ah , 0x0D
	prtRoll:
		lodsb
		stosw
		loop prtRoll

	
	mov di , 3480
	mov cx , 20
	mov ah , 0x70
	prtCopyrights:
		lodsb
		stosw
		loop prtCopyrights
	
	
	mov di , 3640
	mov cx , 20
	mov ah , 0x70
	prtReserved:
		lodsb
		stosw
		loop prtReserved

	mov di , 800
	mov cx , 6
	mov ah , 0x07
	prtCMD:
		lodsb
		stosw
		loop prtCMD
	
	
	;******************* PRINTING FLAGS NAMES ***************
	
	push 0
	push 57
	push strFlg
	push 5
	call printStr			;to print "Flags"
	
	mov ax , 2				;row 
	mov bx , 57				;column
	mov cx , 9
	mov si , 3				;lenght
	mov dx , flagBits
	
	printFLnames:
		push ax
		push bx
		push dx
		push si
		call printStr
		add dx , 3
		add bx , 3
		loop printFLnames
	
	;******************* PRINTING FLAGS VALUES ***************
	
	push 0
	push 63
	mov dx , [bp+6]
	push dx
	call printNum			;prints whole of the flag register
	
	
	
	push 0xB800
	pop es
	mov di , 596
	
	mov dx , [bp+6]			;DX=Flag register
	
	shl dx , 4
	mov cx , 3
	mov ah , 0x0A
	Fl1:
		mov al , 0x30
		shl dx , 1
		jnc Fl1proceed
		mov al , 0x31
		Fl1proceed:
		stosw
		add di , 4
		loop Fl1
	
	shl dx , 1
	mov cx , 2
	Fl3:
		mov al , 0x30
		shl dx , 1
		jnc Fl3proceed
		mov al , 0x31
		Fl3proceed:
		stosw
		add di , 4
		loop Fl3
	
	
	mov cx , 3
	
	Fl2:
		mov al , 0x30
		shl dx , 2
		jc Fl2proceed
		mov al , 0x31
		Fl2proceed:
		stosw
		add di , 4
		loop Fl2	
	
		;******************* PRINTING REGISTERS NAMES ***************
	
	mov ax , 0				;row 
	mov bx , 0				;column
	mov cx , 4
	mov si , 40				;lenght
	mov dx , regNames
	
	printNames:
		push ax
		push bx
		push dx
		push si
		call printStr
		add dx , 40
		add ax , 1
		loop printNames

	
	;******************* PRINTING REGISTER VALUES ***************
	
	mov di , 0
	mov si , 4
	mov cx , 14
	mov ax , 0				;row 
	mov bx , 2				;column
	
	printValues:
		push ax
		push bx
		mov dx , [bp+si]
		push dx
		call printNum
		sub si , 2
		add bx , 10
		inc di
		cmp di , 4
		jnz cntPrt
		
		mov di , 0
		inc ax
		mov bx , 2
		cntPrt:
			loop printValues
	
	;******************** PRINTING STACK STRINGS **************
	
	push 0
	push 42
	push strStk
	push 5
	call printStr			;to print "Stack"
	
	mov ax , 0				;row 
	mov bx , 48				;column
	mov cx , 4
	mov si , 2				;lenght
	mov dx , stkInd
	
	prtStk:
		push ax
		push bx
		push dx
		push si
		call printStr
		add dx , 2
		inc ax
		loop prtStk
	
	
	
	;******************* PRINTING STACK VALUES ***************
	
	mov ax , [bp-20]		;AX=SS
	mov es , ax
	mov di , [bp-2]
	mov cx , 4
	mov ax , 0				;row 
	mov bx , 50				;column
	
	printStackValues:
		push ax
		push bx
		mov dx , [es:di]
		push dx
		call printNum
		add di , 2
		inc ax
		loop printStackValues
	
			;******************* PRINTING m2DS NAMES ***************
	
	push 17
	push 11
	push m2DS1
	push 45
	call printStr			
	
	push 0xB800
	pop es
	mov word [es:2720] , 0x7032
	
	mov ax , 18				;row 
	mov bx , 0				;column
	mov cx , 5
	mov si , 10				;lenght
	mov dx , m2DS2
	
	printm2DS2N:
		push ax
		push bx
		push dx
		push si
		call printStr
		add dx , 10
		inc ax
		loop printm2DS2N
	
	;******************* PRINTING m2DS VALUES ***************
	
	push cs
	pop ds
	
	mov si , 0
	mov di , 0
	mov cx , 40
	mov ax , 18				;row 
	mov bx , 9				;column
	
	printm2DSValues:
		push ax
		push bx
		mov dx , [ds:si]
		xchg dl , dh 			;little endian order
		push dx
		call printNum
		add si , 2
		add bx , 6
		inc di
		cmp di , 8
		jnz cntPrtm2DS
		
		mov di , 0
		inc ax
		mov bx , 9
		cntPrtm2DS:
			loop printm2DSValues
	
	
			;******************* PRINTING m1DS NAMES ***************
	
	push 5
	push 59
	push m2DS1
	push 21
	call printStr			
	
	push 0xB800
	pop es
	mov word [es:896] , 0x7031
	
	mov ax , 6				;row 
	mov bx , 48				;column
	mov cx , 10
	mov si , 9				;lenght
	mov dx , m1DS2
	
	printm1DS2N:
		push ax
		push bx
		push dx
		push si
		call printStr
		add dx , 9
		inc ax
		loop printm1DS2N
	
	;******************* PRINTING m1DS VALUES ***************
	
	push cs
	pop ds
	
	mov si , 0
	mov di , 0
	mov cx , 40
	mov ax , 6				;row 
	mov bx , 57				;column
	
	printm1DSValues:
		push ax
		push bx
		mov dx , [ds:si]
		xchg dl , dh 		;little endian order
		push dx
		call printNum
		add si , 2
		add bx , 6
		inc di
		cmp di , 4
		jnz cntPrtm1DS
		
		mov di , 0
		inc ax
		mov bx , 57
		cntPrtm1DS:
			loop printm1DSValues
	
	CMP WORD [CS:trap_bool],1
	JE SKIP_WAIT
	
	keyWait:
		cmp byte[CS:flag] , 0
		je keyWait
	
	SKIP_WAIT:
	
	pop fs
	pop ss	
	pop es
	pop ds
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop sp
	pop bp
	iret
	
	
start:
	xor ax , ax
	mov es , ax			;point ES to IVT table
	mov ax , [es:9*4]
	mov [oldISR] , ax
	mov ax , [es:9*4+2]
	mov [oldISR+2] , ax
	mov word [es:1*4] , trapISR
	mov [es:1*4+2] , cs
	
	cli
		mov word [es:9*4] , keyboardISR
		mov [es:9*4+2] , cs
		
		mov word [es:3*4] , ISR3
		mov [es:3*4+2] , cs
		
	sti
	
	mov dx,start
	add dx,15
	mov cl,4
	shr dx , cl
	
	mov ax,0x3100
	int 21h