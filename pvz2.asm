;***************************************************************
; Programa atidaranti fail� duom.txt, pakei�ianti ma��sias raides did�iosiomis ir rezultat� �ra�anti � fail� rez.txt
;***************************************************************
.model small
skBufDydis	EQU 20			;konstanta skBufDydis (lygi 20) - skaitymo buferio dydis
raBufDydis	EQU 20			;konstanta raBufDydis (lygi 20) - ra�ymo buferio dydis
.stack 100h
.data
	duom	db "1.asm",0		;duomen� failo pavadinimas, pasibaigiantis nuliniu simboliu (C sintakse - '\0')
	rez	db "rez.txt",0		;rezultat� failo pavadinimas, pasibaigiantis nuliniu simboliu
	skBuf	db skBufDydis dup (?)	;skaitymo buferis
	raBuf	db raBufDydis dup (?)	;ra�ymo buferis
	dFail	dw ?			;vieta, skirta saugoti duomen� failo deskriptoriaus numer� ("handle")
	rFail	dw ?			;vieta, skirta saugoti rezultato failo deskriptoriaus numer�
.code
  pradzia:
	MOV	ax, @data		;reikalinga kiekvienos programos pradzioj
	MOV	ds, ax			;reikalinga kiekvienos programos pradzioj

;***********uosis******************************************
;Duomen� failo atidarymas skaitymui
;*****************************************************
	MOV	ah, 3Dh				;21h pertraukimo failo atidarymo funkcijos numeris
	MOV	al, 00				;00 - failas atidaromas skaitymui
	MOV	dx, offset duom			;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
	INT	21h				;failas atidaromas skaitymui
	JC	klaidaAtidarantSkaitymui	;jei atidarant fail� skaitymui �vyksta klaida, nustatomas carry flag
	MOV	dFail, ax			;atmintyje i�sisaugom duomen� failo deskriptoriaus numer�

;*****************************************************
;Rezultato failo suk�rimas ir atidarymas ra�ymui
;*****************************************************
	MOV	ah, 3Ch				;21h pertraukimo failo suk�rimo funkcijos numeris
	MOV	cx, 0				;kuriamo failo atributai
	MOV	dx, offset rez			;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
	INT	21h				;sukuriamas failas; jei failas jau egzistuoja, visa jo informacija i�trinama
	JC	klaidaAtidarantRasymui		;jei kuriant fail� skaitymui �vyksta klaida, nustatomas carry flag
	MOV	rFail, ax			;atmintyje i�sisaugom rezultato failo deskriptoriaus numer�

;*****************************************************
;Duomen� nuskaitymas i� failo
;*****************************************************
  skaityk:
	MOV	bx, dFail			;� bx �ra�om duomen� failo deskriptoriaus numer�
	CALL	SkaitykBuf			;i�kvie�iame skaitymo i� failo proced�r�
	CMP	ax, 0				;ax �ra�oma, kiek bait� buvo nuskaityta, jeigu 0 - pasiekta failo pabaiga
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
;Rezultato �ra�ymas � fail�
;*****************************************************
	MOV	cx, ax				;cx - kiek bait� reikia �ra�yti
	MOV	bx, rFail			;� bx �ra�om rezultato failo deskriptoriaus numer�
	CALL	RasykBuf			;i�kvie�iame ra�ymo � fail� proced�r�
	CMP	ax, skBufDydis			;jeigu vyko darbas su pilnu buferiu -> i� duomen� failo buvo nuskaitytas pilnas buferis ->
	JE	skaityk				;-> reikia skaityti toliau
  
;*****************************************************
;Rezultato failo u�darymas
;*****************************************************
  uzdarytiRasymui:
	MOV	ah, 3Eh				;21h pertraukimo failo u�darymo funkcijos numeris
	MOV	bx, rFail			;� bx �ra�om rezultato failo deskriptoriaus numer�
	INT	21h				;failo u�darymas
	JC	klaidaUzdarantRasymui		;jei u�darant fail� �vyksta klaida, nustatomas carry flag
	
;*****************************************************
;Duomen� failo u�darymas
;*****************************************************
  uzdarytiSkaitymui:
	MOV	ah, 3Eh				;21h pertraukimo failo u�darymo funkcijos numeris
	MOV	bx, dFail			;� bx �ra�om duomen� failo deskriptoriaus numer�
	INT	21h				;failo u�darymas
	JC	klaidaUzdarantSkaitymui		;jei u�darant fail� �vyksta klaida, nustatomas carry flag

  pabaiga:
	MOV	ah, 4Ch				;reikalinga kiekvienos programos pabaigoj
	MOV	al, 0				;reikalinga kiekvienos programos pabaigoj
	INT	21h				;reikalinga kiekvienos programos pabaigoj

;*****************************************************
;Klaid� apdorojimas
;*****************************************************
  klaidaAtidarantSkaitymui:
	;<klaidos prane�imo i�vedimo kodas>
	JMP	pabaiga
  klaidaAtidarantRasymui:
	;<klaidos prane�imo i�vedimo kodas>
	JMP	uzdarytiSkaitymui
  klaidaUzdarantRasymui:
	;<klaidos prane�imo i�vedimo kodas>
	JMP	uzdarytiSkaitymui
  klaidaUzdarantSkaitymui:
	;<klaidos prane�imo i�vedimo kodas>
	JMP	pabaiga

;*****************************************************
;Proced�ra nuskaitanti informacij� i� failo
;*****************************************************
PROC SkaitykBuf
;� BX paduodamas failo deskriptoriaus numeris
;� AX bus gr��inta, kiek simboli� nuskaityta
	PUSH	cx
	PUSH	dx
	
	MOV	ah, 3Fh			;21h pertraukimo duomen� nuskaitymo funkcijos numeris
	MOV	cx, skBufDydis		;cx - kiek bait� reikia nuskaityti i� failo
	MOV	dx, offset skBuf	;vieta, � kuri� �ra�oma nuskaityta informacija
	INT	21h			;skaitymas i� failo
	JC	klaidaSkaitant		;jei skaitant i� failo �vyksta klaida, nustatomas carry flag

  SkaitykBufPabaiga:
	POP	dx
	POP	cx
	RET

  klaidaSkaitant:
	;<klaidos prane�imo i�vedimo kodas>
	MOV ax, 0			;Pa�ymime registre ax, kad nebuvo nuskaityta n� vieno simbolio
	JMP	SkaitykBufPabaiga
SkaitykBuf ENDP

;*****************************************************
;Proced�ra, �ra�anti bufer� � fail�
;*****************************************************
PROC RasykBuf
;� BX paduodamas failo deskriptoriaus numeris
;� CX - kiek bait� �ra�yti
;� AX bus gr��inta, kiek bait� buvo �ra�yta
	PUSH	dx
	
	MOV	ah, 40h			;21h pertraukimo duomen� �ra�ymo funkcijos numeris
	MOV	dx, offset raBuf	;vieta, i� kurios ra�om � fail�
	INT	21h			;ra�ymas � fail�
	JC	klaidaRasant		;jei ra�ant � fail� �vyksta klaida, nustatomas carry flag
	CMP	cx, ax			;jei cx nelygus ax, vadinasi buvo �ra�yta tik dalis informacijos
	JNE	dalinisIrasymas

  RasykBufPabaiga:
	POP	dx
	RET

  dalinisIrasymas:
	;<klaidos prane�imo i�vedimo kodas>
	JMP	RasykBufPabaiga
  klaidaRasant:
	;<klaidos prane�imo i�vedimo kodas>
	MOV	ax, 0			;Pa�ymime registre ax, kad nebuvo �ra�ytas n� vienas simbolis
	JMP	RasykBufPabaiga
RasykBuf ENDP	
END pradzia