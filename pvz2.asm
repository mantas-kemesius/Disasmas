;***************************************************************
; Programa atidaranti failà duom.txt, pakeièianti maþàsias raides didþiosiomis ir rezultatà áraðanti á failà rez.txt
;***************************************************************
.model small
skBufDydis	EQU 20			;konstanta skBufDydis (lygi 20) - skaitymo buferio dydis
raBufDydis	EQU 20			;konstanta raBufDydis (lygi 20) - raðymo buferio dydis
.stack 100h
.data
	duom	db "1.asm",0		;duomenø failo pavadinimas, pasibaigiantis nuliniu simboliu (C sintakse - '\0')
	rez	db "rez.txt",0		;rezultatø failo pavadinimas, pasibaigiantis nuliniu simboliu
	skBuf	db skBufDydis dup (?)	;skaitymo buferis
	raBuf	db raBufDydis dup (?)	;raðymo buferis
	dFail	dw ?			;vieta, skirta saugoti duomenø failo deskriptoriaus numerá ("handle")
	rFail	dw ?			;vieta, skirta saugoti rezultato failo deskriptoriaus numerá
.code
  pradzia:
	MOV	ax, @data		;reikalinga kiekvienos programos pradzioj
	MOV	ds, ax			;reikalinga kiekvienos programos pradzioj

;***********uosis******************************************
;Duomenø failo atidarymas skaitymui
;*****************************************************
	MOV	ah, 3Dh				;21h pertraukimo failo atidarymo funkcijos numeris
	MOV	al, 00				;00 - failas atidaromas skaitymui
	MOV	dx, offset duom			;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
	INT	21h				;failas atidaromas skaitymui
	JC	klaidaAtidarantSkaitymui	;jei atidarant failà skaitymui ávyksta klaida, nustatomas carry flag
	MOV	dFail, ax			;atmintyje iðsisaugom duomenø failo deskriptoriaus numerá

;*****************************************************
;Rezultato failo sukûrimas ir atidarymas raðymui
;*****************************************************
	MOV	ah, 3Ch				;21h pertraukimo failo sukûrimo funkcijos numeris
	MOV	cx, 0				;kuriamo failo atributai
	MOV	dx, offset rez			;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
	INT	21h				;sukuriamas failas; jei failas jau egzistuoja, visa jo informacija iðtrinama
	JC	klaidaAtidarantRasymui		;jei kuriant failà skaitymui ávyksta klaida, nustatomas carry flag
	MOV	rFail, ax			;atmintyje iðsisaugom rezultato failo deskriptoriaus numerá

;*****************************************************
;Duomenø nuskaitymas ið failo
;*****************************************************
  skaityk:
	MOV	bx, dFail			;á bx áraðom duomenø failo deskriptoriaus numerá
	CALL	SkaitykBuf			;iðkvieèiame skaitymo ið failo procedûrà
	CMP	ax, 0				;ax áraðoma, kiek baitø buvo nuskaityta, jeigu 0 - pasiekta failo pabaiga
	JE	uzdarytiRasymui

;*****************************************************
;Darbas su nuskaityta informacija
;*****************************************************
	MOV	cx, ax
	MOV	si, offset skBuf
	MOV	di, offset raBuf
  dirbk:
	MOV	dl, [si]
	CMP dl, 'a'
	JB	tesk
	CMP dl, 'z'
	JA	tesk
	SUB dl, 20h
  tesk:
	MOV	[di], dl
	INC	si
	INC	di
	LOOP	dirbk
	
;*****************************************************
;Rezultato áraðymas á failà
;*****************************************************
	MOV	cx, ax				;cx - kiek baitø reikia áraðyti
	MOV	bx, rFail			;á bx áraðom rezultato failo deskriptoriaus numerá
	CALL	RasykBuf			;iðkvieèiame raðymo á failà procedûrà
	CMP	ax, skBufDydis			;jeigu vyko darbas su pilnu buferiu -> ið duomenø failo buvo nuskaitytas pilnas buferis ->
	JE	skaityk				;-> reikia skaityti toliau
  
;*****************************************************
;Rezultato failo uþdarymas
;*****************************************************
  uzdarytiRasymui:
	MOV	ah, 3Eh				;21h pertraukimo failo uþdarymo funkcijos numeris
	MOV	bx, rFail			;á bx áraðom rezultato failo deskriptoriaus numerá
	INT	21h				;failo uþdarymas
	JC	klaidaUzdarantRasymui		;jei uþdarant failà ávyksta klaida, nustatomas carry flag
	
;*****************************************************
;Duomenø failo uþdarymas
;*****************************************************
  uzdarytiSkaitymui:
	MOV	ah, 3Eh				;21h pertraukimo failo uþdarymo funkcijos numeris
	MOV	bx, dFail			;á bx áraðom duomenø failo deskriptoriaus numerá
	INT	21h				;failo uþdarymas
	JC	klaidaUzdarantSkaitymui		;jei uþdarant failà ávyksta klaida, nustatomas carry flag

  pabaiga:
	MOV	ah, 4Ch				;reikalinga kiekvienos programos pabaigoj
	MOV	al, 0				;reikalinga kiekvienos programos pabaigoj
	INT	21h				;reikalinga kiekvienos programos pabaigoj

;*****************************************************
;Klaidø apdorojimas
;*****************************************************
  klaidaAtidarantSkaitymui:
	;<klaidos praneðimo iðvedimo kodas>
	JMP	pabaiga
  klaidaAtidarantRasymui:
	;<klaidos praneðimo iðvedimo kodas>
	JMP	uzdarytiSkaitymui
  klaidaUzdarantRasymui:
	;<klaidos praneðimo iðvedimo kodas>
	JMP	uzdarytiSkaitymui
  klaidaUzdarantSkaitymui:
	;<klaidos praneðimo iðvedimo kodas>
	JMP	pabaiga

;*****************************************************
;Procedûra nuskaitanti informacijà ið failo
;*****************************************************
PROC SkaitykBuf
;á BX paduodamas failo deskriptoriaus numeris
;á AX bus gràþinta, kiek simboliø nuskaityta
	PUSH	cx
	PUSH	dx
	
	MOV	ah, 3Fh			;21h pertraukimo duomenø nuskaitymo funkcijos numeris
	MOV	cx, skBufDydis		;cx - kiek baitø reikia nuskaityti ið failo
	MOV	dx, offset skBuf	;vieta, á kurià áraðoma nuskaityta informacija
	INT	21h			;skaitymas ið failo
	JC	klaidaSkaitant		;jei skaitant ið failo ávyksta klaida, nustatomas carry flag

  SkaitykBufPabaiga:
	POP	dx
	POP	cx
	RET

  klaidaSkaitant:
	;<klaidos praneðimo iðvedimo kodas>
	MOV ax, 0			;Paþymime registre ax, kad nebuvo nuskaityta në vieno simbolio
	JMP	SkaitykBufPabaiga
SkaitykBuf ENDP

;*****************************************************
;Procedûra, áraðanti buferá á failà
;*****************************************************
PROC RasykBuf
;á BX paduodamas failo deskriptoriaus numeris
;á CX - kiek baitø áraðyti
;á AX bus gràþinta, kiek baitø buvo áraðyta
	PUSH	dx
	
	MOV	ah, 40h			;21h pertraukimo duomenø áraðymo funkcijos numeris
	MOV	dx, offset raBuf	;vieta, ið kurios raðom á failà
	INT	21h			;raðymas á failà
	JC	klaidaRasant		;jei raðant á failà ávyksta klaida, nustatomas carry flag
	CMP	cx, ax			;jei cx nelygus ax, vadinasi buvo áraðyta tik dalis informacijos
	JNE	dalinisIrasymas

  RasykBufPabaiga:
	POP	dx
	RET

  dalinisIrasymas:
	;<klaidos praneðimo iðvedimo kodas>
	JMP	RasykBufPabaiga
  klaidaRasant:
	;<klaidos praneðimo iðvedimo kodas>
	MOV	ax, 0			;Paþymime registre ax, kad nebuvo áraðytas në vienas simbolis
	JMP	RasykBufPabaiga
RasykBuf ENDP	
END pradzia