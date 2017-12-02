.model small

buferioDydis	EQU	121

;.stack 100h

;*******************Perkelta i kodo segmento pabaiga************
;.data
;	bufDydis DB  buferioDydis
;	nuskaite DB  ?
;	buferis	 DB  buferioDydis dup ('$')
;	ivesk	 DB  'Iveskite eilute:', 13, 10, '$'
;	rezult	 DB  'Radau tiek didziuju raidziu: '
;	rezult2	 DB  3 dup (' ')
;	enteris	 DB  13, 10, '$'
;***************************************************************
			
;*************************Pakeista******************************
;.code
BSeg SEGMENT
;***************************************************************

;*******************Prideta*************************************
	ORG	100h
	ASSUME ds:BSeg, cs:BSeg, ss:BSeg
;***************************************************************

Pradzia:
;	MOV	ax, @data
;	MOV	ds, ax

;****nuskaito eilute****
	MOV	ah, 9
	MOV	dx, offset ivesk
	INT	21h

	MOV	ah, 0Ah
	MOV	dx, offset bufDydis
	INT	21h

	MOV	ah, 9
	MOV	dx, offset enteris
	INT	21h

;****algoritmas****
	XOR	ch, ch
	SUB	ax, ax
	MOV	cl, nuskaite
	MOV	bx, offset buferis
	MOV	dl, 'A'
	MOV	dh, 'Z'

;*******************Prideta*************************************
BSeg ENDS
;***************************************************************
END	Pradzia		