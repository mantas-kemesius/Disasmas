
.model small
skBufDydis	EQU 20
sk2BufDydis	EQU 20
raBufDydis	EQU 20
.stack 100h

.data
	duom	db "duom.txt",0
	kiek dw 0
	temp dw 0
	p dw 0
	a dw 0
	sek dw 0
	counter dw 0
	bituKiekis dw 0

	min dw 0
	max dw 0

	duom2	db "duom2.txt",0
	rez	db "rez.txt",0
	skBuf	db skBufDydis dup (?)
	skBuf2	db sk2BufDydis dup (?)
	raBuf	db raBufDydis dup (?)
	dFail	dw ?
	d2Fail	dw ?
	rFail	dw ?

.code
.model small
.stack 100h
.data
	buff db 50 dup (?)
	filehandle dw ?
	buffout db 50 dup (?)
	filehandleout dw ?
	
	bufsi db 5500 dup (?)
	bufbx db 255 dup (?)
	ip dw 0100h
	senas_si dw ?
	pabaigos_bx dw ?
	pref db 0
	word_bitas db 0
	v db 0
	d db 0
	sw db 0
	mod_reiksme db ?
	reg_reiksme db ?
	rm_reiksme  db ?
	pavadinimai db 'JMP   ROL   XOR   SAR   MOVSB MOVSW CMPSB CMPSW STOSB STOSW LODSB LODSW SCASB SCASW REPNE REP   '
	  ;jmp-0 rol-6 xor-12 sar-18 movsb-24 movsw-30 cmpsb-36 cmpsw-42 stosb-48 stosw-54 lodsb-60 lodsw-66 scasb-72 scasw-78 repne-84 rep-90
	regpavadinimai db 'alaxclcxdldxblbxahspchbpdhsibhdi'
	  ;al-2ax-4cl-6cx-8dl-10dx-12bl-14bx-16ah-18sp-20ch-22bp-24dh-26si-28bh-30di-32
	zinute1 db 'pvz teo.exe com.com ats.txt', 10, 13, '$'
	zinute2 db 'failo nepavyko atidaryti', 10, 13
	zinute3 db 'failo nepavyko sukurti', 10, 13
.code
start:
	mov dx, @data
	mov ds, dx
;------------------------tikrinu ar yra parsyti parametrai arba /?	
	call arklaustukas
	xor cx, cx
	mov cl, es:[80h]
;------------------------jei nera parametru soku i exit	
	cmp cx, 0
	jnz toliau
	jmp exit
;------------------------pradedu skaityti parametrus	
toliau:
	mov si, 0081h
	xor bx, bx
;-----------------------skaitau pirma parametra
loop1:
	mov al, es:[si + bx]
	mov ds:[buff + bx], al
	
	cmp buff[bx], 20h
	jne praleidimas
	cmp bx, 1
	jng praleidimas
	
	lea dx, buff[1]
	mov ax, 3D00h
	int 21h
	call ar_atsidare
	mov filehandle, ax
	add si, bx
	xor bx, bx
	jmp loop2
	
praleidimas:
	inc bx
	loop loop1
;---------------------skaitau ir kuriu antra parametra	
loop2:
	mov al, es:[si + bx]
	mov ds:[buffout + bx], al
	inc bx
loop loop2

	lea dx, buffout[1]
	mov ax, 3C00h
	mov cx, 0
	int 21h
	call ar_sukure
	
	mov filehandleout, ax
;----------------------baigiu skaityti parametrus


;------------------------------------------ tikrina ar kaip parametras ivestas /?
	arklaustukas proc near
		push ax
		push dx
	
		mov dl, es:[82h]
		cmp dl, '/'
		jne ne_klaustukas
		mov dl, es:[83h]
		cmp dl, '?'
		jne ne_klaustukas
		mov ax, 4000h
		mov dx, offset zinute1
		mov cx, 29
		mov bx, 1
		int 21h
		mov ax, 4C00h
		int 21h
	ne_klaustukas:
		pop ax
		pop dx
		ret
	arklaustukas endp
;------------------------------------------ tikrina ar atsidare com failas
	ar_atsidare proc near
		cmp ax, 4
		ja failas_atidaryts
		mov ax, 4000h
		mov bx, 1
		mov cx, 26
		mov dx, offset zinute2
		int 21h
		mov ax, 4C00h
		int 21h
	failas_atidaryts:
		ret
	ar_atsidare endp
;------------------------------------------ tikrina ar susikure faials
	ar_sukure proc neaar
		cmp ax, 4
		ja failas_sukurtas
		mov ax, 4000h
		mov bx, 1
		mov cx, 24
		mov dx, offset zinute2
		int 21h
		mov ax, 4C00h
		int 21h
	failas_sukurtas:
		ret
	ar_sukure endp
;------------------------------------
	
exit:
	mov cx, bx
	mov ax, 4000h
	mov bx, filehandleout
	mov dx, offset bufbx
	int 21h

	mov ax, 4C00h
	int 21h
	
end start