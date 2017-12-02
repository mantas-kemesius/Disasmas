;***************************************************************
; Programa atidaranti failą duom.txt, pakeičianti mažąsias raides didžiosiomis ir rezultatą įrašanti į failą rez.txt
;***************************************************************
.model small
skBufDydis	EQU 1			;konstanta skBufDydis (lygi 20) - skaitymo buferio dydis
raBufDydis	EQU 1			;konstanta raBufDydis (lygi 20) - rašymo buferio dydis
.stack 100h
.data
	duom	db "duom.txt",0		;duomenų failo pavadinimas, pasibaigiantis nuliniu simboliu (C sintakse - '\0')
	rez	db "rez.txt",0		;rezultatų failo pavadinimas, pasibaigiantis nuliniu simboliu
	skBuf	db skBufDydis dup (?)	;skaitymo buferis
	raBuf	db raBufDydis dup (?)	;rašymo buferis
	dFail	dw ?			;vieta, skirta saugoti duomenų failo deskriptoriaus numerį ("handle")
	rFail	dw ?			;vieta, skirta saugoti rezultato failo deskriptoriaus numerį
.code
  pradzia:
	MOV	ax, @data		;reikalinga kiekvienos programos pradzioj
	MOV	ds, ax			;reikalinga kiekvienos programos pradzioj

;*****************************************************
;Duomenų failo atidarymas skaitymui
;*****************************************************
	MOV	ah, 3Dh				;21h pertraukimo failo atidarymo funkcijos numeris
	MOV	al, 00				;00 - failas atidaromas skaitymui
	MOV	dx, offset duom			;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
	INT	21h				;failas atidaromas skaitymui
	JC	klaidaAtidarantSkaitymui	;jei atidarant failą skaitymui įvyksta klaida, nustatomas carry flag
	MOV	dFail, ax			;atmintyje išsisaugom duomenų failo deskriptoriaus numerį

;*****************************************************
;Rezultato failo sukūrimas ir atidarymas rašymui
;*****************************************************
	MOV	ah, 3Ch				;21h pertraukimo failo sukūrimo funkcijos numeris
	MOV	cx, 0				;kuriamo failo atributai
	MOV	dx, offset rez			;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
	INT	21h				;sukuriamas failas; jei failas jau egzistuoja, visa jo informacija ištrinama
	JC	klaidaAtidarantRasymui		;jei kuriant failą skaitymui įvyksta klaida, nustatomas carry flag
	MOV	rFail, ax			;atmintyje išsisaugom rezultato failo deskriptoriaus numerį

;*****************************************************
;Duomenų nuskaitymas iš failo
;*****************************************************
  skaityk:
	MOV	bx, dFail			;į bx įrašom duomenų failo deskriptoriaus numerį
	CALL	SkaitykBuf			;iškviečiame skaitymo iš failo procedūrą
	CMP	ax, 0				;ax įrašoma, kiek baitų buvo nuskaityta, jeigu 0 - pasiekta failo pabaiga
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
;Rezultato įrašymas į failą
;*****************************************************
	MOV	cx, ax				;cx - kiek baitų reikia įrašyti
	MOV	bx, rFail			;į bx įrašom rezultato failo deskriptoriaus numerį
	CALL	RasykBuf			;iškviečiame rašymo į failą procedūrą
	CMP	ax, raBufDydis			;jeigu vyko darbas su pilnu buferiu -> iš duomenų failo buvo nuskaitytas pilnas buferis ->
	JE	skaityk				;-> reikia skaityti toliau
  
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
	MOV	cl, skBufDydis		;cx - kiek baitų reikia nuskaityti iš failo
	MOV	ch, 0			;išvalom vyresnįjį cx baitą
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
	
	MOV	ah, 40h			;21h pertraukimo duomenų įrašymo funkcijos numeris
	MOV	dx, offset raBuf	;vieta, iš kurios rašom į failą
	INT	21h			;rašymas į failą
	JC	klaidaRasant		;jei rašant į failą įvyksta klaida, nustatomas carry flag
	CMP	cx, ax			;jei cx nelygus ax, vadinasi buvo įrašyta tik dalis informacijos
	JNE	dalinisIrasymas

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
END pradzia