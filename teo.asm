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
;----------------------nuskaitau pirmus simbolius
	mov ah, 3Fh
	mov bx, filehandle
	mov cx, 5500
	mov dx, offset bufsi
	int 21h
	
	mov cx, ax
;----------------------cx bus reikalingas iseiti is pagrindinio ciklo
;----------------------nusinulinu parametrus
	xor si,si
	xor bx,bx
	xor ax,ax
	xor bx,bx
	xor dx,dx
;--------------------------pradedu pagrindinio ciklo (main loop) tikrinimo dali


Pagrindinis_ciklas:
	mov senas_si, si
	call spausdinti_ip
	call sekos_spausdinimas
;------------------------------------------pradedu pagrindinio ciklo (main loop) komandos atpazinimo dali

	
	call arprefiksas
	
	cmp bufsi[si], 11101001b
	jne ne_jmp
	mov ax, 0
	call pavadinimo_isspausdinimas
	inc si
	call baitinis_jmp
	jmp Tesiamas_ciklas
	
ne_jmp:
	cmp bufsi[si], 11101010b
	jne ne_jmp2
	mov ax, 0
	call pavadinimo_isspausdinimas
	inc si
	call isorinis_jmp
	jmp Tesiamas_ciklas
	
ne_jmp2:
	cmp bufsi[si], 11101011b 
	jne ne_jmp3
	mov ax, 0
	call pavadinimo_isspausdinimas
	inc si
	call tiesiog_jmp
	jmp Tesiamas_ciklas


ne_jmp3:
	cmp bufsi[si], 11111111b
	jne ne_jmp4
	mov ax, 0
	call pavadinimo_isspausdinimas
	inc si
	mov word_bitas, 1
	call jmp_ff
	jmp Tesiamas_ciklas
	
ne_jmp4:
	cmp bufsi[si], 11010000b
	je tai_rol
	cmp bufsi[si], 11010001b
	je tai_rol
	cmp bufsi[si], 11010010b
	je tai_rol
	cmp bufsi[si], 11010011b
	je tai_rol
	jne ne_rol
	tai_rol:
	call rol_arba_sar
	jmp Tesiamas_ciklas
	
ne_rol:
	cmp bufsi[si], 00110000b
	je tai_xor1
	cmp bufsi[si], 00110001b
	je tai_xor1
	cmp bufsi[si], 00110010b
	je tai_xor1
	cmp bufsi[si], 00110011b
	je tai_xor1
	jne ne_xor
	tai_xor1:
	mov ax, 12
	call pavadinimo_isspausdinimas
	call xordw
	jmp Tesiamas_ciklas

ne_xor:
	cmp bufsi[si], 00110100b
	je tai_xor2
	cmp bufsi[si], 00110101b
	je tai_xor2
	jne ne_xor2
	tai_xor2:
	mov ax, 12
	call pavadinimo_isspausdinimas
	call xorakumuliatorius
	jmp Tesiamas_ciklas
	
ne_xor2:
	cmp bufsi[si], 10000000b
	je tai_xor3
	cmp bufsi[si], 10000001b
	je tai_xor3
	cmp bufsi[si], 10000010b
	je tai_xor3
	cmp bufsi[si], 10000011b
	je tai_xor3
	jne ne_xor3
	tai_xor3:
	mov ax, 12
	call pavadinimo_isspausdinimas
	call xorsw
	jmp Tesiamas_ciklas

ne_xor3:
	cmp bufsi[si], 10100100b
	jne ne_movsb
	mov ax, 24
	call pavadinimo_isspausdinimas
	inc si
	call nauja
	jmp Tesiamas_ciklas

ne_movsb:
	cmp bufsi[si], 10100101b
	jne ne_movsw
	mov ax, 30
	call pavadinimo_isspausdinimas
	
	inc si
	call nauja
	jmp Tesiamas_ciklas

ne_movsw:
	cmp bufsi[si], 10100110b
	jne ne_cmpsb
	mov ax, 36
	call pavadinimo_isspausdinimas
	inc si
	call nauja
	jmp Tesiamas_ciklas

ne_cmpsb:
	cmp bufsi[si], 10100111b
	jne ne_cmpsw
	mov ax,42
	call pavadinimo_isspausdinimas
	inc si
	call nauja
	jmp Tesiamas_ciklas

ne_cmpsw:
	cmp bufsi[si], 10101010b 
	jne ne_stosb
	mov ax, 48
	call pavadinimo_isspausdinimas
	inc si
	call nauja
	jmp Tesiamas_ciklas

ne_stosb:
	cmp bufsi[si], 10101011b
	jne ne_stosw
	mov ax, 54
	call pavadinimo_isspausdinimas
	inc si
	call nauja
	jmp Tesiamas_ciklas

ne_stosw:
	cmp bufsi[si], 10101100b
	jne ne_lodsb
	mov ax, 60
	call pavadinimo_isspausdinimas
	inc si
	call nauja
	jmp Tesiamas_ciklas

ne_lodsb:
	cmp bufsi[si], 10101101b
	jne ne_lodsw
	mov ax,66
	call pavadinimo_isspausdinimas
	inc si
	call nauja
	jmp Tesiamas_ciklas

ne_lodsw:
	cmp bufsi[si], 10101110b
	jne ne_scasb
	mov ax, 72
	call pavadinimo_isspausdinimas
	inc si
	call nauja
	jmp Tesiamas_ciklas

ne_scasb:
	cmp bufsi[si], 10101111b
	jne ne_scasw
	mov ax,78
	call pavadinimo_isspausdinimas
	inc si
	call nauja
	jmp Tesiamas_ciklas

ne_scasw:
	cmp bufsi[si], 11110010b
	jne ne_repne
	mov ax, 84
	call pavadinimo_isspausdinimas
	inc si
	call nauja
	jmp Tesiamas_ciklas
	
ne_repne:	
	cmp bufsi[si], 11110011b
	mov ax, 90
	call pavadinimo_isspausdinimas
	inc si
	call nauja

	
Tesiamas_ciklas:
	call nereikalinga_seka
	call tikrinimas
 
	jmp Pagrindinis_ciklas
	jmp exit
;------------------------------------
	spausdinti_ip proc near
		push dx
		mov dx, ip
		add dx, si
		mov bufbx[bx], 'C'
		inc bx
		mov bufbx[bx], 'S'
		inc bx
		mov bufbx[bx], ':'
		inc bx
		call spausdinti4
		mov bufbx[bx], ' '
		inc bx
		pop dx
		ret
	spausdinti_ip endp
;------------------------------------
sekos_spausdinimas proc near
		push cx
		push si
		push dx
		xor dx, dx
		
		mov cx, 4
	sekos_ciklas:
		mov dl, bufsi[si]
		inc si
		mov dh, bufsi[si]
		inc si
		call spausdinti4
	loop sekos_ciklas
		mov pabaigos_bx, bx
		mov bufbx[bx], ' '
		inc bx
		
		pop dx
		pop si
		pop cx
		ret
	sekos_spausdinimas endp
	
	nereikalinga_seka proc near
		push cx
		push si
		push bx
		
		sub si, senas_si
		add si, si
		mov cx, 16
		sub cx, si
		mov bx, pabaigos_bx
		dec bx
	trinimo_ciklas:
		mov bufbx[bx], ' '
		dec bx
	loop trinimo_ciklas
		
		pop bx
		pop si
		pop cx
		ret
	nereikalinga_seka endp
;------------------------------------
	arprefiksas proc near
		cmp bufsi[si], 26h
			je tai_ES
		cmp bufsi[si], 2Eh
			je tai_CS
		cmp bufsi[si], 36h
			je tai_SS
		cmp bufsi[si], 3Eh
			je tai_DS
		mov pref, 0
		ret
			tai_ES:
				mov pref, 26h
				inc si
				ret
			tai_CS:
				mov pref, 2Eh
				inc si
				ret
			tai_SS:
				mov pref, 36h
				inc si
				ret
			tai_DS:
				mov pref, 3Eh
				inc si
				ret

	arprefiksas endp
;------------------------------------
	xorsw proc near
		xor ax, ax
		mov al, bufsi[si]
		and al, 11b
		mov sw, al
		and al, 1b
		mov word_bitas, al
		inc si
		call nustatomi_mod_reg_rm
		call apdorojami_mod_reg_rm
		mov bufbx[bx], ','
		inc bx
		cmp sw, 01b
		je sw_01
		cmp sw, 10b
		je sw_10
		cmp sw, 11b
		je sw_11
		cmp sw, 00b
		je sw_00
	sw_01:
		push dx
		xor dx, dx
		mov dl, bufsi[si]
		inc si
		mov dh, bufsi[si]
		inc si		
		call spausdinti16
		pop dx
		mov bufbx[bx], 'h'
		inc bx
		call nauja
		ret
	sw_10:
		push dx
		xor dx,dx
		mov dl, bufsi[si]
		inc si
		call spausdinti8
		pop dx
		mov bufbx[bx], 'h'
		inc bx
		call nauja
		ret
	sw_11:
		cmp bufsi[si], 10000000b
		jae reik_plesti_0FF
		mov bufbx[bx], '0'
		inc bx
		mov bufbx[bx], '0'
		inc bx
		jmp baigesi_pletimas
	reik_plesti_0FF:
		mov bufbx[bx], '0'
		inc bx
		mov bufbx[bx], 'F'
		inc bx
		mov bufbx[bx], 'F'
		inc bx
	baigesi_pletimas:
		push dx
		xor dx,dx
		mov dl, bufsi[si]
		inc si
		call spausdinti8
		pop dx
		mov bufbx[bx], 'h'
		inc bx
		call nauja
		ret
	sw_00:
		push dx
		xor dx,dx
		mov dl, bufsi[si]
		inc si
		call spausdinti8
		pop dx
		mov bufbx[bx], 'h'
		inc bx
		call nauja
		ret
	xorsw endp
;------------------------------------
	xorakumuliatorius proc near
		xor ax,ax
		mov al, bufsi[si]
		and al, 1b
		inc si
		mov word_bitas, al
		cmp word_bitas, 0
		jne tai_ne_al
		mov bufbx[bx], 'a'
		inc bx
		mov bufbx[bx], 'l'
		inc bx
		mov bufbx[bx], ','
		inc bx
		push dx
		xor dx,dx
		mov dl, bufsi[si]
		inc si
		call spausdinti8
		pop dx
		mov bufbx[bx], 'h'
		inc bx
		call nauja
		ret
	tai_ne_al:
		mov bufbx[bx], 'a'
		inc bx
		mov bufbx[bx], 'x'
		inc bx
		mov bufbx[bx], ','
		inc bx
		push dx
		xor dx, dx
		mov dl, bufsi[si]
		inc si
		mov dh, bufsi[si]
		inc si
		call spausdinti16
		pop dx
		mov bufbx[bx], 'h'
		inc bx
		call nauja
		ret
	xorakumuliatorius endp
;------------------------------------
	xordw proc near
		xor ax, ax
		mov al, bufsi[si]
		and al, 10b
		shr al, 1
		mov d, al
		mov al, bufsi[si]
		and al, 1b
		mov word_bitas, al
		inc si
		call nustatomi_mod_reg_rm
		cmp d,0
		jne pirmiau_registras
		call apdorojami_mod_reg_rm
		mov bufbx[bx], ','
		inc bx
		mov al, reg_reiksme
		mov rm_reiksme, al
		call registras
		call nauja
		xor ax, ax
		ret
	pirmiau_registras:
		mov al, reg_reiksme
		xchg al, rm_reiksme
		mov reg_reiksme, al
		call registras
		mov bufbx[bx], ','
		inc bx
		mov al, reg_reiksme
		mov rm_reiksme, al
		call apdorojami_mod_reg_rm
		call nauja
		xor ax,ax 
		ret
	xordw endp
;------------------------------------
	rol_arba_sar proc near
		xor ax, ax
		mov al, bufsi[si]
		and al, 10b
		shr al, 1
		mov v, al
		mov al, bufsi[si]
		and al, 1b
		mov word_bitas, al
		inc si
		call nustatomi_mod_reg_rm
		cmp reg_reiksme, 000b
		jne tai_ne_rol
		mov ax, 6
		call pavadinimo_isspausdinimas
		jmp rol_arba_sar_isspausdintas
	tai_ne_rol:
		mov ax, 18
		call pavadinimo_isspausdinimas
	rol_arba_sar_isspausdintas:
		call apdorojami_mod_reg_rm
		mov bufbx[bx], ','
		inc bx
		cmp v, 0
		jne prie_v_cl
		mov bufbx[bx], '1'
		inc bx
		call nauja
		ret
	prie_v_cl:
		mov bufbx[bx], 'c'
		inc bx
		mov bufbx[bx], 'l'
		inc bx
		call nauja
		ret
	rol_arba_sar endp
;------------------------------------
	nustatomi_mod_reg_rm proc near
		xor ax, ax
		mov al, bufsi[si]
		and al, 11000000b
		shr al, 6
		mov mod_reiksme, al
		mov al, bufsi[si]
		and al, 00111000b
		shr al, 3
		mov reg_reiksme, al
		mov al, bufsi[si]
		and al, 00000111b
		mov rm_reiksme, al
		inc si
		xor ax,ax
		ret
	nustatomi_mod_reg_rm endp
;------------------------------------
	apdorojami_mod_reg_rm proc near
		cmp mod_reiksme, 11b
		jne tai_atmintis
		call registras
		ret
	tai_atmintis:
		call atmintis
		ret
	apdorojami_mod_reg_rm endp
;------------------------------------	
	jmp_ff proc near
		call nustatomi_mod_reg_rm
		mov al, bufsi[si]
		and al, 11000000b
		shr al, 6
		mov mod_reiksme, al
		mov al, bufsi[si]
		and al, 00111000b
		shr al, 3
		mov reg_reiksme, al
		mov al, bufsi[si]
		and al, 00000111b
		mov rm_reiksme, al
		inc si
		cmp reg_reiksme, 100b
		jne tai_reg_101b
		call apdorojami_mod_reg_rm
		call nauja
	tai_reg_101b:
		call tai_atmintis
		ret
	jmp_ff endp
;------------------------------------
	prefiksas proc near
		cmp pref, 0
		je pref_0
		cmp pref, 26h
		je pref_26
		cmp pref, 2Eh
		je pref_2e
		cmp pref, 36h
		je pref_36
		cmp pref, 3Eh
		je pref_3e
	pref_0:
		ret
	pref_26:
		mov bufbx[bx], 'E'
		inc bx
		mov bufbx[bx], 'S'
		inc bx
		mov bufbx[bx], ':'
		inc bx
		mov pref, 0
		ret
	pref_2e:
		mov bufbx[bx], 'C'
		inc bx
		mov bufbx[bx], 'S'
		inc bx
		mov bufbx[bx], ':'
		inc bx
		mov pref, 0
		ret
	pref_36:
		mov bufbx[bx], 'S'
		inc bx
		mov bufbx[bx], 'S'
		inc bx
		mov bufbx[bx], ':'
		inc bx
		mov pref, 0
		ret
	pref_3e:
		mov bufbx[bx], 'D'
		inc bx
		mov bufbx[bx], 'S'
		inc bx
		mov bufbx[bx], ':'
		inc bx
		mov pref, 0
		ret
	prefiksas endp
;------------------------------------
	atmintis proc near
		call prefiksas
		xor ax,ax 
		mov al, word_bitas
		push ax
		mov word_bitas, 1
		mov bufbx[bx], '['
		inc bx
		cmp rm_reiksme, 000b
		jne rm_ne_000b
		mov rm_reiksme, 011b
		call registras
		call tarpas
		mov rm_reiksme, 110b
		call registras
		mov rm_reiksme, 000b		
	rm_ne_000b:
		cmp rm_reiksme, 001b
		jne rm_ne_001b
		mov rm_reiksme, 011b
		call registras
		call tarpas
		mov rm_reiksme, 111b
		call registras
		mov rm_reiksme, 001b		
	rm_ne_001b:
		cmp rm_reiksme, 010b
		jne rm_ne_010b
		mov rm_reiksme, 101b
		call registras
		call tarpas
		mov rm_reiksme, 110b
		call registras
		mov rm_reiksme, 010b		
	rm_ne_010b:
		cmp rm_reiksme, 011b
		jne rm_ne_011b
		mov rm_reiksme, 101b
		call registras
		call tarpas
		mov rm_reiksme, 111b
		call registras
		mov rm_reiksme, 011b		
	rm_ne_011b:
		cmp rm_reiksme, 100b
		jne rm_ne_100b
		mov rm_reiksme, 110b
		call registras
		mov rm_reiksme, 100b		
	rm_ne_100b:
		cmp rm_reiksme, 101b
		jne rm_ne_101b
		mov rm_reiksme, 111b
		call registras
		mov rm_reiksme, 101b		
	rm_ne_101b:
		cmp rm_reiksme, 110b
		jne rm_ne_110b
		cmp mod_reiksme, 00b
		je tai_tik_adresas
		mov rm_reiksme, 101b
		call registras
		mov rm_reiksme, 110b
		jmp mod_ne_00
		tai_tik_adresas:
		push dx
		xor dx, dx
		mov dl, bufsi[si]
		inc si
		mov dh, bufsi[si]
		inc si
		
		call spausdinti16
		pop dx
		mov bufbx[bx], 'h'
		inc bx
		mov bufbx[bx], ']'
		inc bx
		pop ax
		mov word_bitas, al
		ret
	rm_ne_110b:

		mov rm_reiksme, 011b
		call registras
		mov rm_reiksme, 111b		
		cmp mod_reiksme, 00b
		jne mod_ne_00
		pop ax
		mov word_bitas, al
		ret
	mod_ne_00:
		cmp mod_reiksme, 01b
		jne mod_ne_01
		call tarpas
		push dx
		xor dx, dx
		mov dl, bufsi[si]
		inc si
		push dx
		xor dx,dx
		mov dl, bufsi[si]
		inc si
		call spausdinti8
		pop dx
		mov bufbx[bx], 'h'
		inc bx
		pop dx
		mov bufbx[bx], ']'
		inc bx
		pop ax
		mov word_bitas, al
		ret
	mod_ne_01:
		call tarpas
		push dx
		mov dl, bufsi[si]
		inc si
		mov dh, bufsi[si]
		inc si
		push dx
		xor dx, dx
		mov dl, bufsi[si]
		inc si
		mov dh, bufsi[si]
		inc si
		call spausdinti16
		pop dx
		mov bufbx[bx], 'h'
		inc bx
		pop dx
		mov bufbx[bx], ']'
		inc bx
		pop ax
		mov word_bitas, al
		ret
	atmintis endp
;------------------------------------
	tarpas proc near
		mov bufbx[bx], ' '
		inc bx
		mov bufbx[bx], '+'
		inc bx
		mov bufbx[bx], ' '
		inc bx
		ret
	tarpas endp
;------------------------------------
	registras proc near
		;4*ax + 2*w
		push di
		xor ax, ax
		mov al, rm_reiksme
		mov di, ax
		add di, di
		add di, di
		cmp word_bitas, 1
		jne nereik_pridet
		add di, 2
		nereik_pridet:
		mov al, regpavadinimai[di]
		mov bufbx[bx], al
		inc di
		inc bx
		mov al, regpavadinimai[di]
		mov bufbx[bx], al
		inc bx
		pop di
		xor ax,ax
		ret
	registras endp
;------------------------------------
	isorinis_jmp proc near
		push dx
		push cx
		mov cl, bufsi[si]
		inc si
		mov ch, bufsi[si]
		inc si
		mov dl, bufsi[si]
		inc si
		mov dh, bufsi[si]
		inc si
		call spausdinti4
		mov bufbx[bx], ':'
		inc bx
		mov bufbx[bx], '['
		inc bx
		mov dx, cx
		call spausdinti16
		mov bufbx[bx], 'h'
		inc bx
		mov bufbx[bx], ']'
		inc bx
		call nauja		
		pop cx
		pop dx
		xor ax, ax
		ret
	isorinis_jmp endp
;------------------------------------
	pavadinimo_isspausdinimas proc near
		push cx
		push si
		mov cx, 6
		mov si, ax
		isspausdinimo_ciklas:
		mov al, pavadinimai[si]
		inc si
		mov bufbx[bx], al
		inc bx
		loop isspausdinimo_ciklas
		pop si
		pop cx
		xor ax, ax
		ret
	pavadinimo_isspausdinimas endp
;------------------------------------
	tiesiog_jmp proc near
		push dx
		mov dx, ip
		xor ax, ax
		mov al, bufsi[si]
		inc si
		add dx, ax
		add dx, si
		mov bufbx[bx], '['
		call spausdinti16
		mov bufbx[bx], 'h'
		inc bx
		mov bufbx[bx], ']'
		call nauja
		pop dx
		xor ax, ax
		ret
		ret
	tiesiog_jmp endp
	
	baitinis_jmp proc near
		push dx
		mov dx, ip
		mov al, bufsi[si]
		inc si
		mov ah, bufsi[si]
		inc si
		add dx, ax
		add dx, si
		mov bufbx[bx], '['
		call spausdinti16
		mov bufbx[bx], 'h'
		inc bx
		mov bufbx[bx], ']'
		call nauja
		pop dx
		xor ax, ax
		ret
	baitinis_jmp endp
;----------------------------------------	
	spausdinti16 proc near
		mov ax, dx
		and ax, 0F000h
		shr ax, 12
		cmp al, 9
		jna nereik_nulio
		mov bufbx[bx], '0'
		inc bx
		nereik_nulio:
		call skaicius
		mov ax, dx
		and ax, 0F00h
		shr ax, 8
		call skaicius
		mov ax, dx
		and ax, 00F0h
		shr ax, 4
		call skaicius
		mov ax, dx
		and ax, 000Fh
		call skaicius
		ret
	spausdinti16 endp
;----------------------------------
	spausdinti8 proc near
		mov al, dl
		and al, 0F0h
		shr ax, 4
		cmp al, 9
		jna nereik_nulio_8
		mov bufbx[bx], '0'
		inc bx
		nereik_nulio_8:
		call skaicius
		mov al, dl
		and al, 0Fh
		call skaicius
		ret
	spausdinti8 endp
;----------------------------------	
	spausdinti4 proc near
		mov ax, dx
		and ax, 0F000h
		shr ax, 12
		call skaicius
		mov ax, dx
		and ax, 0F00h
		shr ax, 8
		call skaicius
		mov ax, dx
		and ax, 00F0h
		shr ax, 4
		call skaicius
		mov ax, dx
		and ax, 000Fh
		call skaicius
		ret
	spausdinti4 endp
;--------------------------------------------	
	skaicius proc near
		cmp al, 9
		ja tai_raide
		add al, 30h
		mov bufbx[bx], al
		inc bx
		ret
	tai_raide:
		add al, 55
		mov bufbx[bx], al
		inc bx
		ret
	skaicius endp
;---------------------------------------------	
	nauja proc near
	
		mov bufbx[bx], 13
		inc bx
		mov bufbx[bx], 10
		inc bx
		ret
	
	nauja endp
;---------------------------------------------	
	
	
	
	
	
	
	
	
	tikrinimas proc near
	;cmp si, 250
	;jl nereikia_dar_papildomai_nuskaityti
	;call nuskaitymas
  ;nereikia_dar_papildomai_nuskaityti:
	cmp si, cx
	jl programa_dar_nesibaige
	jmp exit
  programa_dar_nesibaige:
	cmp bx, 230
	jl dar_nereikia_spausdinti
	call spausdinti
  dar_nereikia_spausdinti:
	ret
  tikrinimas endp
;------------------------------------------
	spausdinti proc near
		mov cx, bx
		mov ax, 4000h
		mov bx, filehandleout
		mov dx, offset bufbx
		int 21h
		xor bx, bx
		ret
	spausdinti endp
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