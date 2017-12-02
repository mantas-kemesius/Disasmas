;------------------------------------------------------Programa----------------------------------------------------------

.model small	;PRIVAL_EIL Pasakom kiek atminties nuskaitinėja
.stack 100h		;PRIVAL_EIL Nurodom Steko dydį
.data			;PRIVAL_EIL Data Segmento pradžia, čia rašysim savo kintamuosius
 hello db 'Iveskite desimtaini skaiciu skaiciu nuo 0 iki 100: $' ;Pasisveikinimo žinutė
 zinute db 'Skaicius + 1 yra: $'
 perDidelis db 'Skaicius yra per didelis!!!$'
 neSkaicius db 'Ivestas ne teigiamas desimtainis skaicius!!!','$'
 bufferis db 256 dup ('$')	;Buferis, kuriame talpinsime vartotojo įvestą skaičių
 enteris db 13,10,'$'		;Carriage return, New Line, End Of Line
;-------------------------------------------------------------------------------
.code			;PRIVAL_EIL Kodo Segmento pradžia, čia rašysim savo kodą


mov ax, 5 ;priskyrimas =
mov bx, 5 ; irgi priskyrimas
mov ax, bx ; atimtis
add ax, 1 ; prideda viena


;Privalomos eilutės
mov ax, @data	;pasakom Assembleriui, kur mūsų kintamieji aprašyt į AX įkeldami data segment'o adresą
mov ds, ax		;iš AX į DS perkeliam data segment'o adresą, dabar galime sėkmingai dirbti su atminties kintamaisiais
;PASTABA: NEGALIMA daryti mov ds, @data, pagal pagrindinę taisyklę: abu operandai NEGALI būti atminties kintamieji

;spausdinam Pasisveikinimo Žinutę (int 21h, AH 09h)
mov ah, 9
mov dx, offset hello
int 21h

;vykdom nuskaitymą (int 21h, AH 0Ah)
mov ah, 0Ah
mov dx, offset bufferis
int 21h
; Bufferio turinys: buf_dydis, kiek_nuskaityta, BAITAS[0], BAITAS[1], ...

;pereinam į kitą eilutę spausdindami enteris simbolių seką
mov ah, 9
mov dx, offset enteris
int 21h

;Nuskaitymas ir pirminių žinučių išvedimas baigtas

;-------------------------------------
;Apdorojame nuskaitytus duomenis

;Idėja tokia, imti po vieną skaitmenį iš buferio ir konstruoti skaičių
;skaičius konstruojamas taip: skaičius dauginamas iš 10 ir pridedamas einamasis skaitmuo
;ciklas sukasi tol, kol baigiasi simboliai (šiuo atveju, kai prieina enter'io simbolį)
mov ax, 0 ;nusinuliname ax registrą
mov si, 2 ;nusistatom indeksinį registra į 2, kadangi tik nuo antro elemento prasidės duomenys

Ciklas:
mov bl, [bufferis+si]	; Pasiimam Bufferis[si] elementą

cmp bl, 13d	 	;lyginam einamąjį simbolį su naujos eilutės ascii kodu
je tikrinimas	;jei pasiekėm enter'į, tai ciklas turi sustot

;tikrinam, ar ten dešimtainis skaitmuo (ascii lentėje 30h - 39h yra dešimtainiai skaitmenys)
cmp bl, 30h ; atitinka '0'
jl skaiciausKlaida
cmp bl, 39h ; atitinka '9'
jg skaiciausKlaida

inc si		 ;padidinam einamąjį indeksą vienetu
sub bl, 30h  ;iš einamojo elemento atimam 30h, kad jis įgautų "tikrąją" šešioliktainę reikšmę assembleryje
; pvz '0' -> 0, '1' -> 1 ir t.t.
mov bh, 10d	 ;perkeliam į bh 10d, nes MUL galima vykdyti tik su registrais
mul bh		 ;dauginam ah'ą iš bh (10d) (einamąjį skaičių iš 10)
mov dx, 0	 ; PAKEITIMAS, prasivalau papildomą registrą DX
mov dl, bl	 ; į jaunesnyjį DX baitą DL keliuosi bl (skaitmenį), kadangi sudėties operandai privalo būti to paties dydžio
add ax, dx   ;pridedam einamąjį skaitmenį prie skaičiaus ir vėl sukam ciklą
			 ; PAKEITIMAS baigtas
jmp ciklas



;klaidos žinutė, kai gavom ne dešimtainį skaičių
skaiciausKlaida:
mov ah, 09h	;jei skaičius didesnis, tai spausdinam klaidos žinutę ir šokam į pabaigą
mov dx, offset neSkaicius
int 21h
jmp Pabaiga

;KĄ TURIM:
;Dabar mes AL'e turime įvestąjį skaičių "grynuoju",
;o ne simboliniu formatu (t.y. turime realią reikšmę)
;Kadangi galime išvesti tik simbolius, tai reikia kažkokiu būdu paversti skaičių į simbolinį formatą
;Galime tai padaryti skaidydami realiąją reikšmę į dešimtainius skaitmenis ir išvesti atitinkamus jų simbolius

;reikia patikrinti ar skaičius didesnis už 100
tikrinimas:
cmp ax, 100d
jle sudetis	;jei skaičius nėra didesnis 100, tęsiam darbą peršokdami ant žymės sudetis
mov ah, 09h	;jei skaičius didesnis, tai spausdinam klaidos žinutę ir šokam į pabaigą
mov dx, offset perDidelis
int 21h
jmp Pabaiga

sudetis:
inc al ;prie AL registro, kuriame laikome skaičių pridedame vienetą

vertimas:
mov ah, 0	;prasivalom ah'ą dėl visą ko
mov bl, 10	;į bl'ą keliamės 10, kad galėtume iš jo dalint
mov si, 0	;prasivalom indeksiuką, jis skaičiuos, kiek dešimtainių skaitmenų mūsų gautas rezultatas turės

VertimoCiklas:
inc si		;didinam skaitmenų kiekį vienetu
div bl		;dalinam savo skaičių iš dešimties
mov ch, 0	;prasivalom ch'ą dėl visą ko (nebūtina)
mov cl, ah	;į cl'ą įsimetam liekaną
mov ah, 0	;prasivalom ah'ą, kad liekanos neliktų
push cx		;į steką padedam cx'ą (liekaną), reikia dėt CX'ą, nes steko operacijas galima vykdyti tik su 'žodžiais'
cmp al, 0	;jei skaičius nelygus nuliui, reiškia reikia toliau dalint
jne VertimoCiklas

;KĄ TURIM:
;Dabar mes steke turime visus dešimtainius skaitmenis.
;ĮDOMU: nors dalindami iš dešimties mes pirmą liekaną gauname vienetų ir tik po to dešimčių, šimtų...
;kadangi mes tas liekanas įpushinom į steką, ištraukti galėsime tik "nuo galo", t.y. mums tinkama, teisinga, tvarka

;spausdinam Žinutę (int 21h, AH 09h)
mov ah, 9
mov dx, offset zinute
int 21h

;pereinam į kitą eilutę spausdindami enteris simbolių seką
mov ah, 9
mov dx, offset enteris
int 21h

Spausdinimas:

pop dx		;į DX'ą pop'inam dvejetainį skaitmenį
mov dh, 0	;profilaktiškai prasivalom dh'ą
add dl, 30h	;prie skaitmens pridedam 30h, kad atitiktų ASCII simbolį, t.y. 2h -> '2'
mov ah, 02h	;į AH'ą metam 02h, tam, kad galėtume spausdinti simbolį (int 21h, AH 02h)
int 21h
dec si		;mažinam si vienetu, kai pasiekiam nulį, reiškia, visus simbolius atspausdinom
cmp si, 0h
je Pabaiga
jmp Spausdinimas

;Išvedame buferio turinį (INT 21h AH 09h)
mov ah, 9
mov dx, offset bufferis
int 21h

;///////////////////////////////////////
;///////////////////////////////////////

;Uždarom programą
Pabaiga:
mov ax, 4C00h
int 21h

END
