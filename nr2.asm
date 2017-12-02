
.model small
skBufDydis    EQU 100
sk2BufDydis    EQU 100
raBufDydis    EQU 100

duom1Dydis EQU 100
.stack 100h

.data
;duom db "duom.txt", 0
duom db 50 dup (?)
filehandle dw ?
kiek dw 0
temp dw 0
p dw 0
a dw 0
sek dw 0
counter dw 0
bituKiekis dw 0

min dw 0
max dw 0
kiekCX dw 0
	bxSave	dw 0082h
duom2   db "duom2.txt", 0
rez    db "rez.txt", 0
skBuf    db skBufDydis dup (?)
skBuf2    db sk2BufDydis dup (?)
raBuf    db raBufDydis dup (?)
dFail    dw ?
d2Fail    dw ?
rFail    dw ?
help    db "II atsiskaitomasis darbas, X variantas.",10,13, "Sia uzduoti atliko Mantas Kemesius VU MIF PS II k. 6gr.$"

.code
pradzia:
MOV    ax, @data
MOV    ds, ax
MOV bp, 0

MOV ch, 0
		MOV cl, [es:0080h]  ;programos paleidimo parametru simboliu skaicius yra rasome 80h baite
		CMP cx, 0           ; jei nera paleidimo parametru, programa veikia normaliai
		JNE helpParam
		JMP pabaiga
	helpParam:		



		MOV bx, 0081h		
	ieskokHelp:

		CMP [es:bx], '?/'   
		JE Yra              

		INC bx				
		LOOP ieskokHelp
		JMP neraHelp


	Yra:
		MOV ah, 9
		MOV dx, offset help
		INT 21h
		
		MOV	ah, 4Ch		
		MOV	al, 0		
		INT	21h			

	neraHelp:




		;MOV di, 0
		MOV cx, [es:0080h] ;kiek skaiciu parametras
		MOV kiekCX, cx
	failoParam:

		MOV si, offset duom
		MOV BX, bxSave
		MOV cx, kiekCX
		CMP cx, 0
		JNE ieskokFailo
	;endProg:	 

	;	MOV 	AH, 4Ch;
	;	INT	    21h;
	ieskokFailo:
		MOV dl, Byte ptr[ES:BX]
		CMP dl, 20h
		JE yraFailas
		CMP dl, 13
		JE yraFailap
		INC bx
		MOV byte ptr [si], dl
		INC si
	LOOP ieskokFailo
	
	yraFailap:
		MOV		CX, 0
		MOV		kiekCX, CX
		
	yraFailas:
		INC si
		MOV byte ptr [si], 0
		INC bx
		MOV bxSave, bx
		MOV kiekCX, cx
		MOV dx, offset duom
		


;rez.txt atidarymas ir rasymas i faila
reza:
;duom.txt failo atidarymas
MOV    ah, 3Dh                ;21h pertraukimo failo atidarymo funkcijos numeris
MOV    al, 00                ;00 - failas atidaromas skaitymui
;MOV    dx, offset duom            ;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
INT    21h                ;failas atidaromas skaitymui
MOV    dFail, ax            ;atmintyje i?sisaugom duomen? failo deskriptoriaus numer?

MOV    ah, 3Ch                ;21h pertraukimo failo suk?rimo funkcijos numeris
MOV    cx, 0                ;kuriamo failo atributai
MOV    dx, offset rez            ;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
INT    21h                ;sukuriamas failas; jei failas jau egzistuoja, visa jo informacija i?trinama
MOV    rFail, ax            ;atmintyje i?sisaugom rezultato failo deskriptoriaus numer?


;Skaitymas is failo

skaityk:
MOV    bx, dFail            ;? bx ?ra?om duomen? failo deskriptoriaus numer?
CALL    SkaitykBuf            ;i?kvie?iame skaitymo i? failo proced?r?
CMP    ax, 0                ;ax ?ra?oma, kiek bait? buvo nuskaityta, jeigu 0 - pasiekta failo pabaiga
JE    atidarymas

;Atliekami darbai su nuskaityta medziaga

MOV    cx, ax
MOV    si, offset skBuf
;MOV    di, offset raBuf
dirbk:
MOV    dl, [si]
PUSH dx
inc bp
CMP dl, 'a'
JB    tesk
CMP dl, 'z'
JA    tesk
SUB dl, 20h
tesk:
;MOV    [di], dl
INC    si
;INC    di
LOOP dirbk

atidarymas:
;push bp
mov kiek, 0
MOV    ah, 3Dh                ;21h pertraukimo failo atidarymo funkcijos numeris
MOV    al, 00                ;00 - failas atidaromas skaitymui
MOV    dx, offset duom2            ;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
INT    21h                ;failas atidaromas skaitymui
JC    klaidaAtidarantSkaitymui    ;jei atidarant fail? skaitymui ?vyksta klaida, nustatomas carry flag
MOV    d2Fail, ax            ;atmintyje i?sisaugom duomen? failo deskriptoriaus numer?

skaityk2:

MOV    bx, d2Fail            ;? bx ?ra?om duomen? failo deskriptoriaus numer?
CALL    SkaitykBuf2            ;i?kvie?iame skaitymo i? failo proced?r?
CMP    ax, 0                ;ax ?ra?oma, kiek bait? buvo nuskaityta, jeigu 0 - pasiekta failo pabaiga
JE    uzdarytiRasymui
jmp Pradeti

;Atliekami darbai su nuskaityta medziaga

;klaidu apdorojimas

klaidaAtidarantSkaitymui:
JMP    pabaiga

klaidaAtidarantRasymui:
JMP    uzdarytiSkaitymui

klaidaUzdarantRasymui:
JMP    uzdarytiSkaitymui

klaidaUzdarantSkaitymui:
JMP    pabaiga

;rezultato failo uzdarymas

uzdarytiRasymui:
MOV    ah, 3Eh                ;21h pertraukimo failo u?darymo funkcijos numeris
MOV    bx, rFail            ;? bx ?ra?om rezultato failo deskriptoriaus numer?
INT    21h                ;failo u?darymas
JC    klaidaUzdarantRasymui        ;jei u?darant fail? ?vyksta klaida, nustatomas carry flag

uzdarytiSkaitymui:
MOV    ah, 3Eh                ;21h pertraukimo failo u?darymo funkcijos numeris
MOV    bx, dFail            ;? bx ?ra?om duomen? failo deskriptoriaus numer?
INT    21h                ;failo u?darymas
;JC    klaidaUzdarantSkaitymui        ;jei u?darant fail? ?vyksta klaida, nustatomas carry fla

uzdarytiSkaitymui2:
MOV    ah, 3Eh                ;21h pertraukimo failo u?darymo funkcijos numeris
MOV    bx, dFail            ;? bx ?ra?om duomen? failo deskriptoriaus numer?
INT    21h                ;failo u?darymas
JC    klaidaUzdarantSkaitymui        ;jei u?darant fail? ?vyksta klaida, nustatomas carry flag

Pradeti:
MOV    cx, ax
MOV    si, offset skBuf2
MOV    di, offset raBuf
dirbk2:
MOV    dl, [si]
inc kiek
CMP dl, 'a'
JB    tesk2
CMP dl, 'z'
JA    tesk2
SUB dl, 20h
tesk2:
INC    si
LOOP dirbk2

tikrinimas:
cmp bp, kiek
JG didesnis ;pirmas failas didesnis
cmp bp, kiek
je lygus    ; lygus
cmp bp, kiek
jl mazesnis ; antras failas didesnis

didesnis:
mov max, bp
mov DX, kiek
mov min, dx

mov temp, 0

mov bituKiekis, bp

mov si, offset skBuf
mov p, si
mov si, offset skBuf2
mov a, si

jmp ciklas

lygus:
mov max, bp
mov DX, kiek
mov min, dx
mov sek,bp

mov temp, 0

mov bituKiekis, bp

mov si, offset skBuf
mov dl, [si]
inc si
mov p, si

mov si, offset skBuf2
mov al, [si]
inc si
mov a, si

dec sek

cmp al, dl
JG Keitimas
cmp al, dl
JE Sekantis
cmp al, dl
JL PreCiklas


jmp ciklas

mazesnis:
mov DX, kiek
mov max, dx
mov min, bp
mov bp, max

mov temp, 1
mov bituKiekis, dx

mov si, offset skBuf2
mov p, si

mov si, offset skBuf
mov a, si

jmp ciklas

Keitimas:
mov si, offset skBuf2
mov p, si
mov si, offset skBuf
mov a, si
jmp ciklas

Sekantis:       ;tikrinam skaicius kurie yra didesni
cmp sek, 0
JE PreCiklas

mov si, p
mov dl, [si]
inc si
mov p, si

mov si, a
mov al, [si]
inc si
mov a, si

dec sek

cmp al, dl
JG Keitimas
cmp al, dl
JL PreCiklas
jmp Sekantis


PreCiklas:
mov si, offset skBuf
mov p, si
mov si, offset skBuf2
mov a, si
jmp ciklas

ciklas:
cmp bp, min
jne PozicijosMazinimas


mov si, p
mov dl, [si]                 ;skaitmuo is didesnio skaitmens
inc si
mov p, si
mov temp, dx                 ;jei AL butu didesnis uz DL

mov si, a
mov al, [si]                 ;skaitmuo is mazesnio skaitmes
inc si
mov a, si

cmp al, dl
JE lygusSkaiciai                 ;lygus skaiciai
cmp al, dl
JG didesnisSkaicius              ;is mazesnio failo skaicius didesnis
cmp al, dl
JL mazesnisSkaicius              ;is mazesnio failo skaicius mazesnis

PozicijosMazinimas:
mov si, p
mov dl, [si]               ;skaitmuo is didesnio skaitmens
inc si
mov p, si
MOV [di], dl
inc di
dec bp
jmp ciklas


lygusSkaiciai:;+               ;atliekamas paprastas atimimas vienas is kito
add ax, 30H
sub ax, dx
mov dl, al
MOV [di], dl
inc di
dec bp
dec min
cmp bp, 0
jg ciklas
cmp bp, 0
je rasymas

didesnisSkaicius:;-  ;AL DIDESNIS
dec di
inc counter
mov dl, [di]

cmp dl, 30h
JE didesnisSkaicius

cmp counter, 0
dec [di]
mov dl, [di]
JG MazinkCounteri ; skaiciaus nesimas iki pacio galo, kol bus ivygdoma atimtis

MazinkCounteri:
cmp counter, 0
JE ciklas

inc di
dec counter

cmp counter, 0
JE Atimti

add [di], 9h

jmp MazinkCounteri

Atimti:
mov si, p
dec si
mov dl, [si]
add dl, 39H
sub dl, al
inc dl
MOV [di], dl
inc di
dec bp
dec min
cmp bp, 0
jg JUMPCIKLAS ;-----
cmp bp, 0
je rasymas


mazesnisSkaicius:
add dl, 30H
sub dx, ax
MOV [di], dl
inc di
dec bp
dec min
cmp bp, 0
jg JUMPCIKLAS  ;-----
cmp bp, 0
je rasymas

JUMPCIKLAS:
jmp ciklas


;rezultato irasymas i faila
rasymas:
MOV cx, BituKiekis                ;cx - kiek bait? reikia ?ra?yti
MOV    bx, rFail            ;? bx ?ra?om rezultato failo deskriptoriaus numer?
CALL RasykBuf            ;i?kvie?iame ra?ymo ? fail? proced?r?
CMP    ax, skBufDydis            ;jeigu vyko darbas su pilnu buferiu -> i? duomen? failo buvo nuskaitytas pilnas buferis ->
JE skaityk3      ;-> reikia skaityti toliau
CMP    ax, 0                ;ax ?ra?oma, kiek bait? buvo nuskaityta, jeigu 0 - pasiekta failo pabaiga
JE    uzdarytiRasymui2

pabaiga:
MOV    ah, 4Ch
MOV    al, 0
INT    21h

skaityk3:
MOV    bx, d2Fail            ;? bx ?ra?om duomen? failo deskriptoriaus numer?
CALL    SkaitykBuf2            ;i?kvie?iame skaitymo i? failo proced?r?
CMP    ax, 0                ;ax ?ra?oma, kiek bait? buvo nuskaityta, jeigu 0 - pasiekta failo pabaiga
JE    uzdarytiRasymui2

uzdarytiRasymui2:
MOV    ah, 3Eh                ;21h pertraukimo failo u?darymo funkcijos numeris
MOV    bx, rFail            ;? bx ?ra?om rezultato failo deskriptoriaus numer?
INT    21h                ;failo u?darymas
JC    klaidaUzdarantRasymui2        ;jei u?darant fail? ?vyksta klaida, nustatomas carry
klaidaUzdarantRasymui2:
JMP    uzdarytiSkaitymui


PROC SkaitykBuf
MOV    ah, 3Fh            ;21h pertraukimo duomen? nuskaitymo funkcijos numeris
MOV    cx, skBufDydis        ;cx - kiek bait? reikia nuskaityti i? failo
MOV    dx, offset skBuf    ;vieta, ? kuri? ?ra?oma nuskaityta informacija
INT    21h            ;skaitymas i? failo
JC    klaidaSkaitant        ;jei skaitant i? failo ?vyksta klaida, nustatomas carry flag

klaidaSkaitant:
RET
SkaitykBuf ENDP


PROC SkaitykBuf2
MOV    ah, 3Fh
MOV    cx, sk2BufDydis
MOV    dx, offset skBuf2
INT    21h
JC    klaidaSkaitant2

klaidaSkaitant2:
RET
SkaitykBuf2 ENDP

;Procedura irasanti bufferi i faila

PROC RasykBuf
;? BX paduodamas failo deskriptoriaus numeris
;? CX - kiek bait? ?ra?yti
;? AX bus gr??inta, kiek bait? buvo ?ra?yta
PUSH    dx

MOV    ah, 40h            ;21h pertraukimo duomen? ?ra?ymo funkcijos numeris
MOV    dx, offset raBuf    ;vieta, i? kurios ra?om ? fail?
INT    21h            ;ra?ymas ? fail?
JC    klaidaRasant        ;jei ra?ant ? fail? ?vyksta klaida, nustatomas carry flag
CMP    cx, ax            ;jei cx nelygus ax, vadinasi buvo ?ra?yta tik dalis informacijos
JNE    dalinisIrasymas

RasykBufPabaiga:
POP    dx
RET

dalinisIrasymas:
;<klaidos prane?imo i?vedimo kodas>
JMP    RasykBufPabaiga
klaidaRasant:
;<klaidos prane?imo i?vedimo kodas>
MOV    ax, 0            ;Pa?ymime registre ax, kad nebuvo ?ra?ytas n? vienas simbolis
JMP    RasykBufPabaiga
RasykBuf ENDP


END pradzia
