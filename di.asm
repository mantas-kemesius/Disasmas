;***************************************************************
; Programa atidaranti failą duom.txt, pakeičianti mažąsias raides didžiosiomis ir rezultatą įrašanti į failą rez.txt
;***************************************************************
.model small
skBufDydis	EQU 10			;konstanta skBufDydis (lygi 20) - skaitymo buferio dydis
raBufDydis	EQU 3000		;konstanta raBufDydis (lygi 20) - rašymo buferio dydis
.stack 100h
.data
	duom	db ,0		;duomenų failo pavadinimas, pasibaigiantis nuliniu simboliu (C sintakse - '\0')
	rez	db ,0		;rezultatų failo pavadinimas, pasibaigiantis nuliniu simboliu
	skBuf	db skBufDydis dup (?)	;skaitymo buferis
	raBuf	db raBufDydis dup (?)	;rašymo buferis
	dFail	dw ?			;vieta, skirta saugoti duomenų failo deskriptoriaus numerį ("handle")
	rFail	dw ?			;vieta, skirta saugoti rezultato failo deskriptoriaus numerį
	kiek dw 0
temp dw 0
p dw 0
yraTaskas dw 0
a dw 0
sek dw 0
skaicius dw 0
poslinkis dw 100h
bituKiekis dw 0
loopCounter db 0
tarpuKintamasis db 0

min dw 0
max dw 0
kiekCX db 0
bxSave	dw 0082h
help    db "III atsiskaitomasis darbas, Disasembleris.",10,13, "Sia uzduoti atliko Mantas Kemesius VU MIF PS II k. 6gr.$"
neveikia    db "Failas nebuvo atidarytas$"


;------ Tarpiniai pranesimai

    enteris db 13,10,'$'
    neatp_pradzia db 'db $'
    neatp_pabaiga db ' ;Neatpazinau komandos$'
    k_ db ', $'
    sonk_ db '[$'
    sond_ db ']$'
    pliusas_ db '+$'
    temp_for_al db ?
    byte_for_sreg db ?


;---------------MASININIS KODAS

    Mas_kodas db 26h, 88h, 06h, 0CAh, 0FFh
              db 36h,0FFh, 0E8h,0C6h, 06h
              db 26h,74h, 5Ch, 5Fh

;----------------DARBINIAI KINTAMIEJI

    reg_part db ?
    rm_part db ?
    mod_part db ?
    d_part db ?
    w_part db ?
    sreg_part db ?

    prefix_nr db ? ; IF = 0 - NETURI   1 - ES   2 - CS  3 - SS  4 - DS

    bojb_baitas db ?
    bovb_baitas db ?
	BAITAS1 DB ?
	BAITAS2 DB ?

    firstByte db ? ;pasidedam pirma komandos baita
    secondByte db ? ;pasidedam pirma komandos baita
    thirdByte db ? ;pasidedam pirma komandos baita
    Byte4 db ? ;pasidedam pirma komandos baita

    format_nr db ? ;dabartines komandos formato numeris

;***************************************************************************************************************************************************************


.code
 pradzia:
		MOV    ax, @data
		MOV    ds, ax
		MOV bp, 0

		MOV ch, 0
		MOV cl, es:[0080h]  ;programos paleidimo parametru simboliu skaicius yra rasome 80h baite
		CMP cx, 0           ; jei nera paleidimo parametru, programa veikia normaliai
		JNE helpJMP
		JMP klaidaAtidarantSkaitymui

	helpJMP:
		MOV bx, 0081h

	ieskokHelp:
		CMP es:[bx], '?/'
		JE YraHELP
		INC bx
	LOOP ieskokHelp
		JMP neraHelp


	YraHELP:
		MOV ah, 9
		MOV dx, offset help
		INT 21h

		MOV	ah, 4Ch
		MOV	al, 0
		INT	21h

	neraHelp:
		MOV cl, es:[80h] ;kiek skaiciu parametras
		mov ch, 0
		MOV kiekCX, cl

	failoParametras:
		MOV si, offset duom
		MOV BX, bxSave
		mov ch, 0
		MOV cl, kiekCX
		CMP cx, 0
		JNE ieskok
	failoParametras2:
		MOV si, offset rez
		MOV BX, bxSave
		mov ch, 0
		MOV cl, kiekCX
		CMP cx, 0
		JNE ieskok

	ieskok:
		MOV dl, Byte ptr ES:[BX]
		CMP dl, 20h
		JE yraFailasK
		CMP dl, 13
		JE yraFailopav
		INC bx
		MOV byte ptr [si], dl
		INC si
		cmp dl, '.'
		JE yraTaskasZ
	LOOP ieskok

	yraTaskasZ:
		mov yraTaskas, 1
		jmp ieskok

	yraFailasK:
	    cmp yraTaskas, 1
	       JE yraPilnasFailas
	    jmp yraFailas

	yraFailopav:
		MOV		CX, 0
		MOV		kiekCX, Cl
		cmp yraTaskas, 1
		JE yraPilnasFailas

	yraFailas:
		mov dl, '.'
		mov byte ptr [si],dl
		INC si
		mov dl, 't'
		mov byte ptr [si],dl
		mov dl, 'x'
		INC si
		mov byte ptr [si],dl
		mov dl, 't'
		INC si
		mov byte ptr [si],dl
		inc si
		MOV byte ptr [si], 0
		inc si
		INC bx
		MOV bxSave, bx
		MOV kiekCX, cl

		inc skaicius
		cmp skaicius, 2
		je rez_atidarymas

		jmp duomenys

	yraPilnasFailas:
	  mov yraTaskas, 0
		INC bx
		MOV bxSave, bx
		MOV kiekCX, cl
		mov yraTaskas, 0
		inc skaicius
		cmp skaicius, 2
		je rez_atidarymas

duomenys:
MOV dx, offset duom
	MOV	ah, 3Dh				;21h pertraukimo failo atidarymo funkcijos numeris
	MOV	al, 00				;00 - failas atidaromas skaitymui
	INT	21h				;failas atidaromas skaitymui
	JC	klaidaAtidarantSkaitymui	;jei atidarant failą skaitymui įvyksta klaida, nustatomas carry flag
	MOV	dFail, ax			;atmintyje išsisaugom duomenų failo deskriptoriaus numerį
	jmp failoParametras2

klaidaAtidarantSkaitymui:
	MOV ah, 9
	MOV dx, offset neveikia
	INT 21h
	mov ah, 4Ch
	int 21h

;*****************************************************
;Rezultato failo sukūrimas ir atidarymas rašymui
;*****************************************************
	rez_atidarymas:
	MOV	ah, 3Ch				;21h pertraukimo failo sukūrimo funkcijos numeris
	MOV	cx, 0				;kuriamo failo atributai
	MOV	dx, offset rez			;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
	INT	21h				;sukuriamas failas; jei failas jau egzistuoja, visa jo informacija ištrinama
	JC	klaidaAtidarantSkaitymui		;jei kuriant failą skaitymui įvyksta klaida, nustatomas carry flag
	MOV	rFail, ax			;atmintyje išsisaugom rezultato failo deskriptoriaus numerį

;*****************************************************
;Duomenų nuskaitymas iš failo
;*****************************************************
  skaityk:
	MOV	bx, dFail			;į bx įrašom duomenų failo deskriptoriaus numerį
	CALL	SkaitykBuf			;iškviečiame skaitymo iš failo procedūrą
	CMP	ax, 0				;ax įrašoma, kiek baitų buvo nuskaityta, jeigu 0 - pasiekta failo pabaiga
	je helpJmpToExit
	jmp teskdarbatoliau

	helpJmpToExit:
		jmp exit
;*****************************************************
;Darbas su nuskaityta informacija
;*****************************************************
	teskdarbatoliau:
	xor bx,bx
	MOV	bx, ax
	MOV	cx, ax
	mov loopCounter, 0
	MOV	si, offset skBuf
	;mov si, offset Mas_kodas
	MOV	di, offset raBuf


MainLoop:
	mov dx, poslinkis
    push dx
    mov dl, dh
    call idekSkaiciu
    pop dx
    mov dh, 0h
    call idekSkaiciu
    call spausdink_dvi;dvitaski
	call trysTarpai
    call getFirstByte
	call check_meybe_set_prefix
	cmp byte ptr[prefix_nr], 0
		jne MainLoop_paimk_dar_viena
		jmp MainLoop_next

	MainLoop_paimk_dar_viena:
		MOV	dl, al
		call idekSkaiciu
		call getFirstByte
	MainLoop_next:
	MOV	dl, al
	call idekSkaiciu

    mov byte ptr[firstByte], al

    call getInfo
    call print_kodo_eilute

	call spausdink_enter
Loop MainLoop

MOV	bx, rFail			;į bx įrašom rezultato failo deskriptoriaus numerį
CALL	RasykBuf			;iškviečiame rašymo į failą procedūrą
jmp skaityk


temp_to_exit:
jmp exit

	;------------------------------------------------------------------------------------------------------

getFirstByte:
	getFirstByte_pradzia:
    mov al,[si]
    inc si
	inc poslinkis
    inc loopCounter
	add tarpuKintamasis, 2

    cmp loopCounter, bl
    jg getFirstByte_temp_jmp_to_end_program

    jmp getFirstByte_end

    getFirstByte_temp_jmp_to_end_program:
		MOV	bx, rFail			;į bx įrašom rezultato failo deskriptoriaus numerį
		CALL	RasykBuf			;iškviečiame rašymo į failą procedūrą
		MOV	bx, dFail			;į bx įrašom duomenų failo deskriptoriaus numerį
		CALL	SkaitykBuf			;iškviečiame skaitymo iš failo procedūrą
		CMP	ax, 0				;ax įrašoma, kiek baitų buvo nuskaityta, jeigu 0 - pasiekta failo pabaiga
		je helpJmpToExit2
		xor bx,bx
		MOV	bx, ax
		MOV	cx, ax
		mov loopCounter, 0
		MOV	si, offset skBuf
		MOV	di, offset raBuf
		jmp getFirstByte_pradzia
		helpJmpToExit2:
			jmp exit

    getFirstByte_end:
    RET

;------------------------------------------------------------------------------------------------------

getInfo:

    call getD_S
    call getW

    call gauk_formato_nr    ;*********************  PIRMAS ********************

    cmp byte ptr[format_nr], 1 ;jei formato numeris 1   ;*********************  TRECIAS ********************
        je domisi_pirmu_temp
    cmp byte ptr[format_nr], 2 ;jei formato numeris 2
        je domisi_antru_temp
    cmp byte ptr[format_nr], 3 ;jei formatas (xxxx xxdw mod reg r/m [poslinkis])
        je domisi_treciu_temp
    cmp byte ptr[format_nr], 4 ;jei formatas (xxxx xxxw mod xxxx r/m [poslinkis] bojb [bovb]) cia su SW
        je domisi_treciu_temp
    cmp byte ptr[format_nr], 5 ;jei formatas (xxxx xxxw mod xxxx r/m [poslinkis] )
        je domisi_treciu_temp
    cmp byte ptr[format_nr], 6 ;jei formatas (xxxx xxxw mod xxxx r/m [poslinkis] )
        je domisi_pirmu_temp
	cmp byte ptr[format_nr], 7 ;jei formatas (xxxx xxxw mod xxxx r/m [poslinkis] )
        je domisi_treciu_temp
	cmp byte ptr[format_nr], 8 ;jei formatas (xxxx xxxw ajb avb )
        je domisi_nuliniu
	cmp byte ptr[format_nr], 9 ;jei formatas (xxxx wreg bojb bovb )
		je domisi_pirmu_temp
	cmp byte ptr[format_nr], 10 ;jei formatas (xxxx xxxw bojb [bovb] )
		je domisi_nuliniu
    cmp byte ptr[format_nr], 11 ;jei formatas (xxxx xxsw mod xxx r/m [poslinkis] bovb [bojb] )
		je domisi_treciu_temp
	cmp byte ptr[format_nr], 12 ;salyginiai jmp ir loop
		je domisi_nuliniu
	cmp byte ptr[format_nr], 13 ;jmp call ret su bojb ir bovb
		je domisi_nuliniu
	cmp byte ptr[format_nr], 14 ;jmp call su sjb ir svb ajb avb
		je domisi_nuliniu
	cmp byte ptr[format_nr], 15 ;ret ir iret
		je domisi_nuliniu

    jmp domisi_nuliniu ;kai netiko ne vienas atvejis


	domisi_pirmu_temp:
		jmp domisi_pirmu
	domisi_antru_temp:
		jmp domisi_antru
    domisi_treciu_temp:
		jmp domisi_treciu

	domisi_nuliniu:
RET

;------------------------------------------------------------------------------------------------------
;Mazdaug atrenkame i kuria puse ziureti

gauk_formato_nr:;******************* ANTRAS *********************
;------------------------------------------------------------------------- Formatas (xxxx xreg)
    gal_pirmas112: ;kai AND
       cmp byte ptr[firstByte], 20h
           jge gal_pirmas112_interval
           jmp gal_pirmas112_interval_end2
           gal_pirmas112_interval:
               cmp byte ptr[firstByte], 23h
                   jle taip_trecias_temp112
				   jmp gal_pirmas112_interval_end2
			taip_trecias_temp112:
				jmp taip_trecias
	
	gal_pirmas112_interval_end2:
    gal_pirmas3: ;kai PUSH
       cmp byte ptr[firstByte], 50h
           jge gal_pirmas3_interval
           jmp gal_pirmas3_interval_end
           gal_pirmas3_interval:
               cmp byte ptr[firstByte], 57h
                   jle taip_pirmas_temp
    gal_pirmas3_interval_end:

    gal_pirmas2: ;kai DEC
       cmp byte ptr[firstByte], 48h
           jge gal_pirmas2_interval
           jmp gal_pirmas2_interval_end
           gal_pirmas2_interval:
               cmp byte ptr[firstByte], 4Fh
                   jle taip_pirmas_temp
    gal_pirmas2_interval_end:

    cmp byte ptr[firstByte], 40h ;INC IR POP, toks pats formatas (xxxx xreg)
        jb gal_antras
    cmp byte ptr[firstByte], 5Fh
        ja gal_antras

    ;patekom i intervala 40h-5Fh
    ;reiskia pirmas formatas
    mov byte ptr[format_nr], 1
    RET
	taip_pirmas_temp:
		jmp taip_pirmas
;----------------------------------------------------------------------------------------
    gal_antras:
        cmp byte ptr[firstByte], 0CDh ;ar antras formatas, jo pirmas baitas CD - (INT)
        je taip_antras_temp
		jmp gal_trecias

		taip_antras_temp:
		jmp taip_antras

;---------------------------------------------- FORMATAS (xxxx xxdw mod reg r/m)
    gal_trecias: ;kai MOV
        cmp byte ptr[firstByte], 88h
            jge gal_trecias_interval
            jmp gal_trecias_interval_end
            gal_trecias_interval:
                cmp byte ptr[firstByte], 8Bh
                    jle taip_trecias_temp
					jmp gal_trecias_interval_end
					taip_trecias_temp:
						jmp taip_trecias
    gal_trecias_interval_end:
    gal_trecias2: ;kai ADD
        cmp byte ptr[firstByte], 00h
            jge gal_trecias2_interval
            jmp gal_trecias2_interval_end
            gal_trecias2_interval:
                cmp byte ptr[firstByte], 03h
                    jle taip_trecias2_temp
					jmp gal_trecias2_interval_end

					taip_trecias2_temp:
						jmp taip_trecias
    gal_trecias2_interval_end:

    gal_trecias3: ;kai SUB
        cmp byte ptr[firstByte], 28h
            jge gal_trecias3_interval
            jmp gal_trecias3_interval_end
            gal_trecias3_interval:
                cmp byte ptr[firstByte], 2Bh
                    jle taip_trecias3_temp
					jmp gal_trecias3_interval_end

					taip_trecias3_temp:
						jmp taip_trecias

    gal_trecias3_interval_end:
    gal_trecias4: ;kai CMP
        cmp byte ptr[firstByte], 38h
            jge gal_trecias4_interval
            jmp gal_trecias4_interval_end
            gal_trecias4_interval:
                cmp byte ptr[firstByte], 3Bh
                    jle taip_trecias4_temp
					jmp gal_trecias4_interval_end

					taip_trecias4_temp:
						jmp taip_trecias
    gal_trecias4_interval_end:
;-----------------------------------------------------------------

   ;--- VISIKITI CMP 3 formato.


    gal_ketvirtas: ;kai (xxxx xxxw mod xxx r/m [poslinkis] bojb [bovb])
        cmp byte ptr[firstByte], 0C6h
            jge gal_ketvirtas_interval
            jmp gal_penktas1
            gal_ketvirtas_interval:
                cmp byte ptr[firstByte], 0C7h
                    jle taip_ketvirtas_temp
					jmp gal_penktas1

					taip_ketvirtas_temp:
						jmp taip_ketvirtas

    gal_penktas1: ;kai (xxxx xxxw mod xxx r/m [poslinkis])
        cmp byte ptr[firstByte], 8Fh        ;POP
            je taip_penktas_temp
			jmp gal_penktas2
			taip_penktas_temp:
					jmp taip_penktas
    gal_penktas2: ;kai (xxxx xxxw mod xxx r/m [poslinkis])
        cmp byte ptr[firstByte], 0FEh        ;PUSH, INC arba DEC, CALL JMP atskiraime pagal REG
            jge gal_penktas2_interval
            jmp gal_penktas
            gal_penktas2_interval:
                cmp byte ptr[firstByte], 0FFh
                    jle taip_penktas_temp1
					jmp gal_penktas
				taip_penktas_temp1:
					jmp taip_penktas

    gal_penktas: ;kai (xxxx xxxw mod xxx r/m [poslinkis])
        cmp byte ptr[firstByte], 0F6h        ;GALI BUTI MUL GALI IR DIV
            jge gal_penktas_interval
            jmp gal_sestas
            gal_penktas_interval:
                cmp byte ptr[firstByte], 0F7h
                    jle taip_penktas_temp3
					jmp gal_sestas

					taip_penktas_temp3:
						jmp taip_penktas

    gal_sestas: ;kai (xxxs rxxx)
        cmp byte ptr[firstByte], 06h        ;GALI BUTI PUSH ARBA POP
            jge gal_sestas_interval
            jmp gal_septintas
            gal_sestas_interval:
                cmp byte ptr[firstByte], 1Fh
                    jle taip_sestas_temp0
					jmp gal_septintas

					taip_sestas_temp0:
						jmp taip_sestas


    gal_septintas:
	cmp byte ptr[firstByte], 8Ch        ;MOV
            jge gal_septintas_interval
            jmp gal_astuntas
            gal_septintas_interval:
                cmp byte ptr[firstByte], 8Eh
                    jle taip_septintas_temp
					jmp gal_astuntas

					taip_septintas_temp:
						jmp taip_septintas


	gal_astuntas:
	cmp byte ptr[firstByte], 0A0h        ;MOV
            jge gal_astuntas_interval
            jmp gal_devintas
            gal_astuntas_interval:
                cmp byte ptr[firstByte], 0A3h
                    jle taip_astuntas_temp
					jmp gal_devintas

					taip_astuntas_temp:
						jmp taip_astuntas
	gal_devintas:
	cmp byte ptr[firstByte], 0B0h        ;MOV
		jge gal_devintas_interval
            jmp gal_desimtas
            gal_devintas_interval:
                cmp byte ptr[firstByte], 0BFh
                    jle taip_devintas_temp
					jmp gal_desimtas

					taip_devintas_temp:
						jmp taip_devintas

	gal_desimtas:
	cmp byte ptr[firstByte], 04h        ;ADD
		jge gal_desimtas_interval
            jmp gal_desimtas1
            gal_desimtas_interval:
                cmp byte ptr[firstByte], 05h
                    jle taip_desimtas_temp
					jmp gal_desimtas1

					taip_desimtas_temp:
						jmp taip_desimtas

	gal_desimtas1:
	cmp byte ptr[firstByte], 2Ch        ;SUB
		jge gal_desimtas1_interval
            jmp gal_desimtas2
            gal_desimtas1_interval:
                cmp byte ptr[firstByte], 2Dh
                    jle taip_desimtas_temp1
					jmp gal_desimtas2

					taip_desimtas_temp1:
						jmp taip_desimtas

	gal_desimtas2:
	cmp byte ptr[firstByte], 3Ch        ;CMP
		jge gal_desimtas2_interval
            jmp gal_vienuoliktas
            gal_desimtas2_interval:
                cmp byte ptr[firstByte], 3Dh
                    jle taip_desimtas_temp2
					jmp gal_vienuoliktas

					taip_desimtas_temp2:
						jmp taip_desimtas

	gal_vienuoliktas:
	cmp byte ptr[firstByte], 80h        ;SU S raidem
		jge gal_vienuoliktas_interval
            jmp gal_dvyliktas
            gal_vienuoliktas_interval:
                cmp byte ptr[firstByte], 83h
                    jle taip_vienuoliktas_temp
					jmp gal_dvyliktas

					taip_vienuoliktas_temp:
						jmp taip_vienuoliktas

;------------------------------------------------------- SALYGINIAI JUMPAI ------------------------------------------------------------------------------
	gal_dvyliktas:
		cmp byte ptr[firstByte], 77h ;JA
			je taip_dvyliktas_temp1
			jmp next_dvyliktas1
			taip_dvyliktas_temp1:
				jmp taip_dvyliktas
		next_dvyliktas1:
		cmp byte ptr[firstByte], 73h ;JAE
			je taip_dvyliktas_temp2
			jmp next_dvyliktas2
			taip_dvyliktas_temp2:
				jmp taip_dvyliktas
		next_dvyliktas2:
		cmp byte ptr[firstByte], 72h ;JB
			je taip_dvyliktas_temp3
			jmp next_dvyliktas3
			taip_dvyliktas_temp3:
				jmp taip_dvyliktas
		next_dvyliktas3:
		cmp byte ptr[firstByte], 76h ;JBE
			je taip_dvyliktas_temp4
			jmp next_dvyliktas4
			taip_dvyliktas_temp4:
				jmp taip_dvyliktas
		next_dvyliktas4:
		cmp byte ptr[firstByte], 74h ;JE
			je taip_dvyliktas_temp5
			jmp next_dvyliktas5
			taip_dvyliktas_temp5:
				jmp taip_dvyliktas
		next_dvyliktas5:
		cmp byte ptr[firstByte], 75h ;JNE
			je taip_dvyliktas_temp6
			jmp next_dvyliktas6
			taip_dvyliktas_temp6:
				jmp taip_dvyliktas
		next_dvyliktas6:
		cmp byte ptr[firstByte], 7Fh ;JG
			je taip_dvyliktas_temp7
			jmp next_dvyliktas7
			taip_dvyliktas_temp7:
				jmp taip_dvyliktas
		next_dvyliktas7:
		cmp byte ptr[firstByte], 7Dh ;JGE
			je taip_dvyliktas_temp8
			jmp next_dvyliktas8
			taip_dvyliktas_temp8:
				jmp taip_dvyliktas
		next_dvyliktas8:
		cmp byte ptr[firstByte], 7Ch ;JL
			je taip_dvyliktas_temp9
			jmp next_dvyliktas9
			taip_dvyliktas_temp9:
				jmp taip_dvyliktas
		next_dvyliktas9:
		cmp byte ptr[firstByte], 7Eh ;JLE
			je taip_dvyliktas_temp10
			jmp next_dvyliktas10
			taip_dvyliktas_temp10:
				jmp taip_dvyliktas
		next_dvyliktas10:
		cmp byte ptr[firstByte], 78h ;JS
			je taip_dvyliktas_temp11
			jmp next_dvyliktas11
			taip_dvyliktas_temp11:
				jmp taip_dvyliktas
		next_dvyliktas11:
		cmp byte ptr[firstByte], 79h ;JNS
			je taip_dvyliktas_temp12
			jmp next_dvyliktas12
			taip_dvyliktas_temp12:
				jmp taip_dvyliktas
		next_dvyliktas12:
		cmp byte ptr[firstByte], 70h ; JO
			je taip_dvyliktas_temp13
			jmp next_dvyliktas13
			taip_dvyliktas_temp13:
				jmp taip_dvyliktas
		next_dvyliktas13:
		cmp byte ptr[firstByte], 71h ;JNO
			je taip_dvyliktas_temp14
			jmp next_dvyliktas14
			taip_dvyliktas_temp14:
				jmp taip_dvyliktas
		next_dvyliktas14:
		cmp byte ptr[firstByte], 7Ah ;JP
			je taip_dvyliktas_temp15
			jmp next_dvyliktas15
			taip_dvyliktas_temp15:
				jmp taip_dvyliktas
		next_dvyliktas15:
		cmp byte ptr[firstByte], 7Bh ;JNP
			je taip_dvyliktas_temp16
			jmp next_dvyliktas16
			taip_dvyliktas_temp16:
				jmp taip_dvyliktas
		next_dvyliktas16:
		cmp byte ptr[firstByte], 0E3h ;JCXZ
			je taip_dvyliktas_temp17
			jmp next_dvyliktas17
			taip_dvyliktas_temp17:
				jmp taip_dvyliktas
		next_dvyliktas17:
		cmp byte ptr[firstByte], 0E2h ;LOOP
			je taip_dvyliktas_temp18
			jmp next_dvyliktas18
			taip_dvyliktas_temp18:
				jmp taip_dvyliktas
		next_dvyliktas18:
		cmp byte ptr[firstByte], 0EBh ;LOOP
			je taip_dvyliktas_temp19
			jmp next_dvyliktas19
			taip_dvyliktas_temp19:
				jmp taip_dvyliktas
		next_dvyliktas19:

		cmp byte ptr[firstByte], 0E9h ;JMP
			je taip_tryliktas
		cmp byte ptr[firstByte], 0C2h ;ret
			je taip_tryliktas
		cmp byte ptr[firstByte], 0CAh ;ret
			je taip_tryliktas
		cmp byte ptr[firstByte], 0E8h ;call
			je taip_tryliktas

		cmp byte ptr[firstByte], 0EAh ;JMP
			je taip_keturioliktas
		cmp byte ptr[firstByte], 9Ah ;call
			je taip_keturioliktas

		cmp byte ptr[firstByte], 0C3h ;RET
			je taip_penkioliktas
		cmp byte ptr[firstByte], 0CFh ;IRET
			je taip_penkioliktas

    gauk_formato_nr_next:

    jmp neatpazintas

    taip_dvyliktas:
        mov byte ptr[format_nr], 12
        RET
    taip_ketvirtas:
        mov byte ptr[format_nr], 4
        RET
    taip_trecias:
        mov byte ptr[format_nr], 3
        RET

    taip_antras:
        mov byte ptr[format_nr], 2
        RET
    taip_pirmas:
        mov byte ptr[format_nr], 1
        RET
    taip_penktas:
        mov byte ptr[format_nr], 5
        RET
    taip_sestas:
        mov byte ptr[format_nr], 6
        RET
	taip_septintas:
        mov byte ptr[format_nr], 7
        RET
	taip_astuntas:
        mov byte ptr[format_nr], 8
        RET
    taip_devintas:
        mov byte ptr[format_nr], 9
        RET
	taip_desimtas:
        mov byte ptr[format_nr], 10
        RET
	taip_vienuoliktas:
        mov byte ptr[format_nr], 11
        RET
	taip_tryliktas:
        mov byte ptr[format_nr], 13
        RET
	taip_keturioliktas:
        mov byte ptr[format_nr], 14
        RET
	taip_penkioliktas:
        mov byte ptr[format_nr], 15
        RET
    neatpazintas:
        mov byte ptr[format_nr], 0
        RET

;------------------------------------------------------------------------------------------------------

;(xxxx xreg) arba (xxxs rxxx) - sreg arba (xxxx wreg)
domisi_pirmu:

    push ax
	push ax
        mov al, byte ptr[firstByte]
        call getSreg
        and al, 111b
        mov byte ptr[rm_part], al
		pop ax
		and al, 00001000b
		mov byte ptr[w_part], al
    pop ax

RET

;INT (xxxx xxxx) - bojb
domisi_antru:

   push ax
        call getFirstByte ;gaunam i AL antro baito reiksme
		push dx
		mov dl, al
		call idekSkaiciu
		pop dx
        mov byte ptr[bojb_baitas], al ;pasidedam i pacio disasmo duom segmenta bet.op. baito reiksme
   pop ax

RET

;(xxxx xxdw mod reg r/m) IR (xxxx xxxw mod xxx r/m)
domisi_treciu:

   push ax
        call getFirstByte

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

        mov byte ptr[secondByte], al
        call getMOD
		call getSreg
        call getREG
        call getRM
   pop ax

RET

;------------------------------------------------------------------------------------------------------


;*************************************************************************************************************************
;=========================================================================================================================
;*************************************************************************************************************************
;Kai zinome i kuria puse ziureti, nukreipiame i ten, kur masininis kodas bus dar konkreciau tikrinamas ir tada spausdinamas

print_kodo_eilute:

    cmp byte ptr[format_nr], 1
        je pr_kod_kviesk1
    cmp byte ptr[format_nr], 2
        je pr_kod_kviesk2
    cmp byte ptr[format_nr], 3
        je pr_kod_kviesk3
    cmp byte ptr[format_nr], 4
        je pr_kod_kviesk4
    cmp byte ptr[format_nr], 5
        je pr_kod_kviesk5
    cmp byte ptr[format_nr], 6
        je pr_kod_kviesk6
	cmp byte ptr[format_nr], 7
        je pr_kod_kviesk7
	cmp byte ptr[format_nr], 8
        je pr_kod_kviesk8
	cmp byte ptr[format_nr], 9
        je pr_kod_kviesk9
	cmp byte ptr[format_nr], 10
        je pr_kod_kviesk10
	cmp byte ptr[format_nr], 11
        je pr_kod_kviesk11
	cmp byte ptr[format_nr], 12
        je pr_kod_kviesk12
	cmp byte ptr[format_nr], 13
        je pr_kod_kviesk13
	cmp byte ptr[format_nr], 14
        je pr_kod_kviesk14
	cmp byte ptr[format_nr], 15
        je pr_kod_kviesk15

    jmp pr_kod_kviesk0

    pr_kod_kviesk1:
        call print_formatui1
        RET
    pr_kod_kviesk2:
        call print_formatui2
        RET
    pr_kod_kviesk3:
        call print_formatui3
        RET
    pr_kod_kviesk4:
        call print_formatui4
        RET
    pr_kod_kviesk5:
        call print_formatui5
        RET
    pr_kod_kviesk6:
        call print_formatui6
        RET
	pr_kod_kviesk7:
        call print_formatui7
        RET
	pr_kod_kviesk8:
		call print_formatui8
		RET
	pr_kod_kviesk9:
		call print_formatui9
		RET
	pr_kod_kviesk10:
		call print_formatui10
		RET
	pr_kod_kviesk11:
		call print_formatui11
		RET
	pr_kod_kviesk12:
		call print_formatui12
		RET
	pr_kod_kviesk13:
		call print_formatui13
		RET
	pr_kod_kviesk14:
		call print_formatui14
		RET
	pr_kod_kviesk15:
		call print_formatui15
		RET


    pr_kod_kviesk0:
        call print_formatui0
        RET


;****************** GAVUS INFO APIE BAITA ATLIEKAME TAM TIKRUS VEIKSMUS, JOG ATVAIZDUOTUME JI **************************************



print_formatui1: ;(xxxx xreg)
    push ax
    call spausdink_varda
    mov al, byte ptr[rm_part]
    call print_rm_w1_mod11
    pop ax
RET

print_formatui2:
    push ax
	  call dekTarpus
    call spausdink_varda
    mov al, byte ptr[bojb_baitas]
    call print_baita_hexu
    pop ax
RET

print_formatui3: ;formatui (xxxx xxdw mod reg r/m [poslinkis])
    push ax
		cmp mod_part, 0C0h
			je format3_spausdinimas_next
		cmp mod_part, 0h
			je format3_spausdinimas_next

        cmp mod_part, 80h;Checkiname kokio ilgio baitas bus
        je format3_poslinkis_2baitai
            call getFirstByte

			push dx
			mov dl, al
			call idekSkaiciu
			pop dx

            mov byte ptr [thirdByte], al
            jmp format3_spausdinimas_next

            format3_poslinkis_2baitai:
                call getFirstByte

				push dx
				mov dl, al
				call idekSkaiciu
				pop dx

                mov byte ptr [thirdByte], al

                call getFirstByte
				push dx
				mov dl, al
				call idekSkaiciu
				pop dx

                mov byte ptr [Byte4], al

        format3_spausdinimas_next:
		call ar_tiesioginis_adresas
		call spausdink_reg_or_rm_su_vardu

    format3_end:
        pop ax
RET


print_formatui4: ;formatui (xxxx xxxw mod xxx r/m [poslinkis] bojb [bojbv])
    push ax

    cmp mod_part, 0C0h
        je format4_antras_baitas
    cmp mod_part, 0h
        je format4_antras_baitas


    format4_poslinkis:

        cmp mod_part, 80h;Checkiname kokio ilgio baitas bus (2)
        je format4_poslinkis_2baitai
            call getFirstByte

			push dx
			mov dl, al
			call idekSkaiciu
			pop dx

            mov byte ptr [thirdByte], al
            jmp format4_antras_baitas

            format4_poslinkis_2baitai:
                call getFirstByte

				push dx
				mov dl, al
				call idekSkaiciu
				pop dx

                mov byte ptr [thirdByte], al
                call getFirstByte

				push dx
				mov dl, al
				call idekSkaiciu
				pop dx

                mov byte ptr [Byte4], al


    format4_antras_baitas: ; bojb bovb
		call ar_tiesioginis_adresas
        cmp w_part, 1h
            je format4_2baitu_bojb_bovb
            call getFirstByte
			mov byte ptr [bojb_baitas], al

			push dx
			mov dl, al
			call idekSkaiciu
			pop dx

            jmp format4_end

        format4_2baitu_bojb_bovb:
            call getFirstByte
			mov byte ptr [bojb_baitas], al

			push dx
			mov dl, al
			call idekSkaiciu
			pop dx

            call getFirstByte
			mov byte ptr [bovb_baitas], al

			push dx
			mov dl, al
			call idekSkaiciu
			pop dx

    format4_end:
	call spausdink_rm
	call spausdink_bojb_bovb

    pop ax
RET

print_formatui5: ;formatui (xxxx xxxw mod xxx r/m [poslinkis])
    push ax

    cmp mod_part, 0C0h
        je format5_end
    cmp mod_part, 0h
        je format5_end

    format5_poslinkis:
        cmp mod_part, 80h ;Checkiname kokio ilgio baitas bus (2)
        je format5_poslinkis_2baitai
            call getFirstByte

			push dx
			mov dl, al
			call idekSkaiciu
			pop dx

            mov byte ptr [thirdByte], al
            jmp format5_end

            format5_poslinkis_2baitai:
                call getFirstByte

				push dx
				mov dl, al
				call idekSkaiciu
				pop dx

                mov byte ptr [thirdByte], al
                call getFirstByte

				push dx
				mov dl, al
				call idekSkaiciu
				pop dx

                mov byte ptr [Byte4], al

    format5_end:
		call ar_tiesioginis_adresas
		call spausdink_rm
    pop ax
RET

print_formatui6: ;formatui (xxxs rxxw)

    push ax
    call spausdink_varda_sreg
    pop ax

RET

print_formatui7: ;formatui (xxxx xxdx mod 0sr r/m [poslinkis])

    push ax
	call ar_tiesioginis_adresas
    call spausdink_varda_sreg2_mov
    pop ax

RET

print_formatui8: ;formatui (xxxx xxxw ajb avb)

    push ax

    call getFirstByte

	push dx
	mov dl, al
	call idekSkaiciu
	pop dx

    mov byte ptr [thirdByte], al

    call getFirstByte

	push dx
	mov dl, al
	call idekSkaiciu
	pop dx

    mov byte ptr [Byte4], al

	;SPAUSDINAME

	cmp d_part, 0h
		je pre_ax_bus_pirmas
		jmp pre_ax_bus_antras

	pre_ax_bus_pirmas:
		call dekTarpus
		call spausdink_mov
	ax_bus_pirmas:
		cmp w_part, 0h
		je ax_bus_pirmas_w0
		jmp ax_bus_pirmas_w1

		ax_bus_pirmas_w0:
			call spausdink_al

			cmp d_part, 0h
				jne print_formatui8_end
			call spausdink_k
			jmp ax_bus_antras

		ax_bus_pirmas_w1:
			call spausdink_ax
			cmp d_part, 0h
			jne print_formatui8_end
			call spausdink_k
			jmp ax_bus_antras

    pre_ax_bus_antras:
		call dekTarpus
		call spausdink_mov


	ax_bus_antras:
		 call spausdink_sonk
		 mov dl, byte ptr [Byte4]
		 call idekSkaiciu
		 mov dl, byte ptr [thirdByte]
		 call idekSkaiciu
		 call spausdink_sond
	cmp d_part, 0h
		je print_formatui8_end
		call spausdink_k
		jmp ax_bus_pirmas

	print_formatui8_end:
    pop ax

RET


print_formatui9: ;(xxxx xreg)
    push ax

	cmp w_part, 08h
	je spausdink_rm_w1_formatui9
	jmp spausdink_rm_w0_formatui9
	spausdink_rm_w1_formatui9:
		call getFirstByte

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

        mov byte ptr [thirdByte], al

        call getFirstByte

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

        mov byte ptr [Byte4], al

		call dekTarpus
		call spausdink_mov
		mov al, byte ptr[firstByte]
		call print_rm_w1_mod11
		call spausdink_k
		mov al, byte ptr [Byte4]
		call print_jaunesnyji_baita_hexu
		mov al, byte ptr [thirdByte]
		call print_vyresnyji_baita_hexu

		jmp print_formatui9_end
	spausdink_rm_w0_formatui9:
		call getFirstByte

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

        mov byte ptr [thirdByte], al

		call dekTarpus
		call spausdink_mov

		mov al, byte ptr[firstByte]
		call print_rm_w0_mod11
		call spausdink_k
		mov al, byte ptr [thirdByte]
		call print_vyresnyji_baita_hexu

	print_formatui9_end:
    pop ax
RET

print_formatui10: ;(xxxx xxxw)
    push ax

	cmp w_part, 0h
	je spausdink_rm_w0_formatui10
	jmp spausdink_rm_w1_formatui10

	spausdink_rm_w1_formatui10:
		call getFirstByte

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

        mov byte ptr [bojb_baitas], al

        call getFirstByte

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

        mov byte ptr [bovb_baitas], al

		jmp formatui10_next
	spausdink_rm_w0_formatui10:
		call getFirstByte

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

        mov byte ptr [bojb_baitas], al

	formatui10_next:

	cmp byte ptr[firstByte], 04h        ;ADD
		jge gal_formatas10_interval
            jmp gal_desimtas1_format10
            gal_formatas10_interval:
                cmp byte ptr[firstByte], 05h
                    jle format10_add

	gal_desimtas1_format10:
	cmp byte ptr[firstByte], 2Ch        ;SUB
		jge gal_formatas10_interval1
            jmp gal_desimtas2_format10
            gal_formatas10_interval1:
                cmp byte ptr[firstByte], 2Dh
                    jle format10_sub

	gal_desimtas2_format10:
	cmp byte ptr[firstByte], 3Ch        ;CMP
		jge gal_formatas10_interval2
            gal_formatas10_interval2:
                cmp byte ptr[firstByte], 3Dh
                    jle format10_cmp

	format10_add:
		call dekTarpus
		call spausdink_add
		jmp sp_formatui10
	format10_sub:
		call dekTarpus
		call spausdink_sub
		jmp sp_formatui10
	format10_cmp:
		call dekTarpus
		call spausdink_cmp

	sp_formatui10:
	cmp w_part, 0h
	je spausdink_rm_w0_formatui10_2
	jmp spausdink_rm_w1_formatui10_2

	spausdink_rm_w0_formatui10_2:
		call spausdink_al
		call spausdink_bojb_bovb
		jmp print_formatui10_end
	spausdink_rm_w1_formatui10_2:
		call spausdink_ax
		call spausdink_bojb_bovb

	print_formatui10_end:
    pop ax
RET

print_formatui11: ;formatui (xxxx xxsw mod xxx r/m [poslinkis] bojb [bojbv]) tas kur veliau
    push ax

    cmp mod_part, 0C0h
        je format11_end_temp
    cmp mod_part, 0h
        je format11_end_temp

    format11_poslinkis:

        cmp mod_part, 80h ;Checkiname kokio ilgio baitas bus (2)
        je format11_poslinkis_2baitai
            call getFirstByte

			push dx
			mov dl, al
			call idekSkaiciu
			pop dx

            mov byte ptr [thirdByte], al

            jmp format11_end_temp

            format11_poslinkis_2baitai:
                call getFirstByte

				push dx
				mov dl, al
				call idekSkaiciu
				pop dx

                mov byte ptr [thirdByte], al

                call getFirstByte

				push dx
				mov dl, al
				call idekSkaiciu
				pop dx

                mov byte ptr [Byte4], al


        format11_end_temp:
			call ar_tiesioginis_adresas
			cmp w_part, 00h
				je format11_vienas_baitas
				jmp format11_pagal_s

			format11_vienas_baitas:
				call getFirstByte

				push dx
				mov dl, al
				call idekSkaiciu
				pop dx

				mov byte ptr [bojb_baitas], al

				jmp tesk_darba

			format11_pagal_s:
				cmp d_part, 00h
				je format11_2_baitai
				jmp format11_baitu_nuskaitymas_pletimas

			format11_2_baitai:
				call getFirstByte

				push dx
				mov dl, al
				call idekSkaiciu
				pop dx

				mov byte ptr [bojb_baitas], al
				call getFirstByte

				push dx
				mov dl, al
				call idekSkaiciu
				pop dx

				mov byte ptr [bovb_baitas], al

				jmp tesk_darba

			format11_baitu_nuskaitymas_pletimas:
				call getFirstByte

				mov byte ptr [bojb_baitas], al

				push dx
				mov dl, al
				call idekSkaiciu
				pop dx


				cmp al, 79h
					ja format11_byte_greater
					jmp format11_byte_lower
				format11_byte_greater:
					mov al, 0FFh
					mov byte ptr [bovb_baitas], al
					jmp tesk_darba
				format11_byte_lower:
					mov al, 00h
					mov byte ptr [bovb_baitas], al


	tesk_darba:
	cmp reg_part, 00h
		je formatui11_add
	cmp reg_part, 28h
		je formatui11_sub
	jmp formatui11_cmp

	formatui11_add:
		call dekTarpus
		call spausdink_add
		jmp formatui11_next_step
	formatui11_cmp:
		call dekTarpus
		call spausdink_cmp
		jmp formatui11_next_step
	formatui11_sub:
		call dekTarpus
		call spausdink_sub

    formatui11_next_step:
		call spausdink_rm_be_vardo
		call spausdink_k

		cmp w_part, 00h
			je format11_vienas_baitas2
			jmp format11_pagal_s2

			format11_vienas_baitas2:
				mov al, byte ptr [bojb_baitas]
				call print_vyresnyji_baita_hexu
				jmp format11_end

			format11_pagal_s2:
				cmp d_part, 00h
				je format11_2_baitai2
				jmp format11_baitu_nuskaitymas_pletimas2

			format11_2_baitai2:
				call print_jaunesnyji_baita_hexu
				mov al, byte ptr [bojb_baitas]
				call print_vyresnyji_baita_hexu
				mov al, byte ptr [bovb_baitas]

				jmp format11_end

			format11_baitu_nuskaitymas_pletimas2:
				mov al, byte ptr [bovb_baitas]
				call print_jaunesnyji_baita_hexu
				mov al, byte ptr [bojb_baitas]
				call print_vyresnyji_baita_hexu

    format11_end:
    pop ax
RET





print_formatui12: ;salyginiai jmp, loop ir jmp
    push ax
    call getFirstByte
	push dx
	mov dl, al
	call idekSkaiciu
	pop dx
	mov byte ptr [bojb_baitas], al
	cmp al, 79h
		ja format12_byte_greater
		jmp format12_byte_lower
			format12_byte_greater:
				mov al, 0FFh
				mov byte ptr [bovb_baitas], al
				jmp format12_tesk_darba
			format12_byte_lower:
				mov al, 00h
				mov byte ptr [bovb_baitas], al

	;Kaip ir pasiruose
	format12_tesk_darba:
		call dekTarpus
		cmp byte ptr[firstByte], 77h ;JA
			je format12_ja
		cmp byte ptr[firstByte], 73h ;JAE
			je format12_jae
		cmp byte ptr[firstByte], 72h ;JB
			je format12_jb
		cmp byte ptr[firstByte], 76h ;JBE
			je format12_jbe
		cmp byte ptr[firstByte], 74h ;JE
			je format12_je
		cmp byte ptr[firstByte], 75h ;JNE
			je format12_jne
		cmp byte ptr[firstByte], 7Fh ;JG
			je format12_jg
		cmp byte ptr[firstByte], 7Dh ;JGE
			je format12_jge
		cmp byte ptr[firstByte], 7Ch ;JL
			je format12_jl
		cmp byte ptr[firstByte], 7Eh ;JLE
			je format12_jle
		cmp byte ptr[firstByte], 78h ;JS
			je format12_js
		cmp byte ptr[firstByte], 79h ;JNS
			je format12_jns
		cmp byte ptr[firstByte], 70h ; JO
			je format12_jo
		cmp byte ptr[firstByte], 71h ;JNO
			je format12_jno
		cmp byte ptr[firstByte], 7Ah ;JP
			je format12_jp
		cmp byte ptr[firstByte], 7Bh ;JNP
			je format12_jnp
		cmp byte ptr[firstByte], 0E3h ;JCXZ
			je format12_jcxz
		cmp byte ptr[firstByte], 0E2h ;LOOP
			je format12_loop
		cmp byte ptr[firstByte], 0EBh ;JMP
			je format12_jmp

	format12_ja:
		call spausdink_ja
		jmp format12_next
	format12_jae:
		call spausdink_jae
		jmp format12_next
	format12_jb:
		call spausdink_jb
		jmp format12_next
	format12_jbe:
		call spausdink_jbe
		jmp format12_next
	format12_je:
		call spausdink_je
		jmp format12_next
	format12_jne:
		call spausdink_jne
		jmp format12_next
	format12_jg:
		call spausdink_jg
		jmp format12_next
	format12_jge:
		call spausdink_jge
		jmp format12_next
	format12_jl:
		call spausdink_jl
		jmp format12_next
	format12_jle:
		call spausdink_jle
		jmp format12_next
	format12_js:
		call spausdink_js
		jmp format12_next
	format12_jns:
		call spausdink_jns
		jmp format12_next
	format12_jo:
		call spausdink_jo
		jmp format12_next
	format12_jno:
		call spausdink_jno
		jmp format12_next
	format12_jp:
		call spausdink_jp
		jmp format12_next
	format12_jnp:
		call spausdink_jnp
		jmp format12_next
	format12_jcxz:
		call spausdink_jcxz
		jmp format12_next
	format12_loop:
		call spausdink_loop
		jmp format12_next
	format12_jmp:
		inc byte ptr [bojb_baitas]
		call spausdink_jmp

	format12_next:
		call skaiciu_sudetis
	pop ax
ret

print_formatui13:
PUSH AX
PUSH DX

	call getFirstByte

	push dx
	mov dl, al
	call idekSkaiciu
	pop dx

	mov byte ptr [bojb_baitas], al

	call getFirstByte

	push dx
	mov dl, al
	call idekSkaiciu
	pop dx

	mov byte ptr [bovb_baitas], al

	cmp byte ptr[firstByte], 0E9h ;JMP
		je formatui13_spausdink_jmp
	cmp byte ptr[firstByte], 0C2h ;ret
		je formatui13_spausdink_ret
	cmp byte ptr[firstByte], 0CAh ;retf
		je formatui13_spausdink_retf
	cmp byte ptr[firstByte], 0E8h ;call
		je formatui13_spausdink_call

	formatui13_spausdink_jmp:
		call dekTarpus
		call spausdink_jmp
		sub byte ptr [bojb_baitas], 22h
		jmp formatui13_next_step
	formatui13_spausdink_ret:
		call dekTarpus
		call spausdink_ret
		jmp formatui13_next_step
	formatui13_spausdink_retf:
		call dekTarpus
		call spausdink_retf
		jmp formatui13_next_step
	formatui13_spausdink_call:
		call dekTarpus
		call spausdink_call

	formatui13_next_step:
		cmp byte ptr[firstByte], 0E9h
			je jumpo_spausdinimas
		mov al, byte ptr [bovb_baitas]
		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

		mov al, byte ptr [bojb_baitas]

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx
		jmp baik_formata13
		jumpo_spausdinimas:
			call skaiciu_sudetis
			
		
baik_formata13:
POP AX
POP AX
ret
print_formatui14:
PUSH AX
PUSH DX
		call getFirstByte

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

		mov byte ptr [secondByte], al

		call getFirstByte

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

		mov byte ptr [thirdByte], al

		call getFirstByte

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

		mov byte ptr [bojb_baitas], al

		call getFirstByte

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

		mov byte ptr [bovb_baitas], al


		cmp byte ptr[firstByte], 0EAh ;JMP
			je formatui14_spausdink_jmp
		cmp byte ptr[firstByte], 9Ah ;call
			je formatui14_spausdink_call

		formatui14_spausdink_jmp:
			call dekTarpus
			call spausdink_jmp
			jmp formatui14_next_step

		formatui14_spausdink_call:
			call dekTarpus
			call spausdink_call

		formatui14_next_step:

			mov al, byte ptr [bovb_baitas]
			push dx
			mov dl, al
			call idekSkaiciu
			pop dx

			mov al, byte ptr [bojb_baitas]

			push dx
			mov dl, al
			call idekSkaiciu
			pop dx
			
			call spausdink_dvi
			
			mov al, byte ptr [thirdByte]

			push dx
			mov dl, al
			call idekSkaiciu
			pop dx

			mov al, byte ptr [secondByte]

			push dx
			mov dl, al
			call idekSkaiciu
			pop dx

POP AX
POP AX
ret

print_formatui15:
PUSH AX
PUSH DX

	cmp byte ptr[firstByte], 0C3h ;RET
		je formatui15_spausdink_ret
	cmp byte ptr[firstByte], 0CFh ;IRET
		je formatui15_spausdink_iret

	formatui15_spausdink_ret:
		call dekTarpus
		call spausdink_ret
		jmp formatui15_next_step

	formatui15_spausdink_iret:
		call dekTarpus
		call spausdink_iret

formatui15_next_step:
POP AX
POP AX
ret


skaiciu_sudetis:
	push ax
	push dx

	mov dx, poslinkis
	mov ah, byte ptr [bovb_baitas]
	mov al, byte ptr [bojb_baitas]
	;push dx

	;mov dl, dh
	add dx, ax
	mov al, dl
	mov dl, dh
    call idekSkaiciu

    ;pop dx

	;mov al, byte ptr [bojb_baitas]
	add dl, al
	dec dl
	dec dl
    call idekSkaiciu


	pop dx
	pop ax
ret


;NEATPAZINTAS ------------- ATLIEKAMI SPEC VEIKSMAI BUTENT JAM ---------------------------------------

print_formatui0:
    push ax
    push bx
    push cx
    push dx
            mov al, byte ptr[firstByte] ;Argumentas sekanciai procedurai (parametras)
			call dekTarpus
			call spausdink_neatpazinta
    pop dx
    pop cx
    pop bx
    pop ax
RET

;------------------------------------------------------------------------------------------------------
;******************************************************************************************************


spausdink_rm:
	call dekTarpus
	call spausdink_varda
    mov al, byte ptr[secondByte]
	call spausdink_sonk
    call spausdink_pagal_mod
    cmp mod_part, 0C0h
        je spausdink_rm_end
	cmp mod_part, 0h
        je spausdink_rm_end

	call skaiciuokPoslinki

	spausdink_rm_end:
	call spausdink_sond
ret

spausdink_rm_be_vardo:
    mov al, byte ptr[secondByte]
	cmp mod_part, 0C0h
	je persok3
	call spausdink_sonk
	persok3:
    call spausdink_pagal_mod
    cmp mod_part, 0C0h
        je spausdink_rm_be_end
	cmp mod_part, 0h
        je spausdink_rm_be_end

	call skaiciuokPoslinki

	spausdink_rm_be_end:
	cmp mod_part, 0C0h
	je persok4
	call spausdink_sond
	persok4:
ret


spausdink_bojb_bovb:
		call spausdink_k
		cmp w_part, 1h
			je dubaitu_bojb_bovb
			mov al, byte ptr [bojb_baitas]
            call print_baita_hexu
            jmp spausdink_bojb_bovb_end

        dubaitu_bojb_bovb:
			mov al, byte ptr [bovb_baitas]
            call print_jaunesnyji_baita_hexu
			mov al, byte ptr [bojb_baitas]
            call print_vyresnyji_baita_hexu

spausdink_bojb_bovb_end:
ret



skaiciuokPoslinki:
	push ax
		call spausdink_pliusa
        cmp mod_part, 80h
        je poslinkis_2baitai
            mov al, byte ptr [thirdByte]
            jmp poslinkis_next

            poslinkis_2baitai:
                mov al, byte ptr [Byte4]
                call print_jaunesnyji_baita_hexu
                mov al, byte ptr [thirdByte]

        poslinkis_next:
			call print_vyresnyji_baita_hexu
	pop ax
ret



spausdink_reg_or_rm_su_vardu:
	call spausdink_varda

    cmp d_part, 0h
        je reg_antras
		jmp reg_pirmas
    pre_reg_pirmas:
		call spausdink_k

    reg_pirmas:;DARBAS SU REG
        cmp w_part, 0h
            je reg_pirmas_byte

        reg_pirmas_word:
            mov al, byte ptr[secondByte]
            call print_reg_w1
            jmp pre_reg_antras
        reg_pirmas_byte:
            mov al, byte ptr[secondByte]
            call print_reg_w0

		pre_reg_antras:
		cmp d_part, 0h
            je spausdink_reg_or_rm_su_vardu_end
		call spausdink_k
    reg_antras:;DARBAS SU R/M
        mov al, byte ptr[secondByte]
		cmp mod_part, 0C0h
		je persok1
		call spausdink_sonk
		persok1:
        call spausdink_pagal_mod
        cmp mod_part, 0C0h
            je lastCheck
        cmp mod_part, 0h
            je lastCheck

		call skaiciuokPoslinki
	lastCheck:
		cmp mod_part, 0C0h
		je persok2
		call spausdink_sond
		persok2:
        cmp d_part, 0h
            je pre_reg_pirmas

	spausdink_reg_or_rm_su_vardu_end:
ret


;Spausdina komandos varda pagal pirma baita (bendru atveju pirma baita ir galbut antra, arba antro reg dali)
spausdink_varda_sreg:
    push ax
    push bx
    push cx
    push dx

    cmp rm_part, 06h
        je spausdink_varda_push
		call dekTarpus
		call spausdink_pop
        jmp sreg_next

    spausdink_varda_push:
		call dekTarpus
		call spausdink_push


    sreg_next:
    cmp sreg_part, 0h
        je sreg_bus_es
    cmp sreg_part, 80h
        je sreg_bus_cs
    cmp sreg_part, 10h
        je sreg_bus_ss

    jmp sreg_bus_ds

    sreg_bus_es:
	  call spausdink_es
      jmp spausdink_sreg
    sreg_bus_cs:
	  call spausdink_cs
      jmp spausdink_sreg
    sreg_bus_ss:
	  call spausdink_ss
      jmp spausdink_sreg
    sreg_bus_ds:
	  call spausdink_ds
      jmp spausdink_sreg

    spausdink_sreg:

    return_from_sreg_spausd:
        pop dx
        pop cx
        pop bx
        pop ax
RET

spausdink_varda_sreg2_mov: ;(xxxx xxdx mod 0sr r/m [poslinkis])
    push ax
    push bx
    push cx
    push dx

		cmp mod_part, 0C0h
			je kai_jau_viska_zinome
		cmp mod_part, 0h
			je kai_jau_viska_zinome

		cmp mod_part, 80h ;Checkiname kokio ilgio baitas bus (2)
			je format7_poslinkis_2baitai_mov

            call getFirstByte

			push dx
			mov dl, al
			call idekSkaiciu
			pop dx

            mov byte ptr [thirdByte], al

            jmp kai_jau_viska_zinome

            format7_poslinkis_2baitai_mov:

                call getFirstByte
				push dx
				mov dl, al
				call idekSkaiciu
				pop dx
                mov byte ptr [thirdByte], al

                call getFirstByte
				push dx
				mov dl, al
				call idekSkaiciu
				pop dx
                mov byte ptr [Byte4], al
	;KAI JAU VISKA ZINOME
	kai_jau_viska_zinome:
    cmp d_part, 0h
		je r_m_will_be_first
	jmp pre_sreg_next2

	r_m_will_be_first:
		call dekTarpus
		call spausdink_mov
		call spausdink_rm_be_vardo
		call spausdink_k
		jmp sreg_next2

	pre_sreg_next2:
		call dekTarpus
		call spausdink_mov

    sreg_next2:
    cmp sreg_part, 0h
        je sreg_bus_es2
    cmp sreg_part, 80h
        je sreg_bus_cs2
    cmp sreg_part, 10h
        je sreg_bus_ss2

    jmp sreg_bus_ds2

    sreg_bus_es2:
	  call spausdink_es
      jmp spausdink_sreg2
    sreg_bus_cs2:
	  call spausdink_cs
      jmp spausdink_sreg2
    sreg_bus_ss2:
	  call spausdink_ss
      jmp spausdink_sreg2
    sreg_bus_ds2:
	  call spausdink_ds
      jmp spausdink_sreg2

    spausdink_sreg2:
		cmp d_part, 0h
			je return_from_sreg_spausd2

		call spausdink_k
		call spausdink_rm_be_vardo


    return_from_sreg_spausd2:
        pop dx
        pop cx
        pop bx
        pop ax
RET




spausdink_varda:
    push ax
    push bx
    push cx
    push dx

    ;veliau formatui (mod xxxx r/m)
    ;gauk_komanda_pagal_reg:
        ;cmp byte ptr[reg_part], [kazkas]
        ;je [spausdink_ta_komanda] ir t.t.
	spausdink_varda_nr_next41:
    cmp byte ptr[firstByte], 20h ; KOMANDOS AND
        jge spausdink_varda_interval41
           jmp spausdink_varda_nr_next4
           spausdink_varda_interval41:
                cmp byte ptr[firstByte], 23h
                    jle komanda_and_temp
				    jmp spausdink_varda_nr_next4
					komanda_and_temp:
						jmp komanda_and

    spausdink_varda_nr_next4:
    cmp byte ptr[firstByte], 48h ; KOMANDOS DEC
        jge spausdink_varda_interval4
           jmp spausdink_varda_nr_next3
           spausdink_varda_interval4:
                cmp byte ptr[firstByte], 4Fh
                    jle komanda_dec_temp
				    jmp spausdink_varda_nr_next3
					komanda_dec_temp:
						jmp komanda_dec

    spausdink_varda_nr_next3:
    cmp byte ptr[firstByte], 50h ; KOMANDOS PUSH
        jge spausdink_varda_interval3
           jmp spausdink_varda_nr_next2
           spausdink_varda_interval3:
                cmp byte ptr[firstByte], 57h
                    jle komanda_push_temp
				    jmp spausdink_varda_nr_next2
					komanda_push_temp:
						jmp komanda_push

    spausdink_varda_nr_next2:
    cmp byte ptr[firstByte], 0C6h ; KOMANDOS MOV
        jge spausdink_varda_interval2
           jmp spausdink_varda_nr_next1
           spausdink_varda_interval2:
                cmp byte ptr[firstByte], 0C7h
                    jle komanda_mov1_temp
					jmp spausdink_varda_nr_next1

					komanda_mov1_temp:
						jmp komanda_mov

     spausdink_varda_nr_next1:
     cmp byte ptr[firstByte], 88h
        jge spausdink_varda_interval1
           jmp spausdink_varda_nr_next0
           spausdink_varda_interval1:
                cmp byte ptr[firstByte], 8Bh
                    jle komanda_mov2_temp
					jmp spausdink_varda_nr_next0
					komanda_mov2_temp:
						jmp komanda_mov
    spausdink_varda_nr_next0:
    cmp byte ptr[firstByte], 00h
        jge spausdink_varda_interval0
           jmp spausdink_varda_nr_next01
           spausdink_varda_interval0:
                cmp byte ptr[firstByte], 03h
                    jle komanda_add_temp1
					jmp spausdink_varda_nr_next01

					komanda_add_temp1:
						jmp komanda_add

    spausdink_varda_nr_next01:
    cmp byte ptr[firstByte], 28h
        jge spausdink_varda_interval01
           jmp spausdink_varda_nr_next02
           spausdink_varda_interval01:
                cmp byte ptr[firstByte], 2Bh
                    jle komanda_sub_temp
					jmp spausdink_varda_nr_next02

					komanda_sub_temp:
						jmp komanda_sub

    spausdink_varda_nr_next02:
    cmp byte ptr[firstByte], 38h
        jge spausdink_varda_interval02
           jmp spausdink_varda_nr_next03
           spausdink_varda_interval02:
                cmp byte ptr[firstByte], 3Bh
                    jle komanda_cmp_temp2
					jmp spausdink_varda_nr_next03

					komanda_cmp_temp2:
						jmp komanda_cmp

    spausdink_varda_nr_next03:
    cmp byte ptr[firstByte], 0F6h
        jge spausdink_varda_interval03
           jmp spausdink_varda_nr_next04
           spausdink_varda_interval03:
                cmp byte ptr[firstByte], 0F7h
                    jle komanda_MUL_DIV_temp
					jmp spausdink_varda_nr_next04

				komanda_MUL_DIV_temp:
					jmp komanda_MUL_DIV
   spausdink_varda_nr_next04:
        cmp byte ptr[firstByte], 8Fh
              je komanda_pop_temp
			  jmp spausdink_varda_nr_next05

			  komanda_pop_temp:
				jmp komanda_pop

    spausdink_varda_nr_next05:
    cmp byte ptr[firstByte], 0FEh
        jge spausdink_varda_interval05
           jmp spausdink_varda_nr_next
           spausdink_varda_interval05:
                cmp byte ptr[firstByte], 0FFh
                    jle komanda_PUSH_INC_DEC_CALL_JMP_temp
					jmp spausdink_varda_nr_next

					komanda_PUSH_INC_DEC_CALL_JMP_temp:
						jmp komanda_PUSH_INC_DEC_CALL_JMP

;-------------------------------------------------------------------------

    spausdink_varda_nr_next:
    ;spejam, kad cia INC (pirmas baitas is intervalo 40-47h)
    cmp byte ptr[firstByte], 40h
    jb gal_komanda_pop_temp
    cmp byte ptr[firstByte], 47h
    ja gal_komanda_pop_temp

	komanda_inc:
		call dekTarpus
		call spausdink_inc
        jmp vardo_spausdinimas

	gal_komanda_pop_temp:
		jmp gal_komanda_pop

    komanda_dec:
	    call dekTarpus
		call spausdink_dec
        jmp vardo_spausdinimas
    komanda_push:
	    call dekTarpus
		call spausdink_push
        jmp vardo_spausdinimas

    komanda_mov:
	    call dekTarpus
		call spausdink_mov
        jmp vardo_spausdinimas

    komanda_sub:
		call dekTarpus
		call spausdink_sub
        jmp vardo_spausdinimas
	komanda_and:
		call dekTarpus
		call spausdink_and
        jmp vardo_spausdinimas
    komanda_add:
		call dekTarpus
		call spausdink_add
        jmp vardo_spausdinimas
    komanda_cmp:
		call dekTarpus
		call spausdink_cmp
        jmp vardo_spausdinimas
    komanda_pop:
		call dekTarpus
		call spausdink_pop
        jmp vardo_spausdinimas
	komanda_call:
		call dekTarpus
		call spausdink_call
		jmp vardo_spausdinimas
	komanda_jmp:
		call dekTarpus
		call spausdink_jmp
		jmp vardo_spausdinimas
    komanda_PUSH_INC_DEC_CALL_JMP:
        cmp reg_part, 30h
            je komanda_push
        cmp reg_part, 00h
            je komanda_inc_temp_1
			jmp next_komanda_call
			komanda_inc_temp_1:
				jmp komanda_inc
		next_komanda_call:
		cmp reg_part, 10h
			je komanda_call
		cmp reg_part, 18h
			je komanda_call
		cmp reg_part, 20h
			je komanda_jmp
		cmp reg_part, 28h
			je komanda_jmp
        jmp komanda_dec
    komanda_MUL_DIV:
        cmp reg_part, 10h
            je komanda_MUL
            jmp komanda_DIV
            komanda_MUL:
				call dekTarpus
				call spausdink_mul
                jmp vardo_spausdinimas
            komanda_DIV:
				;call dekTarpus
				call spausdink_div
                jmp vardo_spausdinimas

    gal_komanda_pop:
        cmp byte ptr[firstByte], 58h
        jb gal_komanda_int
        cmp byte ptr[firstByte], 5Fh
        ja gal_komanda_int
        ;vis tik cia POP
		call dekTarpus
		call spausdink_pop
        jmp vardo_spausdinimas

    gal_komanda_int:
        cmp byte ptr[firstByte], 0CDh
        jne returnfrom_vardo_spausd ;griztam is vardo spausdinimo, nes nepazistam komandos
		call spausdink_int

    vardo_spausdinimas:

    returnfrom_vardo_spausd:
        pop dx
        pop cx
        pop bx
        pop ax
RET

spausdink_pagal_mod:

   cmp mod_part, 00h
        je mod_00
   cmp mod_part, 40h
        je mod_01
   cmp mod_part, 80h
        je mod_10
   cmp mod_part, 0C0h
        je mod_11

   mod_00:
     call print_rm_mod00
     jmp spausdink_pagal_mod_end
   mod_01:
     call print_rm_mod01
     jmp spausdink_pagal_mod_end

   mod_10:
     call print_rm_mod10
     jmp spausdink_pagal_mod_end

   mod_11:
     cmp w_part, 0h
        je spausdink_pagal_mod11_w0
     jmp spausdink_pagal_mod11_w1


   spausdink_pagal_mod11_w0:
      call print_rm_w0_mod11
      jmp spausdink_pagal_mod_end

   spausdink_pagal_mod11_w1:
      call print_rm_w1_mod11
      jmp spausdink_pagal_mod_end


spausdink_pagal_mod_end:
RET

;------------------------------------------------------------------------------------------------------
print_jaunesnyji_baita_hexu:
   push ax
   push bx
   push cx
   push dx
		mov dl, al
		call idekSkaiciu

   pop dx
   pop cx
   pop bx
   pop ax
RET

print_vyresnyji_baita_hexu:
   push ax
   push bx
   push cx
   push dx

		mov dl, al
		call idekSkaiciu

   pop dx
   pop cx
   pop bx
   pop ax
RET

print_baita_hexu:
   push ax
   push bx
   push cx
   push dx
        push ax
			mov byte ptr [di], '0'
			inc di
			inc bp
        pop ax

				mov dl, al
				call idekSkaiciu

   pop dx
   pop cx
   pop bx
   pop ax
RET


;************************************************************************************************************************************************************************
;----------------------------------------- PROCEDUUUUUROS NESUSIJUSIOS SU SPAUSDINIMU -----------------------------------------------------------------------------------
;************************************************************************************************************************************************************************
;Rezultato įrašymas į failą
;*****************************************************
	MOV	cx, ax				;cx - kiek baitų reikia įrašyti
	MOV	bx, rFail			;į bx įrašom rezultato failo deskriptoriaus numerį
	CALL	RasykBuf			;iškviečiame rašymo į failą procedūrą
	;CMP	ax, skBufDydis			;jeigu vyko darbas su pilnu buferiu -> iš duomenų failo buvo nuskaitytas pilnas buferis ->
	;JE	skaityk				;-> reikia skaityti toliau

;*****************************************************
;Rezultato failo uždarymas
;*****************************************************
  uzdarytiRasymui:
	MOV	ah, 3Eh				;21h pertraukimo failo uždarymo funkcijos numeris
	MOV	bx, rFail			;į bx įrašom rezultato failo deskriptoriaus numerį
	INT	21h				;failo uždarymas
	JC	klaidaUzdarantRasymui		;jei uždarant failą įvyksta klaida, nustatomas carry flag

;*****************************************************
;Duomenų failo uždarymas
;*****************************************************
  uzdarytiSkaitymui:
	MOV	ah, 3Eh				;21h pertraukimo failo uždarymo funkcijos numeris
	MOV	bx, dFail			;į bx įrašom duomenų failo deskriptoriaus numerį
	INT	21h				;failo uždarymas
	JC	klaidaUzdarantSkaitymui		;jei uždarant failą įvyksta klaida, nustatomas carry flag

  pabaiga:
	MOV	ah, 4Ch				;reikalinga kiekvienos programos pabaigoj
	MOV	al, 0				;reikalinga kiekvienos programos pabaigoj
	INT	21h				;reikalinga kiekvienos programos pabaigoj

;*****************************************************
;Klaidų apdorojimas
;*****************************************************
  klaidaAtidarantRasymui:
	;<klaidos pranešimo išvedimo kodas>
	JMP	uzdarytiSkaitymui
  klaidaUzdarantRasymui:
	;<klaidos pranešimo išvedimo kodas>
	JMP	uzdarytiSkaitymui
  klaidaUzdarantSkaitymui:
	;<klaidos pranešimo išvedimo kodas>
	JMP	pabaiga

;*****************************************************
;Procedūra nuskaitanti informaciją iš failo
;*****************************************************
PROC SkaitykBuf
;į BX paduodamas failo deskriptoriaus numeris
;į AX bus grąžinta, kiek simbolių nuskaityta
	PUSH	cx
	PUSH	dx

	MOV	ah, 3Fh			;21h pertraukimo duomenų nuskaitymo funkcijos numeris
	MOV	cx, skBufDydis		;cx - kiek baitų reikia nuskaityti iš failo
	MOV	dx, offset skBuf	;vieta, į kurią įrašoma nuskaityta informacija
	INT	21h			;skaitymas iš failo
	JC	klaidaSkaitant		;jei skaitant iš failo įvyksta klaida, nustatomas carry flag

  SkaitykBufPabaiga:
	POP	dx
	POP	cx
	RET

  klaidaSkaitant:
	;<klaidos pranešimo išvedimo kodas>
	MOV ax, 0			;Pažymime registre ax, kad nebuvo nuskaityta nė vieno simbolio
	JMP	SkaitykBufPabaiga
SkaitykBuf ENDP

;*****************************************************
;Procedūra, įrašanti buferį į failą
;*****************************************************
PROC RasykBuf
;į BX paduodamas failo deskriptoriaus numeris
;į CX - kiek baitų įrašyti
;į AX bus grąžinta, kiek baitų buvo įrašyta
	PUSH	dx
	push cx
	mov cx, bp
	MOV	ah, 40h			;21h pertraukimo duomenų įrašymo funkcijos numeris
	MOV	dx, offset raBuf	;vieta, iš kurios rašom į failą
	INT	21h			;rašymas į failą
	JC	klaidaRasant		;jei rašant į failą įvyksta klaida, nustatomas carry flag
	mov bp, 0
	pop cx

  RasykBufPabaiga:
	POP	dx
	RET

  dalinisIrasymas:
	;<klaidos pranešimo išvedimo kodas>
	JMP	RasykBufPabaiga
  klaidaRasant:
	;<klaidos pranešimo išvedimo kodas>
	MOV	ax, 0			;Pažymime registre ax, kad nebuvo įrašytas nė vienas simbolis
	JMP	RasykBufPabaiga
RasykBuf ENDP








;*******************************************************************************************************************************************
;===================================== PRASIDEDA ILGOSIOS PROCEDUROS, GETTERIAI ============================================================
;*******************************************************************************************************************************************


; FOR REG w = 1
print_reg_w1:
    push ax
    push bx
    push cx
    push dx

    test al, 00100000b
    je reg_w1_0xx
    jmp reg_w1_1xx

        reg_w1_0xx:
        test al, 00010000b
        je reg_w1_00x
        jmp reg_w1_01x

        reg_w1_1xx:
        test al, 00010000b
        je reg_w1_10x
        jmp reg_w1_11x

            reg_w1_00x:
            test al, 00001000b
            je reg_w1_000
            jmp reg_w1_001

            reg_w1_01x:
            test al, 00001000b
            je reg_w1_010
            jmp reg_w1_011

            reg_w1_10x:
            test al, 00001000b
            je reg_w1_100
            jmp reg_w1_101

            reg_w1_11x:
            test al, 00001000b
            je reg_w1_110
            jmp reg_w1_111

                reg_w1_000:
				call spausdink_ax
                jmp reg_w1_spausd

                reg_w1_001:
				call spausdink_cx
                jmp reg_w1_spausd

                reg_w1_010:
				call spausdink_dx
                jmp reg_w1_spausd

                reg_w1_011:
				call spausdink_bx
                jmp reg_w1_spausd
                ;----
                reg_w1_100:
				call spausdink_sp
                jmp reg_w1_spausd

                reg_w1_101:
				call spausdink_bp
                jmp reg_w1_spausd

                reg_w1_110:
				call spausdink_si
                jmp reg_w1_spausd

                reg_w1_111:
				call spausdink_di
                jmp reg_w1_spausd

    reg_w1_spausd:

    pop dx
    pop cx
    pop bx
    pop ax
RET


;------------------------------------------------------------------------------------------------------
; FOR REG w = 0

print_reg_w0:
    push ax
    push bx
    push cx
    push dx

    test al, 00100000b
    je reg_w0_0xx
    jmp reg_w0_1xx

        reg_w0_0xx:
        test al, 00010000b
        je reg_w0_00x
        jmp reg_w0_01x

        reg_w0_1xx:
        test al, 00010000b
        je reg_w0_10x
        jmp reg_w0_11x

            reg_w0_00x:
            test al, 00001000b
            je reg_w0_000
            jmp reg_w0_001

            reg_w0_01x:
            test al, 00001000b
            je reg_w0_010
            jmp reg_w0_011

            reg_w0_10x:
            test al, 00001000b
            je reg_w0_100
            jmp reg_w0_101

            reg_w0_11x:
            test al, 00001000b
            je reg_w0_110
            jmp reg_w0_111

                reg_w0_000:
				call spausdink_al
                jmp reg_w0_spausd

                reg_w0_001:
				call spausdink_cl
                jmp reg_w0_spausd

                reg_w0_010:
				call spausdink_dl
                jmp reg_w0_spausd

                reg_w0_011:
				call spausdink_bl
                jmp reg_w0_spausd
                ;----
                reg_w0_100:
				call spausdink_ah
                jmp reg_w0_spausd

                reg_w0_101:
				call spausdink_ch
                jmp reg_w0_spausd

                reg_w0_110:
				call spausdink_dh
                jmp reg_w0_spausd

                reg_w0_111:
				call spausdink_bh
                jmp reg_w0_spausd

    reg_w0_spausd:
    pop dx
    pop cx
    pop bx
    pop ax
RET



; WHEN MOD = 11, w = 0, print r/m  == 000 - 111
print_rm_w1_mod11:
    push ax
    push bx
    push cx
    push dx

    test al, 100b
    je rm_w1_mod11_0xx
    jmp rm_w1_mod11_1xx

        rm_w1_mod11_0xx:
        test al, 10b
        je rm_w1_mod11_00x
        jmp rm_w1_mod11_01x

        rm_w1_mod11_1xx:
        test al, 10b
        je rm_w1_mod11_10x
        jmp rm_w1_mod11_11x

            rm_w1_mod11_00x:
            test al, 1b
            je rm_w1_mod11_000
            jmp rm_w1_mod11_001

            rm_w1_mod11_01x:
            test al, 1b
            je rm_w1_mod11_010
            jmp rm_w1_mod11_011

            rm_w1_mod11_10x:
            test al, 1b
            je rm_w1_mod11_100
            jmp rm_w1_mod11_101

            rm_w1_mod11_11x:
            test al, 1b
            je rm_w1_mod11_110
            jmp rm_w1_mod11_111

                rm_w1_mod11_000:
				call spausdink_ax
                jmp rm_w1_mod11_spausd

                rm_w1_mod11_001:
				call spausdink_cx
                jmp rm_w1_mod11_spausd

                rm_w1_mod11_010:
				call spausdink_dx
                jmp rm_w1_mod11_spausd

                rm_w1_mod11_011:
				call spausdink_bx
                jmp rm_w1_mod11_spausd
                ;----
                rm_w1_mod11_100:
				call spausdink_sp
                jmp rm_w1_mod11_spausd

                rm_w1_mod11_101:
				call spausdink_bp
                jmp rm_w1_mod11_spausd

                rm_w1_mod11_110:
				call spausdink_si
                jmp rm_w1_mod11_spausd

                rm_w1_mod11_111:
				call spausdink_di
                jmp rm_w1_mod11_spausd

    rm_w1_mod11_spausd:

    pop dx
    pop cx
    pop bx
    pop ax
RET


;------------------------------------------------------------------------------------------------------
; WHEN MOD = 11, w = 0 r/m  == 000 - 111

print_rm_w0_mod11:
    push ax
    push bx
    push cx
    push dx

    test al, 100b
    je rm_w0_mod11_0xx
    jmp rm_w0_mod11_1xx

        rm_w0_mod11_0xx:
        test al, 10b
        je rm_w0_mod11_00x
        jmp rm_w0_mod11_01x

        rm_w0_mod11_1xx:
        test al, 10b
        je rm_w0_mod11_10x
        jmp rm_w0_mod11_11x

            rm_w0_mod11_00x:
            test al, 1b
            je rm_w0_mod11_000
            jmp rm_w0_mod11_001

            rm_w0_mod11_01x:
            test al, 1b
            je rm_w0_mod11_010
            jmp rm_w0_mod11_011

            rm_w0_mod11_10x:
            test al, 1b
            je rm_w0_mod11_100
            jmp rm_w0_mod11_101

            rm_w0_mod11_11x:
            test al, 1b
            je rm_w0_mod11_110
            jmp rm_w0_mod11_111

                rm_w0_mod11_000:
				call spausdink_al
                jmp rm_w0_mod11_spausd

                rm_w0_mod11_001:
				call spausdink_cl
                jmp rm_w0_mod11_spausd

                rm_w0_mod11_010:
				call spausdink_dl
                jmp rm_w0_mod11_spausd

                rm_w0_mod11_011:
				call spausdink_bl
                jmp rm_w0_mod11_spausd
                ;----
                rm_w0_mod11_100:
				call spausdink_ah
                jmp rm_w0_mod11_spausd

                rm_w0_mod11_101:
				call spausdink_ch
                jmp rm_w0_mod11_spausd

                rm_w0_mod11_110:
				call spausdink_dh
                jmp rm_w0_mod11_spausd

                rm_w0_mod11_111:
				call spausdink_bh
                jmp rm_w0_mod11_spausd

    rm_w0_mod11_spausd:

    pop dx
    pop cx
    pop bx
    pop ax
RET



;------------------------------------------------------------------------------------------------------
; WHEN MOD = 00, print r/m  == 000 - 111

print_rm_mod00:
    push ax
    push bx
    push cx
    push dx

    test al, 100b
    je rm_mod00_0xx
    jmp rm_mod00_1xx

        rm_mod00_0xx:
        test al, 10b
        je rm_mod00_00x
        jmp rm_mod00_01x

        rm_mod00_1xx:
        test al, 10b
        je rm_mod00_10x
        jmp rm_mod00_11x

            rm_mod00_00x:
            test al, 1b
            je rm_mod00_000
            jmp rm_mod00_001

            rm_mod00_01x:
            test al, 1b
            je rm_mod00_010
            jmp rm_mod00_011

            rm_mod00_10x:
            test al, 1b
            je rm_mod00_100
            jmp rm_mod00_101

            rm_mod00_11x:
            test al, 1b
            je rm_mod00_110
            jmp rm_mod00_111

                rm_mod00_000:
				call spausdink_ea_rm_000
                jmp rm_mod00_spausd

                rm_mod00_001:
				call spausdink_ea_rm_001
                jmp rm_mod00_spausd

                rm_mod00_010:
				call spausdink_ea_rm_010
                jmp rm_mod00_spausd

                rm_mod00_011:
				call spausdink_ea_rm_011
                jmp rm_mod00_spausd
                ;----
                rm_mod00_100:
				call spausdink_ea_rm_100
                jmp rm_mod00_spausd

                rm_mod00_101:
				call spausdink_ea_rm_101
                jmp rm_mod00_spausd

                rm_mod00_110:
                mov al, byte ptr [BAITAS2]
				push dx
				mov dl, al
				call idekSkaiciu
				pop dx
				mov al, byte ptr [BAITAS1]
				push dx
				mov dl, al
				call idekSkaiciu
				pop dx
                jmp rm_mod00_spausd

                rm_mod00_111:
				call spausdink_ea_rm_111
                jmp rm_mod00_spausd

    rm_mod00_spausd:

    pop dx
    pop cx
    pop bx
    pop ax
RET

;------------------------------------------------------------------------------------------------------
; WHEN MOD = 01, print r/m  == 000 - 111

print_rm_mod01:
    push ax
    push bx
    push cx
    push dx

    test al, 100b
    je rm_mod01_0xx
    jmp rm_mod01_1xx

        rm_mod01_0xx:
        test al, 10b
        je rm_mod01_00x
        jmp rm_mod01_01x

        rm_mod01_1xx:
        test al, 10b
        je rm_mod01_10x
        jmp rm_mod01_11x

            rm_mod01_00x:
            test al, 1b
            je rm_mod01_000
            jmp rm_mod01_001

            rm_mod01_01x:
            test al, 1b
            je rm_mod01_010
            jmp rm_mod01_011

            rm_mod01_10x:
            test al, 1b
            je rm_mod01_100
            jmp rm_mod01_101

            rm_mod01_11x:
            test al, 1b
            je rm_mod01_110
            jmp rm_mod01_111

                rm_mod01_000:
				call spausdink_ea_rm_000
                jmp rm_mod01_spausd

                rm_mod01_001:
				call spausdink_ea_rm_001
                jmp rm_mod01_spausd

                rm_mod01_010:
				call spausdink_ea_rm_010
                jmp rm_mod01_spausd

                rm_mod01_011:
				call spausdink_ea_rm_011
                jmp rm_mod01_spausd
                ;----
                rm_mod01_100:
				call spausdink_ea_rm_100
                jmp rm_mod01_spausd

                rm_mod01_101:
				call spausdink_ea_rm_101
                jmp rm_mod01_spausd

                rm_mod01_110:
                ;****** CIA TURI BUTI TIESIOGINIS ADRESAS
				call spausdink_ea_rm_110
                jmp rm_mod01_spausd

                rm_mod01_111:
				call spausdink_ea_rm_111
                jmp rm_mod01_spausd

    rm_mod01_spausd:

    pop dx
    pop cx
    pop bx
    pop ax
RET

;------------------------------------------------------------------------------------------------------
; WHEN MOD = 10, print r/m  == 000 - 111

print_rm_mod10:
    push ax
    push bx
    push cx
    push dx

    test al, 100b
    je rm_mod10_0xx
    jmp rm_mod10_1xx

        rm_mod10_0xx:
        test al, 10b
        je rm_mod10_00x
        jmp rm_mod10_01x

        rm_mod10_1xx:
        test al, 10b
        je rm_mod10_10x
        jmp rm_mod10_11x

            rm_mod10_00x:
            test al, 1b
            je rm_mod10_000
            jmp rm_mod10_001

            rm_mod10_01x:
            test al, 1b
            je rm_mod10_010
            jmp rm_mod10_011

            rm_mod10_10x:
            test al, 1b
            je rm_mod10_100
            jmp rm_mod10_101

            rm_mod10_11x:
            test al, 1b
            je rm_mod10_110
            jmp rm_mod10_111

                rm_mod10_000:
				call spausdink_ea_rm_000
                jmp rm_mod10_spausd

                rm_mod10_001:
				call spausdink_ea_rm_001
                jmp rm_mod10_spausd

                rm_mod10_010:
				call spausdink_ea_rm_010
                jmp rm_mod10_spausd

                rm_mod10_011:
				call spausdink_ea_rm_011
                jmp rm_mod10_spausd
                ;----
                rm_mod10_100:
				call spausdink_ea_rm_100
                jmp rm_mod10_spausd

                rm_mod10_101:
				call spausdink_ea_rm_101
                jmp rm_mod10_spausd

                rm_mod10_110:
                ;****** CIA TURI BUTI TIESIOGINIS ADRESAS
				call spausdink_ea_rm_110
                jmp rm_mod10_spausd

                rm_mod10_111:
				call spausdink_ea_rm_111
                jmp rm_mod10_spausd

    rm_mod10_spausd:

    pop dx
    pop cx
    pop bx
    pop ax
RET




;*******************************************************************************************************
;GETTERIAI
;------ GET D, W FROM FIRST BYTE, MOD REG AND R/M FROM SECOND BYTE AND FROM both SReg -----------


getD_S:
  mov byte ptr[temp_for_al], al
  and al, 00000010b
  mov byte ptr[d_part], al
  mov al, byte ptr[firstByte]
ret





getW:
  mov byte ptr[temp_for_al], al
  and al, 00000001b
  mov byte ptr[w_part], al
  mov al, byte ptr[temp_for_al]
ret




getMOD:
  mov byte ptr[temp_for_al], al
  and al, 11000000b
  mov byte ptr[mod_part], al

  mov al, byte ptr[temp_for_al]
ret



getREG:
  mov byte ptr[temp_for_al], al
  and al, 00111000b
  mov byte ptr[reg_part], al
  mov al, byte ptr[temp_for_al]
ret




getRM:
  mov byte ptr[temp_for_al], al
  and al, 00000111b
  mov byte ptr[rm_part], al
  mov al, byte ptr[temp_for_al]
ret



getSreg:;Jam reikia paduoti baita, kuriame yra sreg (byte_for_sreg)
 mov byte ptr[temp_for_al], al
 and al, 00011000b
 mov byte ptr[sreg_part], al
 mov al, byte ptr[temp_for_al]
ret



check_meybe_set_prefix:
 mov byte ptr[temp_for_al], al
 ;mov al, byte ptr[firstByte]

 cmp al, 26h
    je set_ES
 cmp al, 2Eh
    je set_CS
 cmp al, 36h
    je set_SS
 cmp al, 3Eh
    je set_DS

 mov byte ptr[prefix_nr], 0

 jmp end_of_check_meybe_set_prefix ;JEIGU NERA, TIESIOG JMP I PROCEDUROS PABAIGA

 set_ES:
    mov byte ptr[prefix_nr], 1
    jmp end_of_check_meybe_set_prefix

 set_CS:
    mov byte ptr[prefix_nr], 2
    jmp end_of_check_meybe_set_prefix

 set_SS:
    mov byte ptr[prefix_nr], 3
    jmp end_of_check_meybe_set_prefix

 set_DS:
    mov byte ptr[prefix_nr], 4
    jmp end_of_check_meybe_set_prefix


 end_of_check_meybe_set_prefix:
    mov al, byte ptr[temp_for_al]
ret
spausdink_prefiksa:
	cmp byte ptr[prefix_nr], 0
		je spausdink_prefiksa0

		cmp byte ptr[prefix_nr], 1
			je spausdink_prefiksa1
		cmp byte ptr[prefix_nr], 2
			je spausdink_prefiksa2
		cmp byte ptr[prefix_nr], 3
			je spausdink_prefiksa3
		cmp byte ptr[prefix_nr], 4
			je spausdink_prefiksa4

		spausdink_prefiksa1:
			call spausdink_es
			call spausdink_dvi
			jmp spausdink_prefiksa0

		spausdink_prefiksa2:
			call spausdink_cs
			call spausdink_dvi
			jmp spausdink_prefiksa0

		spausdink_prefiksa3:
			call spausdink_ss
			call spausdink_dvi
			jmp spausdink_prefiksa0

		spausdink_prefiksa4:
			call spausdink_ds
			call spausdink_dvi
			jmp spausdink_prefiksa0

spausdink_prefiksa0:
mov byte ptr[prefix_nr], 0
ret

;**********************************************************************************************************************
;------------------------------------------------------------------------------------------------------

;**********************************************************************************************************************
;------------------------------------------------------------------------------------------------------
idekSkaiciu:
    push dx
	and dl, 11110000b
	push cx
	mov cl, 4
	shr dl, cl
	pop cx
	cmp dl, 9h
	jg next__pradzia
	add dl, 30h
	jmp next2__pradzia
	next__pradzia:
	    add dl, 55
	next2__pradzia:
	MOV	[di], dl
	INC	di
	inc bp
	pop dx
	push dx
	and dl, 00001111b
	cmp dl, 9h
	jg next3__pradzia
	add dl, 30h
	jmp next4__pradzia
	next3__pradzia:
	    add dl, 55
	next4__pradzia:
	MOV	[di], dl
	INC	di
	inc bp
	pop dx
ret
spausdink_mov:
	mov byte ptr [di], 'M'
	inc di
	inc bp
	mov byte ptr [di], 'O'
	inc di
	inc bp
	mov byte ptr [di], 'V'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_add:
	mov byte ptr [di], 'A'
	inc di
	inc bp
	mov byte ptr [di], 'D'
	inc di
	inc bp
	mov byte ptr [di], 'D'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_inc:
	mov byte ptr [di], 'I'
	inc di
	inc bp
	mov byte ptr [di], 'N'
	inc di
	inc bp
	mov byte ptr [di], 'C'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_dec:
	mov byte ptr [di], 'D'
	inc di
	inc bp
	mov byte ptr [di], 'E'
	inc di
	inc bp
	mov byte ptr [di], 'C'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_pop:
	mov byte ptr [di], 'P'
	inc di
	inc bp
	mov byte ptr [di], 'O'
	inc di
	inc bp
	mov byte ptr [di], 'P'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_push:
	mov byte ptr [di], 'P'
	inc di
	inc bp
	mov byte ptr [di], 'U'
	inc di
	inc bp
	mov byte ptr [di], 'S'
	inc di
	inc bp
	mov byte ptr [di], 'H'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_int:
	mov byte ptr [di], 'I'
	inc di
	inc bp
	mov byte ptr [di], 'N'
	inc di
	inc bp
	mov byte ptr [di], 'T'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
ret

spausdink_sub:
	mov byte ptr [di], 'S'
	inc di
	inc bp
	mov byte ptr [di], 'U'
	inc di
	inc bp
	mov byte ptr [di], 'B'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_cmp:
	mov byte ptr [di], 'C'
	inc di
	inc bp
	mov byte ptr [di], 'M'
	inc di
	inc bp
	mov byte ptr [di], 'P'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_mul:
	mov byte ptr [di], 'M'
	inc di
	inc bp
	mov byte ptr [di], 'U'
	inc di
	inc bp
	mov byte ptr [di], 'L'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_div:
	mov byte ptr [di], 'D'
	inc di
	inc bp
	mov byte ptr [di], 'I'
	inc di
	inc bp
	mov byte ptr [di], 'V'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_call:
	mov byte ptr [di], 'C'
	inc di
	inc bp
	mov byte ptr [di], 'A'
	inc di
	inc bp
	mov byte ptr [di], 'L'
	inc di
	inc bp
	mov byte ptr [di], 'L'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_ret:
	mov byte ptr [di], 'R'
	inc di
	inc bp
	mov byte ptr [di], 'E'
	inc di
	inc bp
	mov byte ptr [di], 'T'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_loop:
	mov byte ptr [di], 'L'
	inc di
	inc bp
	mov byte ptr [di], 'O'
	inc di
	inc bp
	mov byte ptr [di], 'O'
	inc di
	inc bp
	mov byte ptr [di], 'P'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jmp:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'M'
	inc di
	inc bp
	mov byte ptr [di], 'P'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jo:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'O'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jno:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'O'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jb:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'B'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jae:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'A'
	inc di
	inc bp
	mov byte ptr [di], 'E'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_je:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'E'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jne:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'N'
	inc di
	inc bp
	mov byte ptr [di], 'E'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jbe:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'B'
	inc di
	inc bp
	mov byte ptr [di], 'E'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_ja:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'A'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_js:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'S'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jns:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'N'
	inc di
	inc bp
	mov byte ptr [di], 'S'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jp:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'P'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jnp:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'N'
	inc di
	inc bp
	mov byte ptr [di], 'P'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jl:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'L'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jge:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'G'
	inc di
	inc bp
	mov byte ptr [di], 'E'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jle:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'L'
	inc di
	inc bp
	mov byte ptr [di], 'E'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jg:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'G'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_jcxz:
	mov byte ptr [di], 'J'
	inc di
	inc bp
	mov byte ptr [di], 'C'
	inc di
	inc bp
	mov byte ptr [di], 'X'
	inc di
	inc bp
	mov byte ptr [di], 'Z'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret
spausdink_retf:
	mov byte ptr [di], 'R'
	inc di
	inc bp
	mov byte ptr [di], 'E'
	inc di
	inc bp
	mov byte ptr [di], 'T'
	inc di
	inc bp
	mov byte ptr [di], 'F'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_iret:
	mov byte ptr [di], 'I'
	inc di
	inc bp
	mov byte ptr [di], 'R'
	inc di
	inc bp
	mov byte ptr [di], 'E'
	inc di
	inc bp
	mov byte ptr [di], 'T'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_and:
	mov byte ptr [di], 'A'
	inc di
	inc bp
	mov byte ptr [di], 'N'
	inc di
	inc bp
	mov byte ptr [di], 'D'
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	call spausdink_prefiksa
ret

spausdink_ea_rm_000:
	mov byte ptr [di], 'b'
	inc di
	inc bp
	mov byte ptr [di], 'x'
	inc di
	inc bp
	mov byte ptr [di], '+'
	inc di
	inc bp
	mov byte ptr [di], 's'
	inc di
	inc bp
	mov byte ptr [di], 'i'
	inc di
	inc bp
ret

spausdink_ea_rm_001:
	mov byte ptr [di], 'b'
	inc di
	inc bp
	mov byte ptr [di], 'x'
	inc di
	inc bp
	mov byte ptr [di], '+'
	inc di
	inc bp
	mov byte ptr [di], 'd'
	inc di
	inc bp
	mov byte ptr [di], 'i'
	inc di
	inc bp
ret

spausdink_ea_rm_010:
	mov byte ptr [di], 'b'
	inc di
	inc bp
	mov byte ptr [di], 'p'
	inc di
	inc bp
	mov byte ptr [di], '+'
	inc di
	inc bp
	mov byte ptr [di], 's'
	inc di
	inc bp
	mov byte ptr [di], 'i'
	inc di
	inc bp
ret

spausdink_ea_rm_011:
	mov byte ptr [di], 'b'
	inc di
	inc bp
	mov byte ptr [di], 'p'
	inc di
	inc bp
	mov byte ptr [di], '+'
	inc di
	inc bp
	mov byte ptr [di], 'd'
	inc di
	inc bp
	mov byte ptr [di], 'i'
	inc di
	inc bp
ret

spausdink_ea_rm_100:
	mov byte ptr [di], 's'
	inc di
	inc bp
	mov byte ptr [di], 'i'
	inc di
	inc bp
ret

spausdink_ea_rm_101:
	mov byte ptr [di], 'd'
	inc di
	inc bp
	mov byte ptr [di], 'i'
	inc di
	inc bp
ret

spausdink_ea_rm_110:
	mov byte ptr [di], 'b'
	mov byte ptr [di], 'b'
	inc di
	inc bp
	mov byte ptr [di], 'p'
	inc di
	inc bp
ret

spausdink_ea_rm_111:
	mov byte ptr [di], 'b'
	inc di
	inc bp
	mov byte ptr [di], 'x'
	inc di
	inc bp
ret

spausdink_es:
	mov byte ptr [di], 'e'
	inc di
	inc bp
	mov byte ptr [di], 's'
	inc di
	inc bp
ret

spausdink_cs:
	mov byte ptr [di], 'c'
	inc di
	inc bp
	mov byte ptr [di], 's'
	inc di
	inc bp
ret

spausdink_ss:
	mov byte ptr [di], 's'
	inc di
	inc bp
	mov byte ptr [di], 's'
	inc di
	inc bp
ret

spausdink_ds:
	mov byte ptr [di], 'd'
	inc di
	inc bp
	mov byte ptr [di], 's'
	inc di
	inc bp
ret

spausdink_ax:
	mov byte ptr [di], 'a'
	inc di
	inc bp
	mov byte ptr [di], 'x'
	inc di
	inc bp
ret

spausdink_al:
	mov byte ptr [di], 'a'
	inc di
	inc bp
	mov byte ptr [di], 'l'
	inc di
	inc bp
ret

spausdink_ah:
	mov byte ptr [di], 'a'
	inc di
	inc bp
	mov byte ptr [di], 'h'
	inc di
	inc bp
ret

spausdink_cx:
	mov byte ptr [di], 'c'
	inc di
	inc bp
	mov byte ptr [di], 'x'
	inc di
	inc bp
ret

spausdink_cl:
	mov byte ptr [di], 'c'
	inc di
	inc bp
	mov byte ptr [di], 'l'
	inc di
	inc bp
ret

spausdink_ch:
	mov byte ptr [di], 'c'
	inc di
	inc bp
	mov byte ptr [di], 'h'
	inc di
	inc bp
ret

spausdink_dx:
	mov byte ptr [di], 'd'
	inc di
	inc bp
	mov byte ptr [di], 'x'
	inc di
	inc bp
ret

spausdink_dl:
	mov byte ptr [di], 'd'
	inc di
	inc bp
	mov byte ptr [di], 'l'
	inc di
	inc bp
ret

spausdink_dh:
	mov byte ptr [di], 'd'
	inc di
	inc bp
	mov byte ptr [di], 'h'
	inc di
	inc bp
ret

spausdink_bx:
	mov byte ptr [di], 'b'
	inc di
	inc bp
	mov byte ptr [di], 'x'
	inc di
	inc bp
ret

spausdink_bl:
	mov byte ptr [di], 'b'
	inc di
	inc bp
	mov byte ptr [di], 'l'
	inc di
	inc bp
ret

spausdink_bh:
	mov byte ptr [di], 'b'
	inc di
	inc bp
	mov byte ptr [di], 'h'
	inc di
	inc bp
ret

spausdink_sp:
	mov byte ptr [di], 's'
	inc di
	inc bp
	mov byte ptr [di], 'p'
	inc di
	inc bp
ret

spausdink_bp:
	mov byte ptr [di], 'b'
	inc di
	inc bp
	mov byte ptr [di], 'p'
	inc di
	inc bp
ret

spausdink_si:
	mov byte ptr [di], 's'
	inc di
	inc bp
	mov byte ptr [di], 'i'
	inc di
	inc bp
ret

spausdink_di:
	mov byte ptr [di], 'd'
	inc di
	inc bp
	mov byte ptr [di], 'i'
	inc di
	inc bp
ret

spausdink_k:
	mov byte ptr [di], ','
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
ret

spausdink_sond:
	mov byte ptr [di], ']'
	inc di
	inc bp
ret
spausdink_sonk:
	mov byte ptr [di], '['
	inc di
	inc bp
ret

spausdink_dvi:
	mov byte ptr [di], ':'
	inc di
	inc bp
ret
spausdink_pliusa:
	mov byte ptr [di], '+'
	inc di
	inc bp
ret
dekTarpus:
	tarpuCiklas:
	mov byte ptr [di], ' '
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	add tarpuKintamasis, 2
	cmp tarpuKintamasis, 20
		jl tarpuCiklas
	mov tarpuKintamasis, 0
ret
trysTarpai:
	mov byte ptr [di], ' '
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
ret
duTarpai:
	mov byte ptr [di], ' '
	inc di
	inc bp
	mov byte ptr [di], ' '
	inc di
	inc bp
ret

spausdink_enter:
	mov byte ptr [di], 13
	inc di
	inc bp
	mov byte ptr [di], 10
	inc di
	inc bp
ret
spausdink_neatpazinta:
	mov byte ptr [di], 'N'
	inc di
	inc bp
	mov byte ptr [di], 'E'
	inc di
	inc bp
	mov byte ptr [di], 'A'
	inc di
	inc bp
	mov byte ptr [di], 'T'
	inc di
	inc bp
	mov byte ptr [di], 'P'
	inc di
	inc bp
	mov byte ptr [di], 'A'
	inc di
	inc bp
	mov byte ptr [di], 'Z'
	inc di
	inc bp
	mov byte ptr [di], 'I'
	inc di
	inc bp
	mov byte ptr [di], 'N'
	inc di
	inc bp
	mov byte ptr [di], 'T'
	inc di
	inc bp
	mov byte ptr [di], 'A'
	inc di
	inc bp
ret
ar_tiesioginis_adresas:
push ax
push dx

	cmp mod_part, 0h
		je taip_gal_tiesioginis
		jmp ne_netiesioginis

	taip_gal_tiesioginis:
		cmp rm_part, 06h
			je taip_tiesioginis
			jmp ne_netiesioginis

	taip_tiesioginis:
		call getFirstByte

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

		mov byte ptr [BAITAS1], al

		call getFirstByte

		push dx
		mov dl, al
		call idekSkaiciu
		pop dx

		mov byte ptr [BAITAS2], al


ne_netiesioginis:
pop dx
pop ax
ret



exit:
    mov ah, 4Ch
    int 21h



END pradzia
