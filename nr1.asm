.model small

buferioDydis EQU 121

.stack 200h

.data
bufDydis DB  buferioDydis
buferis	 DB  buferioDydis dup (?)
ivedimoZinute DB 'Iveskite zodi: $'
newline DB 13, 10, '$'
isvedimoZinute DB 'Didziuju raidziu: $'
.code

MOV ax, @data
MOV ds, ax

MOV ah, 9
MOV dx, offset ivedimoZinute
INT 21h

MOV ah, 0Ah
MOV dx, offset bufDydis
INT 21h

MOV ah, 9
MOV dx, offset newline
INT 21h

MOV ax, 0
MOV si, 2

ApdorojimoCiklas:
MOV bl, [bufDydis + si]
CMP bl, 13d
JE Vertimas
INC si
MOV dh, 'A'
MOV dl, 'Z'
CMP bl, dh
  JAE ArZ

MOV dh, 30h
MOV dl, 39H
CMP bl, dh
  JAE ArZ

JMP ApdorojimoCiklas

ArZ:
CMP bl, dl
JBE pridejimas
JMP ApdorojimoCiklas

Pridejimas:
INC ax; ;
JMP ApdorojimoCiklas

Vertimas:
MOV ah, 0
MOV bl, 16
MOV si, 0

VertimoCiklas:
INC si
DIV bl
MOV ch, 0
MOV cl, ah
MOV ah, 0
PUSH cx
CMP al, 0
JNE VertimoCiklas


MOV ah, 9
MOV dx, offset isvedimoZinute
INT 21h

MOV ah, 9
MOV dx, offset newline
INT 21h

Spausdinimas:
POP dx
MOV dh, 0
ADD dl, 30h
mov bl, 39h
CMP bl, dl
  JL Prid
JMP Spaus2

Spaus2:
MOV ah, 02h
INT 21h
DEC si
CMP si, 0
JE pabaiga
JMP spausdinimas

Prid:
  add dl, 7h
  jmp Spaus2

Pabaiga:
mov ax, 4C00h
int 21h

END
