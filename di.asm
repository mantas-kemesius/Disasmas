;***************************************************************
; Programa atidaranti failą duom.txt, pakeičianti mažąsias raides didžiosiomis ir rezultatą įrašanti į failą rez.txt
;***************************************************************
.model small
skBufDydis	EQU 10000			;konstanta skBufDydis (lygi 20) - skaitymo buferio dydis
raBufDydis	EQU 10000		;konstanta raBufDydis (lygi 20) - rašymo buferio dydis
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
counter dw 0
bituKiekis dw 0
loopCounter dw 0

min dw 0
max dw 0
kiekCX db 0
bxSave	dw 0082h
help    db "II atsiskaitomasis darbas, X variantas.",10,13, "Sia uzduoti atliko Mantas Kemesius VU MIF PS II k. 6gr.$"
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
   ; Mas_kodas db 41h, 42h, 43h, 59h,13h
    ;          db  0h,0ECh, 0CDh,21h, 12h
     ;         db 26h,74h, 5Ch, 5Fh  
              
    Mas_kodas db 0B8h, 80h, 0FFh, 0C8h, 0C6h
              db 00h,23h, 24h,3Bh, 12h
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
      
    firstByte db ? ;pasidedam pirma komandos baita
    secondByte db ? ;pasidedam pirma komandos baita
    thirdByte db ? ;pasidedam pirma komandos baita
    Byte4 db ? ;pasidedam pirma komandos baita
    
    format_nr db ? ;dabartines komandos formato numeris

;---------------SPAUSDINAMU KOMANDU VARDAI
    c_INC db 'INC $'
    c_POP db 'POP $'
    c_INT db 'INT $'
    c_MOV db 'MOV $'
    c_PUSH db 'PUSH $'
    c_ADD db 'ADD $'
    c_DEC db 'DEC $'
    c_SUB db 'SUB $'
    c_CMP db 'CMP $'
    c_MUL db 'MUL $'
    c_DIV db 'DIV $'
    c_CALL db 'CALL $'
    c_RET db 'RET $'
    
    c_JMP db 'JMP $'
    c_JO db 'JO $'
    c_JNO db 'JNO $'
    c_JNAE db 'JNAE $'
    c_JAE db 'JAE $'
    c_JE db 'JE $'
    c_JNE db 'JNE $'
    c_JBE db 'JBE $'
    c_JA db 'JA $'
    c_JS db 'JS $'
    c_JNS db 'JNS $'
    c_JP db 'JP $'
    c_JNP db 'JNP $'
    c_JL db 'JL $'
    c_JGE db 'JGE $'
    c_JLE db 'JLE $'
    c_JG db 'JG $' 
    
    c_LOOP db 'LOOP $'

;---------------SPAUSDINAMU REGISTRU VARDAI
    ea_rm000 db 'bx+si$'
    ea_rm001 db 'bx+di$'
    ea_rm010 db 'bp+si$'
    ea_rm011 db 'bp+di$'
    ea_rm100 db 'si$'
    ea_rm101 db 'di$'
    ea_rm110 db 'bp$';kai mod=00 ir r/m = 110, tai tiesioginis
    ea_rm111 db 'bx$'
    

    t_ES db 'es$'
    t_CS db 'cs$'
    t_SS db 'ss$'
    t_DS db 'ds$'

    r_AX db 'ax$'
    r_AL db 'al$'
    r_AH db 'ah$'
    
    r_CX db 'cx$'
    r_CL db 'cl$'
    r_CH db 'ch$'
    
    r_DX db 'dx$'
    r_DL db 'dl$'
    r_DH db 'dh$'
    
    r_BX db 'bx$'
    r_BL db 'bl$'
    r_BH db 'bh$'
    
    r_SP db 'sp$'
    r_BP db 'bp$'
    r_SI db 'si$'
    r_DI db 'di$'

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
		JMP pabaiga

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
;*****************************************************
;Duomenų failo atidarymas skaitymui
;*****************************************************
	MOV	ah, 3Dh				;21h pertraukimo failo atidarymo funkcijos numeris
	MOV	al, 00				;00 - failas atidaromas skaitymui
	INT	21h				;failas atidaromas skaitymui
	;JC	klaidaAtidarantSkaitymui	;jei atidarant failą skaitymui įvyksta klaida, nustatomas carry flag
	MOV	dFail, ax			;atmintyje išsisaugom duomenų failo deskriptoriaus numerį
	jmp failoParametras2
;*****************************************************
;Rezultato failo sukūrimas ir atidarymas rašymui
;*****************************************************
	rez_atidarymas:
	MOV	ah, 3Ch				;21h pertraukimo failo sukūrimo funkcijos numeris
	MOV	cx, 0				;kuriamo failo atributai
	MOV	dx, offset rez			;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
	INT	21h				;sukuriamas failas; jei failas jau egzistuoja, visa jo informacija ištrinama
	;JC	klaidaAtidarantRasymui		;jei kuriant failą skaitymui įvyksta klaida, nustatomas carry flag
	MOV	rFail, ax			;atmintyje išsisaugom rezultato failo deskriptoriaus numerį

;*****************************************************
;Duomenų nuskaitymas iš failo
;*****************************************************
  skaityk:
	MOV	bx, dFail			;į bx įrašom duomenų failo deskriptoriaus numerį
	CALL	SkaitykBuf			;iškviečiame skaitymo iš failo procedūrą
	CMP	ax, 0				;ax įrašoma, kiek baitų buvo nuskaityta, jeigu 0 - pasiekta failo pabaiga

;*****************************************************
;Darbas su nuskaityta informacija
;*****************************************************
	xor bx,bx
	MOV	cx, ax
	mov cx, 15h
	;MOV	si, offset skBuf
	mov si, offset Mas_kodas
	MOV	di, offset raBuf
	

MainLoop:
    call getFirstByte
	
	MOV	dl, al
	push dx
	and dl, 11110000b
	push cx
	mov cl, 4
	shr dl, cl
	pop cx
	cmp dl, 9h
	jge next__pradzia
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
	MOV	[di], ' '
	INC	di
	inc bp
	
    mov byte ptr[firstByte], al

    call getInfo
    call print_kodo_eilute
	
    mov ah, 9
    mov dx, offset enteris
    int 21h  
        
Loop MainLoop

	;------------------------------------------------------------------------------------------------------
    
getFirstByte:
    mov al,[si]
    inc si
    inc loopCounter
    
    cmp loopCounter, cx
    ja getFirstByte_temp_jmp_to_end_program   
    
    jmp getFirstByte_end

    getFirstByte_temp_jmp_to_end_program:
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
		je domisi_treciu_temp
    cmp byte ptr[format_nr], 11 ;jei formatas (xxxx xxsw mod xxx r/m [poslinkis] bovb [bojb] )
		je domisi_treciu_temp		
       		
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
				jmp taip_penktas_temp0
				jmp gal_penktas2
				taip_penktas_temp0:
					jmp taip_penktas
    gal_penktas2: ;kai (xxxx xxxw mod xxx r/m [poslinkis])
        cmp byte ptr[firstByte], 0FEh        ;PUSH, INC arba DEC atskiraime pagal REG
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
                    jle taip_devintas	
					
	gal_desimtas:
	cmp byte ptr[firstByte], 04h        ;ADD
		jge gal_desimtas_interval
            jmp gal_desimtas1
            gal_desimtas_interval:
                cmp byte ptr[firstByte], 05h
                    jle taip_desimtas	

	gal_desimtas1:
	cmp byte ptr[firstByte], 2Ch        ;SUB
		jge gal_desimtas1_interval
            jmp gal_desimtas2
            gal_desimtas1_interval:
                cmp byte ptr[firstByte], 2Dh
                    jle taip_desimtas	
					
	gal_desimtas2:
	cmp byte ptr[firstByte], 3Ch        ;CMP
		jge gal_desimtas2_interval
            jmp gal_vienuoliktas
            gal_desimtas2_interval:
                cmp byte ptr[firstByte], 3Dh
                    jle taip_desimtas	
					
	gal_vienuoliktas:
	cmp byte ptr[firstByte], 80h        ;SU S raidem
		jge gal_vienuoliktas_interval
            jmp gauk_formato_nr_next
            gal_vienuoliktas_interval:
                cmp byte ptr[firstByte], 83h
                    jle taip_vienuoliktas					
					
    gauk_formato_nr_next:
    
    jmp neatpazintas
    
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
        mov byte ptr[bojb_baitas], al ;pasidedam i pacio disasmo duom segmenta bet.op. baito reiksme
   pop ax
   
RET

;(xxxx xxdw mod reg r/m) IR (xxxx xxxw mod xxx r/m)
domisi_treciu:

   push ax
        call getFirstByte
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
    call spausdink_varda
    mov al, byte ptr[bojb_baitas]
    call print_baita_hexu
    pop ax
RET

print_formatui3: ;formatui (xxxx xxdw mod reg r/m [poslinkis])
    push ax
    call spausdink_varda
    cmp d_part, 0h
        je format3_reg_antras
        
    format3_reg_pirmas:;DARBAS SU REG
        cmp w_part, 0h
            je format3_reg_pirmas_byte
            
        format3_reg_pirmas_word:
            mov al, byte ptr[secondByte]
            call print_reg_w1
            mov ah, 9
            mov dx, offset k_
            int 21h
            jmp format3_reg_antras
        format3_reg_pirmas_byte:
            mov al, byte ptr[secondByte]
            call print_reg_w0
            mov ah, 9
            mov dx, offset k_
            int 21h
             
    format3_reg_antras:;DARBAS SU R/M
        mov ah, 9
        mov dx, offset sonk_
        int 21h
        mov al, byte ptr[secondByte]
        call spausdink_pagal_mod
        cmp mod_part, 0C0h
            je format3_lastCheck
        cmp mod_part, 0h
            je format3_lastCheck   
                    
                    
    format3_poslinkis:
        mov ah, 9
        mov dx, offset pliusas_
        int 21h
        
        cmp mod_part, 80h;Checkiname kokio ilgio baitas bus
        je format3_poslinkis_2baitai
            call getFirstByte
            mov byte ptr [thirdByte], al
            jmp format3_poslinkis_next
            
            format3_poslinkis_2baitai:
                call getFirstByte
                mov byte ptr [thirdByte], al
                call getFirstByte
                mov byte ptr [Byte4], al
                call print_jaunesnyji_baita_hexu
                mov al, byte ptr [thirdByte]
                 
       format3_poslinkis_next:                      
        call print_vyresnyji_baita_hexu
        
    format3_lastCheck:
        mov ah, 9
        mov dx, offset sond_
        int 21h
            
        cmp d_part, 0h
            je format3_reg_pirmas_second         
        jmp format3_end
                               
                               
                                                          
    format3_reg_pirmas_second:;DARBAS SU REG
        mov ah, 9
        mov dx, offset k_
        int 21h
        cmp w_part, 0h
            je format3_reg_pirmas_second_byte
            
        format3_reg_pirmas_second_word:
            mov al, byte ptr[secondByte]
            call print_reg_w1
            jmp format3_end
            
        format3_reg_pirmas_second_byte:
            mov al, byte ptr[secondByte]
            call print_reg_w0 
              
    format3_end:
        pop ax
RET





print_formatui4: ;formatui (xxxx xxxw mod xxx r/m [poslinkis] bojb [bojbv])
    push ax
    call spausdink_varda
    
    mov ah, 9
    mov dx, offset sonk_
    int 21h
    mov al, byte ptr[secondByte]
    call spausdink_pagal_mod
    cmp mod_part, 0C0h
        je format4_antras_baitas
    cmp mod_part, 0h
        je format4_antras_baitas   
                    
                    
    format4_poslinkis:
        mov ah, 9
        mov dx, offset pliusas_
        int 21h
        
        cmp mod_part, 80h;Checkiname kokio ilgio baitas bus (2)
        je format4_poslinkis_2baitai
            call getFirstByte
            mov byte ptr [thirdByte], al
            jmp format4_poslinkis_next
            
            format4_poslinkis_2baitai:
                call getFirstByte
                mov byte ptr [thirdByte], al
                call getFirstByte
                mov byte ptr [Byte4], al
                call print_jaunesnyji_baita_hexu
                mov al, byte ptr [thirdByte]
                 
       format4_poslinkis_next:                      
        call print_vyresnyji_baita_hexu
        
    format4_antras_baitas: ; bojb bovb
        mov ah, 9
        mov dx, offset sond_
        int 21h
        mov dx, offset k_
        int 21h  
        cmp w_part, 1h
            je format4_2baitu_bojb_bovb
            call getFirstByte
            call print_baita_hexu
            jmp format4_end
                
        format4_2baitu_bojb_bovb:
            call getFirstByte
            call print_jaunesnyji_baita_hexu
            call getFirstByte   
            call print_vyresnyji_baita_hexu
            
    format4_end:
    pop ax
RET

print_formatui5: ;formatui (xxxx xxxw mod xxx r/m [poslinkis] bojb [bojbv])
    push ax
    call spausdink_varda
    
    mov ah, 9
    mov dx, offset sonk_
    int 21h
    mov al, byte ptr[secondByte]
    call spausdink_pagal_mod  
    cmp mod_part, 0C0h
        je format5_end
    cmp mod_part, 0h
        je format5_end                   
                    
    format5_poslinkis:
        mov ah, 9
        mov dx, offset pliusas_
        int 21h
        
        cmp mod_part, 80h ;Checkiname kokio ilgio baitas bus (2)
        je format5_poslinkis_2baitai
            call getFirstByte
            mov byte ptr [thirdByte], al
            jmp format5_poslinkis_next
            
            format5_poslinkis_2baitai:
                call getFirstByte
                mov byte ptr [thirdByte], al
                call getFirstByte
                mov byte ptr [Byte4], al
                call print_jaunesnyji_baita_hexu
                mov al, byte ptr [thirdByte]
                 
       format5_poslinkis_next:                      
        call print_vyresnyji_baita_hexu
        
            
    format5_end:
    mov ah, 9
    mov dx, offset sond_
    int 21h
    pop ax
RET

print_formatui6: ;formatui (xxxs rxxw)
    
    push ax
    call spausdink_varda_sreg
    pop ax
    
RET

print_formatui7: ;formatui (xxxx xxdx mod 0sr r/m [poslinkis])
    
    push ax
    call spausdink_varda_sreg2_mov
    pop ax
    
RET

print_formatui8: ;formatui (xxxx xxxw ajb avb)
    
    push ax
	mov ah,9
    mov dx, offset c_MOV
    int 21h
	cmp d_part, 0h
		je ax_bus_pirmas
		jmp ax_bus_antras
		
	ax_bus_pirmas:
		cmp w_part, 0h
		je ax_bus_pirmas_w0
		jmp ax_bus_pirmas_w1
		
		ax_bus_pirmas_w0:
			mov ah,9
			mov dx, offset r_AL
			int 21h
			cmp d_part, 0h
			jne print_formatui8_end
			mov dx, offset k_
			int 21h
			jmp ax_bus_antras
		
		ax_bus_pirmas_w1:
			mov ah,9
			mov dx, offset r_AX
			int 21h
			cmp d_part, 0h
			jne print_formatui8_end
			mov dx, offset k_
			int 21h
			jmp ax_bus_antras	
			
	ax_bus_antras:
		cmp w_part, 1h;Checkiname kokio ilgio baitas bus (2)
        je format8_poslinkis_2baitai
            call getFirstByte
            mov byte ptr [thirdByte], al
            jmp format8_poslinkis_next
            
            format8_poslinkis_2baitai:
                call getFirstByte
                mov byte ptr [thirdByte], al
                call getFirstByte
                mov byte ptr [Byte4], al
                call print_jaunesnyji_baita_hexu
                mov al, byte ptr [thirdByte]
                 
       format8_poslinkis_next:                      
         call print_vyresnyji_baita_hexu
		 cmp d_part, 0h
			jne ax_bus_pirmas_temp
			jmp print_formatui8_end
		ax_bus_pirmas_temp:	
		 mov ah, 9
		 mov dx, offset k_ 
		 int 21h
		jmp ax_bus_pirmas	 
    
	print_formatui8_end:
    pop ax
    
RET

print_formatui9: ;(xxxx xreg)
    push ax
    mov ah,9
    mov dx, offset c_MOV
    int 21h
    mov al, byte ptr[rm_part]
	cmp w_part, 08h
	je spausdink_rm_w1_formatui9
	jmp spausdink_rm_w0_formatui9
	spausdink_rm_w1_formatui9:
		call print_rm_w1_mod11
		mov ah,9
		mov dx, offset k_
		int 21h
		call getFirstByte
        mov byte ptr [thirdByte], al
        call getFirstByte
        mov byte ptr [Byte4], al
        call print_jaunesnyji_baita_hexu
        mov al, byte ptr [thirdByte]
		call print_vyresnyji_baita_hexu
		
		jmp print_formatui9_end
	spausdink_rm_w0_formatui9:
		call print_rm_w0_mod11
		mov ah,9
		mov dx, offset k_
		int 21h
		call getFirstByte
        mov byte ptr [thirdByte], al
		call print_vyresnyji_baita_hexu
		
	print_formatui9_end:
    pop ax
RET
print_formatui10: ;(xxxx xxxw)
    push ax
	
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
		mov ah,9
		mov dx, offset c_ADD
		int 21h
		jmp sp_formatui10
	format10_sub:
		mov ah,9
		mov dx, offset c_SUB
		int 21h
		jmp sp_formatui10
	format10_cmp:
		mov ah,9
		mov dx, offset c_CMP
		int 21h
	
	
	sp_formatui10:
	cmp w_part, 0h
	je spausdink_rm_w0_formatui10
	jmp spausdink_rm_w1_formatui10
	spausdink_rm_w1_formatui10:
		mov ah,9
		mov dx, offset r_AX
		int 21h
		mov ah,9
		mov dx, offset k_
		int 21h
		call getFirstByte
        mov byte ptr [thirdByte], al
        call getFirstByte
        mov byte ptr [Byte4], al
        call print_jaunesnyji_baita_hexu
        mov al, byte ptr [thirdByte]
		call print_vyresnyji_baita_hexu
		
		jmp print_formatui10_end
	spausdink_rm_w0_formatui10:
		mov ah,9
		mov dx, offset r_AL
		int 21h
		mov ah,9
		mov dx, offset k_
		int 21h
		call getFirstByte
        mov byte ptr [thirdByte], al
		call print_vyresnyji_baita_hexu
		
	print_formatui10_end:
    pop ax
RET

print_formatui11: ;formatui (xxxx xxxw mod xxx r/m [poslinkis] bojb [bojbv])
    push ax
    
	cmp reg_part, 00h
		je formatui11_add
	cmp reg_part, 0A0h
		je formatui11_sub
	jmp formatui11_cmp
	
	formatui11_add:
		mov ah, 9
        mov dx, offset c_ADD
        int 21h
		jmp formatui11_next_step
	formatui11_cmp:
		mov ah, 9
        mov dx, offset c_CMP
        int 21h
		jmp formatui11_next_step
	formatui11_sub:
		mov ah, 9
        mov dx, offset c_SUB
        int 21h
		
    formatui11_next_step:
	
    mov ah, 9
    mov dx, offset sonk_
    int 21h
    mov al, byte ptr[secondByte]
    call spausdink_pagal_mod  
    cmp mod_part, 0C0h
        je format11_end_temp
    cmp mod_part, 0h
        je format11_end_temp                   
                    
    format11_poslinkis:
        mov ah, 9
        mov dx, offset pliusas_
        int 21h
        
        cmp mod_part, 80h ;Checkiname kokio ilgio baitas bus (2)
        je format11_poslinkis_2baitai
            call getFirstByte
            mov byte ptr [thirdByte], al
            jmp format11_poslinkis_next
            
            format11_poslinkis_2baitai:
                call getFirstByte
                mov byte ptr [thirdByte], al
                call getFirstByte
                mov byte ptr [Byte4], al
                call print_jaunesnyji_baita_hexu
                mov al, byte ptr [thirdByte]
                 
       format11_poslinkis_next:                      
        call print_vyresnyji_baita_hexu
        
        format11_end_temp:
			mov ah, 9
			mov dx, offset sond_
			int 21h
			mov ah, 9
			mov dx, offset k_
			int 21h
			cmp w_part, 00h
				je format11_vienas_baitas
				jmp format11_pagal_s
				
			format11_vienas_baitas:
				call getFirstByte
				call print_vyresnyji_baita_hexu
				jmp format11_end
				
			format11_pagal_s:
				cmp d_part, 00h
				je format11_2_baitai
				jmp format11_baitu_nuskaitymas_pletimas
				
			format11_2_baitai:
				call getFirstByte
				call print_jaunesnyji_baita_hexu
				call getFirstByte
				call print_vyresnyji_baita_hexu
				jmp format11_end
			
			format11_baitu_nuskaitymas_pletimas:
				call getFirstByte
				mov byte ptr [thirdByte], al
				cmp al, 79h
					ja format11_byte_greater
					jmp format11_byte_lower
				format11_byte_greater:
					mov al, 0FFh
					call print_jaunesnyji_baita_hexu
					mov al, byte ptr [thirdByte]
					call print_vyresnyji_baita_hexu
					jmp format11_end
				format11_byte_lower:
					mov al, 00h
					call print_jaunesnyji_baita_hexu
					mov al, byte ptr [thirdByte]
					call print_vyresnyji_baita_hexu
				
    format11_end:
    pop ax
RET


;NEATPAZINTAS------------- ATLIEKAMI SPEC VEIKSMAI BUTENT JAM ---------------------------------------

print_formatui0:
    push ax
    push bx
    push cx
    push dx
        mov ah, 9
        mov dx, offset neatp_pradzia
        int 21h
            mov al, byte ptr[firstByte] ;Argumentas sekanciai procedurai (parametras)
            call print_baita_hexu
        mov ah, 9
        mov dx, offset neatp_pabaiga
        int 21h
    pop dx
    pop cx
    pop bx
    pop ax
RET

;------------------------------------------------------------------------------------------------------
;******************************************************************************************************
	

;Spausdina komandos varda pagal pirma baita (bendru atveju pirma baita ir galbut antra, arba antro reg dali)
spausdink_varda_sreg:
    push ax
    push bx
    push cx
    push dx 
    
    cmp rm_part, 06h
        je spausdink_varda_push
        mov dx, offset c_POP
        mov ah, 9
        int 21h
        jmp sreg_next  
        
    spausdink_varda_push:
        mov dx, offset c_PUSH
        mov ah, 9
        int 21h    
    
    
    sreg_next:
    cmp sreg_part, 0h
        je sreg_bus_es
    cmp sreg_part, 80h
        je sreg_bus_cs
    cmp sreg_part, 10h
        je sreg_bus_ss  
        
    jmp sreg_bus_ds
    
    sreg_bus_es:
      mov bx, offset t_ES
      jmp spausdink_sreg 
    sreg_bus_cs:
      mov bx, offset t_CS
      jmp spausdink_sreg
    sreg_bus_ss:
      mov bx, offset t_SS
      jmp spausdink_sreg
    sreg_bus_ds:
      mov bx, offset t_DS
      jmp spausdink_sreg
      
    spausdink_sreg:
        mov ah,9
        mov dx, bx
        int 21h      
       
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
    
	mov ah,9
    mov dx, offset c_MOV
    int 21h
	cmp d_part, 0h
		je r_m_will_be_first
		jmp sreg_next2
	r_m_will_be_first:
		mov ah,9
		mov dx, offset sonk_
		int 21h
		mov al, byte ptr [secondByte]
		call spausdink_pagal_mod
		cmp mod_part, 0C0h
			je klausimas_del_sreg
		cmp mod_part, 0h 
			je klausimas_del_sreg
		cmp mod_part, 80h ;Checkiname kokio ilgio baitas bus (2)
		    mov ah,9
			mov dx, offset pliusas_
			int 21h
			je format7_poslinkis_2baitai_mov
            call getFirstByte
            mov byte ptr [thirdByte], al
            jmp format7_poslinkis_next
            
            format7_poslinkis_2baitai_mov:
                call getFirstByte
                mov byte ptr [thirdByte], al
                call getFirstByte
                mov byte ptr [Byte4], al
                call print_jaunesnyji_baita_hexu
                mov al, byte ptr [thirdByte]
                 
       format7_poslinkis_next:                      
           call print_vyresnyji_baita_hexu
		   mov ah,9
			mov dx, offset sond_
			int 21h
		   cmp d_part, 0h
		   je kablelis
		   jmp return_from_sreg_spausd2
    klausimas_del_sreg:
		cmp d_part, 0h
			je kablelis
			jmp return_from_sreg_spausd2
			kablelis:
			mov ah, 9
			mov dx, offset k_
			int 21h
    sreg_next2:
    cmp sreg_part, 0h
        je sreg_bus_es2
    cmp sreg_part, 80h
        je sreg_bus_cs2
    cmp sreg_part, 10h
        je sreg_bus_ss2 
        
    jmp sreg_bus_ds2
    
    sreg_bus_es2:
      mov bx, offset t_ES
      jmp spausdink_sreg2 
    sreg_bus_cs2:
      mov bx, offset t_CS
      jmp spausdink_sreg2
    sreg_bus_ss2:
      mov bx, offset t_SS
      jmp spausdink_sreg2
    sreg_bus_ds2:
      mov bx, offset t_DS
      jmp spausdink_sreg2
      
    spausdink_sreg2:
        mov ah,9
        mov dx, bx
        int 21h
		mov dx, offset k_
		int 21h
    
	cmp d_part, 0h
		jne r_m_will_be_first_temp
		
	jmp return_from_sreg_spausd2
		r_m_will_be_first_temp:
			jmp r_m_will_be_first
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
                    jle komanda_mov          
                    
    spausdink_varda_nr_next0:                
    cmp byte ptr[firstByte], 00h
        jge spausdink_varda_interval0
           jmp spausdink_varda_nr_next01
           spausdink_varda_interval0:
                cmp byte ptr[firstByte], 03h
                    jle komanda_add
                    
    spausdink_varda_nr_next01:                
    cmp byte ptr[firstByte], 28h
        jge spausdink_varda_interval01
           jmp spausdink_varda_nr_next02
           spausdink_varda_interval01:
                cmp byte ptr[firstByte], 2Bh
                    jle komanda_sub  
                    
    spausdink_varda_nr_next02:                
    cmp byte ptr[firstByte], 38h
        jge spausdink_varda_interval02
           jmp spausdink_varda_nr_next03
           spausdink_varda_interval02:
                cmp byte ptr[firstByte], 3Bh
                    jle komanda_cmp
                    
    spausdink_varda_nr_next03:                
    cmp byte ptr[firstByte], 0F6h
        jge spausdink_varda_interval03
           jmp spausdink_varda_nr_next04
           spausdink_varda_interval03:
                cmp byte ptr[firstByte], 0F7h
                    jle komanda_MUL_DIV 
                    
   spausdink_varda_nr_next04:
        cmp byte ptr[firstByte], 8Fh
              je komanda_pop
              
    spausdink_varda_nr_next05:                
    cmp byte ptr[firstByte], 0FEh
        jge spausdink_varda_interval05
           jmp spausdink_varda_nr_next
           spausdink_varda_interval05:
                cmp byte ptr[firstByte], 0FFh
                    jle komanda_PUSH_INC_DEC                                                                                                                                           
;-------------------------------------------------------------------------                                   
                                                              
    spausdink_varda_nr_next:                                                          
    ;spejam, kad cia INC (pirmas baitas is intervalo 40-47h)  
    cmp byte ptr[firstByte], 40h
    jb gal_komanda_pop
    cmp byte ptr[firstByte], 47h
    ja gal_komanda_pop
    
    komanda_inc: 
        mov bx, offset c_INC
        jmp vardo_spausdinimas 
    
    komanda_dec:
        mov bx, offset c_DEC
        jmp vardo_spausdinimas
    komanda_push:
        mov bx, offset c_PUSH  
        jmp vardo_spausdinimas
        
    komanda_mov:
        mov bx, offset c_MOV  
        jmp vardo_spausdinimas
        
    komanda_sub:
        mov bx, offset c_SUB  
        jmp vardo_spausdinimas
        
    komanda_add:
        mov bx, offset c_ADD  
        jmp vardo_spausdinimas
    komanda_cmp:
        mov bx, offset c_CMP  
        jmp vardo_spausdinimas
    komanda_pop:
        mov bx, offset c_POP
        jmp vardo_spausdinimas    
    komanda_PUSH_INC_DEC:
        cmp reg_part, 30h
            je komanda_push    
        cmp reg_part, 00h
            je komanda_inc
        jmp komanda_dec       
    komanda_MUL_DIV:
        cmp reg_part, 10h
            je komanda_MUL
            jmp komanda_DIV
            komanda_MUL:
                mov bx, offset c_MUL  
                jmp vardo_spausdinimas
            komanda_DIV:
                mov bx, offset c_DIV
                jmp vardo_spausdinimas    
                   
    gal_komanda_pop:
        cmp byte ptr[firstByte], 58h
        jb gal_komanda_int
        cmp byte ptr[firstByte], 5Fh
        ja gal_komanda_int
        ;vis tik cia POP
        mov bx, offset c_POP
        jmp vardo_spausdinimas

    gal_komanda_int:
        cmp byte ptr[firstByte], 0CDh
        jne returnfrom_vardo_spausd ;griztam is vardo spausdinimo, nes nepazistam komandos
        mov bx, offset c_INT

    vardo_spausdinimas:
        mov ah,9
        mov dx, bx
        int 21h       
    
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
        push ax
            and al, 11110000b
                mov cl, 4
                shr al, cl ;stumiam al bitus i desine per 4 vietas (prireike CL)
                            ;nes SHR antras operandas tik is aibes {1,CL}
                call print_hex_skaitmuo
        pop ax

        push ax
            and al, 00001111b
            call print_hex_skaitmuo
        pop ax

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
        push ax
            and al, 11110000b
                mov cl, 4
                shr al, cl ;stumiam al bitus i desine per 4 vietas (prireike CL)
                            ;nes SHR antras operandas tik is aibes {1,CL}
                call print_hex_skaitmuo
        pop ax

        push ax
            and al, 00001111b
            call print_hex_skaitmuo
        pop ax
        mov ah, 2
        mov dl, 'h'
        int 21h
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
            mov dl, '0' ;spausdina 0 priekyj
            mov ah, 2
            int 21h
        pop ax

        push ax
            and al, 11110000b
                mov cl, 4
                shr al, cl ;stumiam al bitus i desine per 4 vietas (prireike CL)
                            ;nes SHR antras operandas tik is aibes {1,CL}
                call print_hex_skaitmuo
        pop ax

        push ax
            and al, 00001111b
            call print_hex_skaitmuo
        pop ax

        mov ah, 2
        mov dl, 'h'
        int 21h
   pop dx
   pop cx
   pop bx
   pop ax
RET

print_hex_skaitmuo:
    push ax
    push dx
        and al, 00001111b  ;isvalom vyresni pusbaiti jis musu nedomins
        cmp al, 9
        ja print_hex_raidyte
        jmp print_hex_skaiciukas

        print_hex_raidyte:
        push ax
        sub al, 0Ah
        add al, 'A'
        mov ah, 2
        mov dl, al
        int 21h
        pop ax
        jmp grizti_is_pr_hex_sk

        print_hex_skaiciukas:
        push ax
        add al, 30h
        mov ah, 2
        mov dl, al
        int 21h
        pop ax
        jmp grizti_is_pr_hex_sk

    grizti_is_pr_hex_sk:
    pop dx
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
  klaidaAtidarantSkaitymui:
	;<klaidos pranešimo išvedimo kodas>
	JMP	pabaiga
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
                mov bx, offset r_AX
                jmp reg_w1_spausd

                reg_w1_001:
                mov bx, offset r_CX
                jmp reg_w1_spausd

                reg_w1_010:
                mov bx, offset r_DX
                jmp reg_w1_spausd

                reg_w1_011:
                mov bx, offset r_BX
                jmp reg_w1_spausd
                ;----
                reg_w1_100:
                mov bx, offset r_SP
                jmp reg_w1_spausd

                reg_w1_101:
                mov bx, offset r_BP
                jmp reg_w1_spausd

                reg_w1_110:
                mov bx, offset r_SI
                jmp reg_w1_spausd

                reg_w1_111:
                mov bx, offset r_DI
                jmp reg_w1_spausd

    reg_w1_spausd:
    mov ah, 9
    mov dx, bx
    int 21h

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
                mov bx, offset r_AL
                jmp reg_w0_spausd

                reg_w0_001:
                mov bx, offset r_CL
                jmp reg_w0_spausd

                reg_w0_010:
                mov bx, offset r_DL
                jmp reg_w0_spausd

                reg_w0_011:
                mov bx, offset r_BL
                jmp reg_w0_spausd
                ;----
                reg_w0_100:
                mov bx, offset r_AH
                jmp reg_w0_spausd

                reg_w0_101:
                mov bx, offset r_CH
                jmp reg_w0_spausd

                reg_w0_110:
                mov bx, offset r_DH
                jmp reg_w0_spausd

                reg_w0_111:
                mov bx, offset r_BH
                jmp reg_w0_spausd

    reg_w0_spausd:
    mov ah, 9
    mov dx, bx
    int 21h

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
                mov bx, offset r_AX
                jmp rm_w1_mod11_spausd

                rm_w1_mod11_001:
                mov bx, offset r_CX
                jmp rm_w1_mod11_spausd

                rm_w1_mod11_010:
                mov bx, offset r_DX
                jmp rm_w1_mod11_spausd

                rm_w1_mod11_011:
                mov bx, offset r_BX
                jmp rm_w1_mod11_spausd
                ;----
                rm_w1_mod11_100:
                mov bx, offset r_SP
                jmp rm_w1_mod11_spausd

                rm_w1_mod11_101:
                mov bx, offset r_BP
                jmp rm_w1_mod11_spausd

                rm_w1_mod11_110:
                mov bx, offset r_SI
                jmp rm_w1_mod11_spausd

                rm_w1_mod11_111:
                mov bx, offset r_DI
                jmp rm_w1_mod11_spausd

    rm_w1_mod11_spausd:
    mov ah, 9
    mov dx, bx
    int 21h

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
                mov bx, offset r_AL
                jmp rm_w0_mod11_spausd

                rm_w0_mod11_001:
                mov bx, offset r_CL
                jmp rm_w0_mod11_spausd

                rm_w0_mod11_010:
                mov bx, offset r_DL
                jmp rm_w0_mod11_spausd

                rm_w0_mod11_011:
                mov bx, offset r_BL
                jmp rm_w0_mod11_spausd
                ;----
                rm_w0_mod11_100:
                mov bx, offset r_AH
                jmp rm_w0_mod11_spausd

                rm_w0_mod11_101:
                mov bx, offset r_CH
                jmp rm_w0_mod11_spausd

                rm_w0_mod11_110:
                mov bx, offset r_DH
                jmp rm_w0_mod11_spausd

                rm_w0_mod11_111:
                mov bx, offset r_BH
                jmp rm_w0_mod11_spausd

    rm_w0_mod11_spausd:
    mov ah, 9
    mov dx, bx
    int 21h

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
                mov bx, offset ea_rm000
                jmp rm_mod00_spausd

                rm_mod00_001:
                mov bx, offset ea_rm001
                jmp rm_mod00_spausd

                rm_mod00_010:
                mov bx, offset ea_rm010
                jmp rm_mod00_spausd

                rm_mod00_011:
                mov bx, offset ea_rm011
                jmp rm_mod00_spausd
                ;----
                rm_mod00_100:
                mov bx, offset ea_rm100
                jmp rm_mod00_spausd

                rm_mod00_101:
                mov bx, offset ea_rm101
                jmp rm_mod00_spausd

                rm_mod00_110:
                mov bx, offset ea_rm110 ;****** CIA TURI BUTI TIESIOGINIS ADRESAS
                jmp rm_mod00_spausd

                rm_mod00_111:
                mov bx, offset ea_rm111
                jmp rm_mod00_spausd

    rm_mod00_spausd:
    mov ah, 9
    mov dx, bx
    int 21h

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
                mov bx, offset ea_rm000
                jmp rm_mod01_spausd

                rm_mod01_001:
                mov bx, offset ea_rm001
                jmp rm_mod01_spausd

                rm_mod01_010:
                mov bx, offset ea_rm010
                jmp rm_mod01_spausd

                rm_mod01_011:
                mov bx, offset ea_rm011
                jmp rm_mod01_spausd
                ;----
                rm_mod01_100:
                mov bx, offset ea_rm100
                jmp rm_mod01_spausd

                rm_mod01_101:
                mov bx, offset ea_rm101
                jmp rm_mod01_spausd

                rm_mod01_110:
                mov bx, offset ea_rm110 ;****** CIA TURI BUTI TIESIOGINIS ADRESAS
                jmp rm_mod01_spausd

                rm_mod01_111:
                mov bx, offset ea_rm111
                jmp rm_mod01_spausd

    rm_mod01_spausd:
    mov ah, 9
    mov dx, bx
    int 21h

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
                mov bx, offset ea_rm000
                jmp rm_mod10_spausd

                rm_mod10_001:
                mov bx, offset ea_rm001
                jmp rm_mod10_spausd

                rm_mod10_010:
                mov bx, offset ea_rm010
                jmp rm_mod10_spausd

                rm_mod10_011:
                mov bx, offset ea_rm011
                jmp rm_mod10_spausd
                ;----
                rm_mod10_100:
                mov bx, offset ea_rm100
                jmp rm_mod10_spausd

                rm_mod10_101:
                mov bx, offset ea_rm101
                jmp rm_mod10_spausd

                rm_mod10_110:
                mov bx, offset ea_rm110 ;****** CIA TURI BUTI TIESIOGINIS ADRESAS
                jmp rm_mod10_spausd

                rm_mod10_111:
                mov bx, offset ea_rm111
                jmp rm_mod10_spausd

    rm_mod10_spausd:
    mov ah, 9
    mov dx, bx
    int 21h

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
 mov al, byte ptr[firstByte]
 
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

;**********************************************************************************************************************
;------------------------------------------------------------------------------------------------------

spausdink_mov:
	mov [di], 'M'
	inc di
	mov [di], 'O'
	inc di
	mov [di], 'V'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_add:
	mov [di], 'A'
	inc di
	mov [di], 'D'
	inc di
	mov [di], 'D'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_inc:
	mov [di], 'I'
	inc di
	mov [di], 'N'
	inc di
	mov [di], 'C'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_dec:
	mov [di], 'D'
	inc di
	mov [di], 'E'
	inc di
	mov [di], 'C'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_pop:
	mov [di], 'P'
	inc di
	mov [di], 'O'
	inc di
	mov [di], 'P'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_push:
	mov [di], 'P'
	inc di
	mov [di], 'U'
	inc di
	mov [di], 'S'
	inc di
	mov [di], 'H'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_int:
	mov [di], 'I'
	inc di
	mov [di], 'N'
	inc di
	mov [di], 'T'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_sub:
	mov [di], 'S'
	inc di
	mov [di], 'U'
	inc di
	mov [di], 'B'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_cmp:
	mov [di], 'C'
	inc di
	mov [di], 'M'
	inc di
	mov [di], 'P'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_mul:
	mov [di], 'M'
	inc di
	mov [di], 'U'
	inc di
	mov [di], 'L'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_div:
	mov [di], 'D'
	inc di
	mov [di], 'I'
	inc di
	mov [di], 'V'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_call:
	mov [di], 'C'
	inc di
	mov [di], 'A'
	inc di
	mov [di], 'L'
	inc di
	mov [di], 'L'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_ret:
	mov [di], 'R'
	inc di
	mov [di], 'E'
	inc di
	mov [di], 'T'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_loop:
	mov [di], 'L'
	inc di
	mov [di], 'O'
	inc di
	mov [di], 'O'
	inc di
	mov [di], 'P'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jmp:
	mov [di], 'J'
	inc di
	mov [di], 'M'
	inc di
	mov [di], 'P'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jo:
	mov [di], 'J'
	inc di
	mov [di], 'O'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jno:
	mov [di], 'J'
	inc di
	mov [di], 'O'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jnae:
	mov [di], 'J'
	inc di
	mov [di], 'N'
	inc di
	mov [di], 'A'
	inc di
	mov [di], 'E'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jae:
	mov [di], 'J'
	inc di
	mov [di], 'A'
	inc di
	mov [di], 'E'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_je:
	mov [di], 'J'
	inc di
	mov [di], 'E'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jne:
	mov [di], 'J'
	inc di
	mov [di], 'N'
	inc di
	mov [di], 'E'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jbe:
	mov [di], 'J'
	inc di
	mov [di], 'B'
	inc di
	mov [di], 'E'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_ja:
	mov [di], 'J'
	inc di
	mov [di], 'A'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_js:
	mov [di], 'J'
	inc di
	mov [di], 'S'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jns:
	mov [di], 'J'
	inc di
	mov [di], 'N'
	inc di
	mov [di], 'S'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jp:
	mov [di], 'J'
	inc di
	mov [di], 'P'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jnp:
	mov [di], 'J'
	inc di
	mov [di], 'N'
	inc di
	mov [di], 'P'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jl:
	mov [di], 'J'
	inc di
	mov [di], 'L'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jge:
	mov [di], 'J'
	inc di
	mov [di], 'G'
	inc di
	mov [di], 'E'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jle:
	mov [di], 'J'
	inc di
	mov [di], 'L'
	inc di
	mov [di], 'E'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_jg:
	mov [di], 'J'
	inc di
	mov [di], 'G'
	inc di
	mov [di], ' '
	inc di
ret

spausdink_ea_rm_000:
	mov [di], 'b'
	inc di
	mov [di], 'x'
	inc di
	mov [di], '+'
	inc di
	mov [di], 's'
	inc di
	mov [di], 'i'
	inc di
ret

spausdink_ea_rm_001:
	mov [di], 'b'
	inc di
	mov [di], 'x'
	inc di
	mov [di], '+'
	inc di
	mov [di], 'd'
	inc di
	mov [di], 'i'
	inc di
ret

spausdink_ea_rm_010:
	mov [di], 'b'
	inc di
	mov [di], 'p'
	inc di
	mov [di], '+'
	inc di
	mov [di], 's'
	inc di
	mov [di], 'i'
	inc di
ret

spausdink_ea_rm_011:
	mov [di], 'b'
	inc di
	mov [di], 'p'
	inc di
	mov [di], '+'
	inc di
	mov [di], 'd'
	inc di
	mov [di], 'i'
	inc di
ret

spausdink_ea_rm_100:
	mov [di], 's'
	inc di
	mov [di], 'i'
	inc di
ret

spausdink_ea_rm_101:
	mov [di], 'd'
	inc di
	mov [di], 'i'
	inc di
ret

spausdink_ea_rm_110:
	mov [di], 'b'
	inc di
	mov [di], 'p'
	inc di
ret

spausdink_ea_rm_111:
	mov [di], 'b'
	inc di
	mov [di], 'x'
	inc di
ret

spausdink_es:
	mov [di], 'e'
	inc di
	mov [di], 's'
	inc di
ret

spausdink_cs:
	mov [di], 'c'
	inc di
	mov [di], 's'
	inc di
ret

spausdink_ss:
	mov [di], 's'
	inc di
	mov [di], 's'
	inc di
ret

spausdink_ds:
	mov [di], 'd'
	inc di
	mov [di], 's'
	inc di
ret

spausdink_ax:
	mov [di], 'a'
	inc di
	mov [di], 'x'
	inc di
ret

spausdink_al:
	mov [di], 'a'
	inc di
	mov [di], 'h'
	inc di
ret

spausdink_ah:
	mov [di], 'a'
	inc di
	mov [di], 'h'
	inc di
ret

spausdink_cx:
	mov [di], 'c'
	inc di
	mov [di], 'x'
	inc di
ret

spausdink_cl:
	mov [di], 'c'
	inc di
	mov [di], 'l'
	inc di
ret

spausdink_ch:
	mov [di], 'c'
	inc di
	mov [di], 'h'
	inc di
ret

spausdink_dx:
	mov [di], 'd'
	inc di
	mov [di], 'x'
	inc di
ret

spausdink_dl:
	mov [di], 'd'
	inc di
	mov [di], 'l'
	inc di
ret

spausdink_dh:
	mov [di], 'd'
	inc di
	mov [di], 'h'
	inc di
ret

spausdink_bx:
	mov [di], 'b'
	inc di
	mov [di], 'x'
	inc di
ret

spausdink_bl:
	mov [di], 'b'
	inc di
	mov [di], 'l'
	inc di
ret

spausdink_bh:
	mov [di], 'b'
	inc di
	mov [di], 'h'
	inc di
ret

spausdink_sp:
	mov [di], 's'
	inc di
	mov [di], 'p'
	inc di
ret

spausdink_bp:
	mov [di], 'b'
	inc di
	mov [di], 'p'
	inc di
ret

spausdink_si:
	mov [di], 's'
	inc di
	mov [di], 'i'
	inc di
ret

spausdink_di:
	mov [di], 'd'
	inc di
	mov [di], 'i'
	inc di
ret

spausdink_k:
	mov [di], ','
	inc di
	mov [di], ' '
	inc di
ret

spausdink_sond:
	mov [di], ']'
	inc di
ret
spausdink_sonk:
	mov [di], '['
	inc di
ret

spausdink_dvi:
	mov [di], ':'
	inc di
ret
;**********************************************************************************************************************
;------------------------------------------------------------------------------------------------------

exit:
    mov ah, 9
    mov dx, offset enteris
    int 21h

    mov ah, 4Ch
    int 21h



END pradzia                