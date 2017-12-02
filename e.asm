.model small
.stack 100h
.data
	buff db 50 dup (?)
	filehandle dw ?
	buffout db 50 dup (?)
	filehandleout dw ?
	
	nuskaityta db 2550 dup (?)
	spausdinimui db 2550 dup (?)
	tikras dw ?
	papildymas dw ?
	senas_si dw ?
	pabaigos_bx dw ?
	prefiksas db ?
	xreg db ?
	xmod db ?
	xrm db ?
	xw db ?
	xd db ?
	xs db ?
	xv db ?
	xsw db ?
	skaitmuo db ?
	
	zinute1 db 'pvz a.exe com.com labas.txt', 10, 13, '$'
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
l1:
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
	jmp l2
	
praleidimas:
	inc bx
	loop l1
;---------------------skaitau ir kuriu antra parametra	
l2:
	mov al, es:[si + bx]
	mov ds:[buffout + bx], al
	inc bx
loop l2

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
	mov cx, 2550
	mov dx, offset nuskaityta
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

		
	call ar_prefiksas
;------------------------------------------pradedu pagrindinio ciklo (main loop) komandos atpazinimo dali

	cmp nuskaityta[si], 3
	ja ne_3
	call spausdinti_add	
	call nustatomi_dw	
	inc si	
	call modregrm
	call dwmodregrm	
	inc si	
	jmp Tesiamas_ciklas
		
ne_3:
	cmp nuskaityta[si], 5
	ja ne_5
	call spausdinti_add
	call akumuliatorius
	inc si
	jmp Tesiamas_ciklas	
ne_5:
	cmp nuskaityta[si], 6
	ja ne_6
	call spausdinti_push
	call spausdinti_ES
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_6:
	cmp nuskaityta[si], 7
	ja ne_7
	call spausdinti_pop
	call spausdinti_ES
	call nauja
	inc si
	jmp Tesiamas_ciklas	
ne_7:
	cmp nuskaityta[si], 11
	ja ne_11
	call spausdinti_or
	call nustatomi_dw	
	inc si	
	call modregrm
	call dwmodregrm	
	inc si	
	jmp Tesiamas_ciklas
ne_11:
	cmp nuskaityta[si], 13
	ja ne_13
	call spausdinti_or
	call akumuliatorius
	inc si
	jmp Tesiamas_ciklas
ne_13:
	cmp nuskaityta[si], 14
	ja ne_14
	call spausdinti_push
	call spausdinti_CS
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_14:
	cmp nuskaityta[si], 15
	ja ne_15
	call spausdinti_pop
	call spausdinti_CS
	call nauja
	inc si
	jmp Tesiamas_ciklas	
ne_15:
	cmp nuskaityta[si], 19
	ja ne_19
	call spausdinti_adc
	call nustatomi_dw	
	inc si	
	call modregrm
	call dwmodregrm	
	inc si	
	jmp Tesiamas_ciklas	
ne_19:
	cmp nuskaityta[si], 21
	ja ne_21
	call spausdinti_adc
	call akumuliatorius
	inc si
	jmp Tesiamas_ciklas
ne_21:
	cmp nuskaityta[si], 22
	ja ne_22
	call spausdinti_push
	call spausdinti_SS
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_22:
	cmp nuskaityta[si], 23
	ja ne_23
	call spausdinti_pop
	call spausdinti_SS
	call nauja
	inc si
	jmp Tesiamas_ciklas	
ne_23:
	cmp nuskaityta[si], 27
	ja ne_27
	call spausdinti_sbb
	call nustatomi_dw	
	inc si	
	call modregrm
	call dwmodregrm	
	inc si	
	jmp Tesiamas_ciklas	
ne_27:
	cmp nuskaityta[si], 29
	ja ne_29
	call spausdinti_sbb
	call akumuliatorius
	inc si
	jmp Tesiamas_ciklas
ne_29:
	cmp nuskaityta[si], 30
	ja ne_30
	call spausdinti_push
	call spausdinti_DS
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_30:
	cmp nuskaityta[si], 31
	ja ne_31
	call spausdinti_pop
	call spausdinti_DS
	call nauja
	inc si
	jmp Tesiamas_ciklas	
ne_31:
	cmp nuskaityta[si], 35
	ja ne_35
	call spausdinti_and
	call nustatomi_dw	
	inc si	
	call modregrm
	call dwmodregrm	
	inc si	
	jmp Tesiamas_ciklas	
ne_35:
	cmp nuskaityta[si], 37
	ja ne_37
	call spausdinti_and
	call akumuliatorius
	inc si
	jmp Tesiamas_ciklas
ne_37:
	cmp nuskaityta[si],39
	ja ne_39
	call spausdinti_daa
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_39:
	cmp nuskaityta[si], 43
	ja ne_43
	call spausdinti_sub
	call nustatomi_dw	
	inc si	
	call modregrm
	call dwmodregrm	
	inc si	
	jmp Tesiamas_ciklas	
ne_43:
	cmp nuskaityta[si], 45
	ja ne_45
	call spausdinti_sub
	call akumuliatorius
	inc si
	jmp Tesiamas_ciklas
ne_45:
	cmp nuskaityta[si], 47
	ja ne_47
	call spausdinti_das
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_47:
	cmp nuskaityta[si], 51
	ja ne_51
	call spausdinti_xor
	call nustatomi_dw	
	inc si	
	call modregrm
	call dwmodregrm	
	inc si	
	jmp Tesiamas_ciklas	
ne_51:
	cmp nuskaityta[si], 53
	ja ne_53
	call spausdinti_xor
	call akumuliatorius
	inc si
	jmp Tesiamas_ciklas
ne_53:
	cmp nuskaityta[si], 55
	ja ne_55
	call spausdinti_aaa
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_55:
	cmp nuskaityta[si], 59
	ja ne_59
	call spausdinti_cmp
	call nustatomi_dw	
	inc si	
	call modregrm
	call dwmodregrm	
	inc si	
	jmp Tesiamas_ciklas	
ne_59:
	cmp nuskaityta[si], 61
	ja ne_61
	call spausdinti_cmp
	call akumuliatorius
	inc si
	jmp Tesiamas_ciklas
ne_61:
	cmp nuskaityta[si], 63
	ja ne_63
	call spausdinti_aas
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_63:
	cmp nuskaityta[si], 71
	ja ne_71
	call spausdinti_inc
	call tik_registras
	inc si
	jmp Tesiamas_ciklas
ne_71:
	cmp nuskaityta[si], 79
	ja ne_79
	call spausdinti_dec
	call tik_registras
	inc si
	jmp Tesiamas_ciklas
ne_79:
	cmp nuskaityta[si], 87
	ja ne_87
	call spausdinti_push
	call tik_registras
	inc si
	jmp Tesiamas_ciklas
ne_87:
	cmp nuskaityta[si], 95
	ja ne_95
	call spausdinti_pop
	call tik_registras
	inc si
	jmp Tesiamas_ciklas
ne_95:
	cmp nuskaityta[si], 112
	ja ne_112
	call spausdinti_jo
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_112:
	cmp nuskaityta[si], 113
	ja ne_113
	call spausdinti_jno
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_113:
	cmp nuskaityta[si], 114
	ja ne_114
	call spausdinti_jb
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_114:
	cmp nuskaityta[si], 115
	ja ne_115
	call spausdinti_jnb
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_115:
	cmp nuskaityta[si], 116
	ja ne_116
	call spausdinti_je
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_116:
	cmp nuskaityta[si], 117
	ja ne_117
	call spausdinti_jne
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_117:
	cmp nuskaityta[si], 118
	ja ne_118
	call spausdinti_jbe
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_118:
	cmp nuskaityta[si], 119
	ja ne_119
	call spausdinti_ja
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_119:
	cmp nuskaityta[si], 120
	ja ne_120
	call spausdinti_js
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_120:
	cmp nuskaityta[si], 121
	ja ne_121
	call spausdinti_jns
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_121:
	cmp nuskaityta[si], 122
	ja ne_122
	call spausdinti_jp
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_122:
	cmp nuskaityta[si], 123
	ja ne_123
	call spausdinti_jnp
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_123:
	cmp nuskaityta[si], 124
	ja ne_124
	call spausdinti_jl
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_124:
	cmp nuskaityta[si], 125
	ja ne_125
	call spausdinti_jnl
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_125:
	cmp nuskaityta[si], 126
	ja ne_126
	call spausdinti_jng
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_126:
	cmp nuskaityta[si], 127
	ja ne_127
	call spausdinti_jg
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_127:
	cmp nuskaityta[si], 131
	ja ne_131
	call nustatomi_sw
	inc si
	call modregrm
	call swmodregrm
	inc si
	jmp Tesiamas_ciklas
ne_131:
	cmp nuskaityta[si], 133
	ja ne_133
	call spausdinti_test
	call nustatomi_dw
	mov xd, 1 
	inc si	
	call modregrm
	call dwmodregrm	
	inc si	
	jmp Tesiamas_ciklas	
ne_133:
	cmp nuskaityta[si], 135
	ja ne_135
	call spausdinti_xchg
	call nustatomi_dw	
	inc si	
	call modregrm
	call dwmodregrm	
	inc si	
	jmp Tesiamas_ciklas	
ne_135:
	cmp nuskaityta[si], 139
	ja ne_139
	call spausdinti_mov
	call nustatomi_dw	
	inc si	
	call modregrm
	call dwmodregrm	
	inc si	
	jmp Tesiamas_ciklas	
ne_139:
	cmp nuskaityta[si], 140
	ja ne_140
	call spausdinti_mov
	call nustatomi_dw
	inc si
	mov xw, 1
	call modregrm
	call mod_sutvarkymas
	call kablelis_ir_tarpas
	call segmento_atpazinimas
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_140:
	cmp nuskaityta[si], 141
	ja ne_141
	call spausdinti_lea
	mov xd, 1
	mov xw, 1
	inc si
	call modregrm
	call dwmodregrm
	inc si
	jmp Tesiamas_ciklas	
ne_141:
	cmp nuskaityta[si], 142
	ja ne_142
	call spausdinti_mov
	call nustatomi_dw
	inc si
	mov xw, 1
	call modregrm
	call segmento_atpazinimas
	call kablelis_ir_tarpas
	call mod_sutvarkymas
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_142:
	cmp nuskaityta[si], 143
	ja ne_143
	call spausdinti_pop
	inc si
	call modregrm
	call mod_sutvarkymas
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_143:
	cmp nuskaityta[si],144
	ja ne_144
	call spausdinti_nop
	inc si
	jmp Tesiamas_ciklas
ne_144:
	cmp nuskaityta[si],151
	ja ne_151
	call spausdinti_xchg
	call spausdinti_ax
	call kablelis_ir_tarpas
	call tik_registras
	inc si
	jmp Tesiamas_ciklas
ne_151:
	cmp nuskaityta[si], 152
	ja ne_152
	call spausdinti_cbw
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_152:
	cmp nuskaityta[si], 153
	ja ne_153
	call spausdinti_cwd
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_153:
	cmp nuskaityta[si], 154
	ja ne_154
	call spausdinti_call
	call aass
	inc si
	jmp Tesiamas_ciklas	
ne_154:
	cmp nuskaityta[si], 155
	ja ne_155
	call spausdinti_wait
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_155:
	cmp nuskaityta[si], 156
	ja ne_156
	call spausdinti_pushf
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_156:
	cmp nuskaityta[si], 157
	ja ne_157
	call spausdinti_popf
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_157:
	cmp nuskaityta[si], 158
	ja ne_158
	call spausdinti_sahf
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_158:
	cmp nuskaityta[si], 159
	ja ne_159
	call spausdinti_lahf
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_159:
	cmp nuskaityta[si], 161
	ja ne_161
	call spausdinti_mov
	call nustatomi_dw
	mov xreg, 0
	mov xmod, 3
	mov xd, 1
	call registarai
	call kablelis_ir_tarpas
	mov spausdinimui[bx], 91
	inc bx
	call zodinis_sesioliktainis_skaicius
	mov spausdinimui[bx], 93
	inc bx
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_161:
	cmp nuskaityta[si], 163
	ja ne_163
	call spausdinti_mov
	call nustatomi_dw
	mov spausdinimui[bx], 91
	inc bx
	call zodinis_sesioliktainis_skaicius
	mov spausdinimui[bx], 93
	inc bx
	call kablelis_ir_tarpas
	mov xreg, 0
	mov xmod, 3
	mov xd, 1
	call registarai
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_163:
	cmp nuskaityta[si], 164
	ja ne_164
	call spausdinti_movsb
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_164:
	cmp nuskaityta[si], 165
	ja ne_165
	call spausdinti_movsw
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_165:
	cmp nuskaityta[si], 166
	ja ne_166
	call spausdinti_cmpsb
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_166:
	cmp nuskaityta[si], 167
	ja ne_167
	call spausdinti_cmpsw
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_167:
	cmp nuskaityta[si], 169
	ja ne_169
	call spausdinti_test
	call akumuliatorius
	inc si
	jmp Tesiamas_ciklas
ne_169:
	cmp nuskaityta[si], 170
	ja ne_170
	call spausdinti_stosb
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_170:
	cmp nuskaityta[si], 171
	ja ne_171
	call spausdinti_stosw
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_171:
	cmp nuskaityta[si], 172
	ja ne_172
	call spausdinti_lodsb
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_172:
	cmp nuskaityta[si], 173
	ja ne_173
	call spausdinti_lodsw
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_173:
	cmp nuskaityta[si], 174
	ja ne_174
	call spausdinti_scasb
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_174:
	cmp nuskaityta[si], 175
	ja ne_175
	call spausdinti_scasw
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_175:
	cmp nuskaityta[si], 191
	ja ne_191
	call spausdinti_mov
	call wreg
	inc si
	jmp Tesiamas_ciklas
ne_191:
	cmp nuskaityta[si], 194
	ja ne_194
	call spausdinti_ret
	call spausdinti_ax
	call kablelis_ir_tarpas
	call zodinis_sesioliktainis_skaicius
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_194:
	cmp nuskaityta[si], 195
	ja ne_195
	call spausdinti_ret
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_195:
	cmp nuskaityta[si], 196
	ja ne_196
	call spausdinti_les
	mov xd, 1
	mov xw, 1
	inc si
	call modregrm
	call dwmodregrm
	inc si
	jmp Tesiamas_ciklas
ne_196:
	cmp nuskaityta[si], 197
	ja ne_197
	call spausdinti_lds
	mov xd, 1
	mov xw, 1
	inc si
	call modregrm
	call dwmodregrm
	inc si
	jmp Tesiamas_ciklas
ne_197:
	cmp nuskaityta[si], 198
	ja ne_198
	call spausdinti_mov
	mov xd, 0
	inc si
	call modregrm
	call mod_sutvarkymas
	call kablelis_ir_tarpas
	call baitinis_sesioliktaini_skaiciaus
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_198:
	cmp nuskaityta[si], 199
	ja ne_199
	call spausdinti_mov
	mov xd, 0
	inc si
	call modregrm
	call mod_sutvarkymas
	call kablelis_ir_tarpas
	call zodinis_sesioliktainis_skaicius
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_199:
	cmp nuskaityta[si], 202
	ja ne_202
	call spausdinti_retf
	call zodinis_sesioliktainis_skaicius
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_202:
	cmp nuskaityta[si], 203
	ja ne_203
	call spausdinti_retf
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_203:
	cmp nuskaityta[si], 204
	ja ne_204
	call spausdinti_int_3
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_204:
	cmp nuskaityta[si], 205
	ja ne_205
	call spausdinti_int
	call baitinis_sesioliktaini_skaiciaus
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_205:
	cmp nuskaityta[si], 206
	ja ne_206
	call spausdinti_into
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_206:
	cmp nuskaityta[si], 207
	ja ne_207
	call spausdinti_iret
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_207:
	cmp nuskaityta[si], 211
	ja ne_211
	call nustatomi_vw
	inc si
	call modregrm
	call vwmodregrm
	inc si
	jmp Tesiamas_ciklas
ne_211:
	cmp nuskaityta[si], 212
	ja ne_212
	call spausdinti_aam
	call nauja
	inc si
	inc si
	jmp Tesiamas_ciklas
ne_212:
	cmp nuskaityta[si], 213
	ja ne_213
	call spausdinti_aad
	call nauja
	inc si
	inc si
	jmp Tesiamas_ciklas
ne_213:
	cmp nuskaityta[si], 215
	ja ne_215
	call spausdinti_xlat
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_215:
	cmp nuskaityta[si], 223
	ja ne_223
	call spausdinti_esc
	inc si
	call modregrm
	call mod_sutvarkymas
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_223:
	cmp nuskaityta[si], 224
	ja ne_224
	call spausdinti_loopne
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_224:
	cmp nuskaityta[si], 225
	ja ne_225
	call spausdinti_loope
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_225:
	cmp nuskaityta[si], 226
	ja ne_226
	call spausdinti_loop
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_226:
	cmp nuskaityta[si], 227
	ja ne_227
	call spausdinti_jcxz
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_227:
	cmp nuskaityta[si], 229
	ja ne_229
	call spausdinti_in
	call baitinis_sesioliktaini_skaiciaus
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_229:
	cmp nuskaityta[si], 231
	ja ne_231
	call spausdinti_out
	call baitinis_sesioliktaini_skaiciaus
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_231:
	cmp nuskaityta[si], 232
	ja ne_232
	call spausdinti_call
	call jumpam_zodinis
	inc si
	jmp Tesiamas_ciklas
ne_232:
	cmp nuskaityta[si], 233
	ja ne_233
	call spausdinti_jmp
	call jumpam_zodinis
	inc si
	jmp Tesiamas_ciklas
ne_233:
	cmp nuskaityta[si], 234
	ja ne_234
	call spausdinti_jmp
	call jumpam_zodinis
	call kablelis_ir_tarpas
	call zodinis_sesioliktainis_skaicius
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_234:
	cmp nuskaityta[si], 235
	ja ne_235
	call spausdinti_jmp
	call jumpam
	inc si
	jmp Tesiamas_ciklas
ne_235:
	cmp nuskaityta[si], 237
	ja ne_237
	call spausdinti_in
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_237:
	cmp nuskaityta[si], 239
	ja ne_239
	call spausdinti_out
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_239:
	cmp nuskaityta[si], 240
	ja ne_240
	call spausdinti_lock
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_240:
	cmp nuskaityta[si], 242
	ja ne_242
	call spausdinti_repne
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_242:
	cmp nuskaityta[si], 243
	ja ne_243
	call spausdinti_rep
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_243:
	cmp nuskaityta[si], 244
	ja ne_244
	call spausdinti_hlt
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_244:
	cmp nuskaityta[si], 245
	ja ne_245
	call spausdinti_cmc
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_245:
	cmp nuskaityta[si], 247
	ja ne_247
	call nustatomi_dw
	inc si
	call modregrm
	call notmodregrm
	inc si
	jmp Tesiamas_ciklas
ne_247:
	cmp nuskaityta[si], 248
	ja ne_248
	call spausdinti_clc
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_248:
	cmp nuskaityta[si], 249
	ja ne_249
	call spausdinti_stc
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_249:
	cmp nuskaityta[si], 250
	ja ne_250
	call spausdinti_cli
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_250:
	cmp nuskaityta[si], 251
	ja ne_251
	call spausdinti_sti
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_251:
	cmp nuskaityta[si], 252
	ja ne_252
	call spausdinti_cld
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_252:
	cmp nuskaityta[si], 253
	ja ne_253
	call spausdinti_std
	call nauja
	inc si
	jmp Tesiamas_ciklas
ne_253:
	cmp nuskaityta[si], 255
	ja ne_255
	call nustatomi_dw
	inc si
	call modregrm
	call incmodregrm
	inc si
	jmp Tesiamas_ciklas
ne_255:
Tesiamas_ciklas:
	call nereikalinga_seka

	cmp si, 2540
	jl nereikia_dar_papildomai_nuskaityti
	call nuskaitymas
  nereikia_dar_papildomai_nuskaityti:
	cmp si, cx
	jl programa_dar_nesibaige
	jmp exit
  programa_dar_nesibaige:
	cmp bx, 2500
	jl dar_nereikia_spausdinti
	call spausdinti
  dar_nereikia_spausdinti:
  
  
	jmp Pagrindinis_ciklas
	jmp exit
;------------------------------------
	spausdinti_ip proc near
		push ax
		
		mov spausdinimui[bx], 67
		inc bx
		mov spausdinimui[bx], 83
		inc bx
		mov spausdinimui[bx], 58
		inc bx
		mov tikras, 0
		mov ax, papildymas
		add tikras, ax
		add tikras, si
		call tikrasutvarkymas
		
		
		mov spausdinimui[bx], 20h
		inc bx
		
		pop ax
		ret
	spausdinti_ip endp
	
	tikrasutvarkymas proc near
		push ax
		
		mov ax, tikras
		shr ah, 4h
		mov al, ah
		call sekos_skaitmuo
		mov ax, tikras
		and ah, 15
		mov al, ah
		call sekos_skaitmuo
		mov ax, tikras
		shr al, 4h
		call sekos_skaitmuo
		mov ax, tikras
		and al, 15
		call sekos_skaitmuo
		
		pop ax
		ret
	tikrasutvarkymas endp
	
	sekos_skaitmuo proc near
		cmp al, 9
		ja sekos_skaitmuo_raide
		add al, 30h
		mov spausdinimui[bx], al
		inc bx
		jmp exit_sekos_skaitmuo
	sekos_skaitmuo_raide:
		add al, 55
		mov spausdinimui[bx], al
		inc bx
	exit_sekos_skaitmuo:
		ret
	sekos_skaitmuo endp
	
	sekos_spausdinimas proc near
		push cx
		push si
		push ax
		xor ax, ax
		
		mov cx, 8
	sekos_ciklas:
		mov al, nuskaityta[si]
		shr al, 4
		call sekos_skaitmuo
		mov al, nuskaityta[si]
		and al, 15
		call sekos_skaitmuo
		inc si
	loop sekos_ciklas
		mov pabaigos_bx, bx
		mov spausdinimui[bx], 20h
		inc bx
		
		pop ax
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
		mov spausdinimui[bx], 20h
		dec bx
	loop trinimo_ciklas
		
		pop bx
		pop si
		pop cx
		ret
	nereikalinga_seka endp
;------------------------------------ naudojamas sutvarkyti komandas su papildomu kodu
	incmodregrm proc near
		mov xd, 0
		cmp xreg, 0
		jne incmodregrm_ne_inc
		call spausdinti_inc
	incmodregrm_ne_inc:
		cmp xreg, 1
		jne incmodregrm_ne_dec
		call spausdinti_dec
	incmodregrm_ne_dec:
		cmp xreg, 2
		jne incmodregrm_ne_call1
		call spausdinti_call
	incmodregrm_ne_call1:
		cmp xreg, 3
		jne incmodregrm_ne_call2
		call spausdinti_call
	incmodregrm_ne_call2:
		cmp xreg, 4
		jne incmodregrm_ne_jmp1
		call spausdinti_jmp
	incmodregrm_ne_jmp1:
		cmp xreg, 5
		jne incmodregrm_ne_jmp2
		call spausdinti_jmp
	incmodregrm_ne_jmp2:
		cmp xreg, 6
		jne incmodregrm_ne_push
		call spausdinti_push
	incmodregrm_ne_push:
		call mod_sutvarkymas
		call nauja
		ret
	incmodregrm endp
;------------------------------------ naudojamas sutvarkyti komandas su papildomu kodu
	notmodregrm proc near
		mov xd, 0
		cmp xreg, 0
		jne notmodregrm_ne_test
		call spausdinti_test
		call mod_sutvarkymas
		call kablelis_ir_tarpas
		cmp xw, 0
		je test_baitinis
		call zodinis_sesioliktainis_skaicius
		jmp exit_notmodregrm
	test_baitinis:
		call baitinis_sesioliktaini_skaiciaus
		jmp exit_notmodregrm
	notmodregrm_ne_test:
		cmp xreg, 2
		jne notmodregrm_ne_not
		call spausdinti_not
	notmodregrm_ne_not:
		cmp xreg, 3
		jne notmodregrm_ne_neg
		call spausdinti_neg
	notmodregrm_ne_neg:
		cmp xreg, 4
		jne notmodregrm_ne_mul
		call spausdinti_mul
	notmodregrm_ne_mul:
		cmp xreg, 5
		jne notmodregrm_ne_imul
		call spausdinti_imul
	notmodregrm_ne_imul:
		cmp xreg, 6
		jne notmodregrm_ne_div
		call spausdinti_div
	notmodregrm_ne_div:
		cmp xreg, 7
		jne notmodregrm_ne_idiv
		call spausdinti_idiv
	notmodregrm_ne_idiv:
		call mod_sutvarkymas
	exit_notmodregrm:
		call nauja
		ret
	notmodregrm endp
;------------------------------------  naudojamas sutvarkyti komandas su papildomu kodu
	vwmodregrm proc near
		mov xd, 0
		cmp xreg, 0
		jne vwmodregrm_ne_rol
		call spausdinti_rol
	vwmodregrm_ne_rol:
		cmp xreg, 1
		jne vwmodregrm_ne_ror
		call spausdinti_ror
	vwmodregrm_ne_ror:
		cmp xreg, 2
		jne vwmodregrm_ne_rcl
		call spausdinti_rcl
	vwmodregrm_ne_rcl:
		cmp xreg, 3
		jne vwmodregrm_ne_rcr
		call spausdinti_rcr
	vwmodregrm_ne_rcr:
		cmp xreg, 4
		jne vwmodregrm_ne_shl
		call spausdinti_shl
	vwmodregrm_ne_shl:
		cmp xreg, 5
		jne vwmodregrm_ne_shr
		call spausdinti_shr
	vwmodregrm_ne_shr:
		cmp xreg, 7
		jne vwmodregrm_ne_sar
		call spausdinti_sar
	vwmodregrm_ne_sar:
		call mod_sutvarkymas
		call kablelis_ir_tarpas
		cmp xv, 1
		jne vwmodregrm_cl
		mov spausdinimui[bx], 31h
		inc bx
		jmp exit_vwmodregrm
	vwmodregrm_cl:
		call spausdinti_cl
	exit_vwmodregrm:
		call nauja
		ret
	vwmodregrm endp
;------------------------------------ naudojamas apdoroti operacijos koda 1011 wreg
	wreg proc near
		push ax
		mov al, nuskaityta[si]
		and al, 8
		shr al, 3
		mov xw, al
		mov al, nuskaityta[si]
		and al, 7
		mov xreg, al
		mov xd, 1
		call registarai
		call kablelis_ir_tarpas
		cmp xw, 1
		jne wreg_baitinis
		call zodinis_sesioliktainis_skaicius
		jmp exit_wreg
	wreg_baitinis:
		call baitinis_sesioliktaini_skaiciaus
	exit_wreg:
		call nauja
		pop ax
		ret
	wreg endp
;------------------------------------ naudojamas sustvarkyti komandas ar ju dalis kurios dirba su segmentais sr
	segmento_atpazinimas proc near
		cmp xreg, 0
		jne segmentas_ne_ES
		call spausdinti_ES
	segmentas_ne_ES:
		cmp xreg, 1
		jne segmentas_ne_CS
		call spausdinti_CS
	segmentas_ne_CS:
		cmp xreg, 2
		jne segmentas_ne_SS
		call spausdinti_SS
	segmentas_ne_SS:
		cmp xreg, 3
		jne segmentas_ne_DS
		call spausdinti_DS
	segmentas_ne_DS:
		ret
	segmento_atpazinimas endp
;------------------------------------ naudojamas su komandom kuriu operacijos kodas **** **sw mod reg r/m
	swmodregrm proc near
		mov xd, 0
		cmp xreg, 0
		jne swmodregrm_ne_add
		call spausdinti_add
	swmodregrm_ne_add:
		cmp xreg, 1
		jne swmodregrm_ne_or
		call spausdinti_or
	swmodregrm_ne_or:
		cmp xreg, 2
		jne swmodregrm_ne_adc
		call spausdinti_adc
	swmodregrm_ne_adc:
		cmp xreg, 3
		jne swmodregrm_ne_sbb
		call spausdinti_sbb
	swmodregrm_ne_sbb:
		cmp xreg, 4
		jne swmodregrm_ne_and
		call spausdinti_and
	swmodregrm_ne_and:
		cmp xreg, 5
		jne swmodregrm_ne_sub
		call spausdinti_sub
	swmodregrm_ne_sub:
		cmp xreg, 6
		jne swmodregrm_ne_xor
		call spausdinti_xor
	swmodregrm_ne_xor:
		cmp xreg, 7
		jne swmodregrm_ne_cmp
		call spausdinti_cmp
	swmodregrm_ne_cmp:
		call mod_sutvarkymas
		call kablelis_ir_tarpas
		cmp xsw, 1
		jne swmodregrm_baitas
		call zodinis_sesioliktainis_skaicius
		jmp exit_swmodregrm
	swmodregrm_baitas:
		call baitinis_sesioliktaini_skaiciaus
	exit_swmodregrm:
		call nauja
		ret
	swmodregrm endp
;------------------------------------  nustatomi sw is operacijos kodo **** **sw
	nustatomi_sw proc near
		push ax
		mov al, nuskaityta[si]
		and al, 3
		mov xsw, al
		mov al, nuskaityta[si]
		and al, 2
		shr al, 1
		mov xs, al
		mov al, nuskaityta[si]
		and al, 1
		mov xw, al
		pop ax
		ret
	nustatomi_sw endp
;------------------------------------ spausdinamas [sesioliktainis skaicius]
	jumpam proc near
		mov spausdinimui[bx], 91
		inc bx
		call baitinis_sesioliktaini_skaiciaus
		mov spausdinimui[bx], 93
		inc bx
		call nauja
		ret
	jumpam endp
;------------------------------------ spausdinamas [2 baitu sesioliktainis skaicius]
	jumpam_zodinis proc near
		mov spausdinimui[bx], 91
		inc bx
		call zodinis_sesioliktainis_skaicius
		mov spausdinimui[bx], 93
		inc bx
		call nauja
		ret
	jumpam_zodinis endp
;------------------------------------- apdorojama operacijos koda **** *reg
	tik_registras proc near
		push ax
		mov al, nuskaityta[si]
		and al, 7
		mov xreg, al
		mov xrm, al
		mov xw, 1
		call registarai
		call nauja
		pop ax
		ret
	tik_registras endp
;------------------------------------   atpazysta akumuliatoriu al arba ax
	akumuliatorius proc near
		push ax
		
		mov al, nuskaityta[si]
		and al, 1
		cmp al, 0
		jne akumuliatorius_ax
		call spausdinti_al
		call kablelis_ir_tarpas
		call baitinis_sesioliktaini_skaiciaus
		jmp exit_akumuliatorius
		
	akumuliatorius_ax:
		call spausdinti_ax
		call kablelis_ir_tarpas
		call zodinis_sesioliktainis_skaicius
		
	exit_akumuliatorius:
		call nauja
		
		pop ax
		ret
	akumuliatorius endp
;------------------------------------ procedura kuri kai bx pasiekia tam tikra reiksme spausdina i faila
	spausdinti proc near
	
		push ax
		push bx
		push cx
		push dx
		
		mov cx, bx
		mov ax, 4000h
		mov bx, filehandleout
		mov dx, offset spausdinimui
		int 21h
		
		
		
		pop dx
		pop cx
		pop bx
		pop ax
		
		xor bx, bx	
		
		ret
	spausdinti endp
;----------------------------------- procedura tikrina ar pries operacijos koda yra prefiksas
	ar_prefiksas proc near
	
		prefikso_tikrinimas:
		cmp nuskaityta[si], 26h
		jne tolimesnis_prefiksas
		mov prefiksas, 26h
		inc si
		jmp exit_ar_prefiksas
	tolimesnis_prefiksas:
		cmp nuskaityta[si], 2Eh
		jne tolimesnis_prefiksas2
		mov prefiksas, 2Eh
		inc si
		jmp exit_ar_prefiksas
	tolimesnis_prefiksas2:
		cmp nuskaityta[si], 36h
		jne tolimesnis_prefiksas3
		mov prefiksas, 36h
		inc si
		jmp exit_ar_prefiksas
	tolimesnis_prefiksas3:
		cmp nuskaityta[si], 3Eh
		jne nera_prefikso
		mov prefiksas, 3Eh
		inc si
		jmp exit_ar_prefiksas
	nera_prefikso:
		mov prefiksas, 0
	exit_ar_prefiksas:
		ret
		
	ar_prefiksas endp
;---------------------------------- kai si pasiekia tam tikra reiksme is naujo papildomas buferis
	nuskaitymas proc near
	
		push ax
		push bx
		push dx				
	
		
		sub cx, si
		mov bx, cx
		
	nuskaitymo_ciklas:
		dec bx
		mov al, nuskaityta[si+bx]
		mov nuskaityta[bx], al
		cmp bx, 0
		jnz nuskaitymo_ciklas
		
		mov dx, si
		mov si, cx
		push cx
		
	
		mov cx, dx
		mov dx, offset nuskaityta[si]	
		mov ax, 3F00h
		mov bx, filehandle 
		int 21h
		
	
		pop cx
		add cx, ax
		pop dx
		pop bx
		pop ax
		
		xor si,si
		
		ret
	nuskaitymas endp
;------------------------------------
	spausdinti_ax proc near
		
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 120
		inc bx
		
		ret
	spausdinti_ax endp
;------------------------------------
	spausdinti_al proc near
		
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		
		ret
	spausdinti_al endp
;------------------------------------
	spausdinti_cl proc near
		
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		
		ret
	spausdinti_cl endp
;------------------------------------
	spausdinti_bx proc near
		
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 120
		inc bx
		
		ret
	spausdinti_bx endp
;------------------------------------
	spausdinti_si proc near
	
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 105
		inc bx
		
		ret
	spausdinti_si endp
;-----------------------------------
	spausdinti_di proc near
		
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 105
		inc bx
		
		ret
	spausdinti_di endp
;-----------------------------------
	spausdinti_bp proc near
	
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		
		ret
	spausdinti_bp endp
;---------------------------------
	spausdinti_add proc near
		
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_add endp
;---------------------------------
	spausdinti_pop proc near
		
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
	
		ret
	spausdinti_pop endp
;---------------------------------
	spausdinti_push proc near
		
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 117
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 104
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
	
		ret
	spausdinti_push endp
;---------------------------------
	spausdinti_or proc near
		
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_or endp
;---------------------------------
	spausdinti_adc proc near
	
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_adc endp
;---------------------------------
	spausdinti_sbb proc near
		
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_sbb endp
;---------------------------------
	spausdinti_and proc near
		
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_and endp
;---------------------------------
	spausdinti_daa proc near
		
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_daa endp
;---------------------------------
	spausdinti_sub proc near
		
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 117
		inc bx
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_sub endp
;---------------------------------
	spausdinti_das proc near
		
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_das endp
;---------------------------------
	spausdinti_xor proc near
		
		mov spausdinimui[bx], 120
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_xor endp
;---------------------------------
	spausdinti_aaa proc near
		
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_aaa endp
;---------------------------------
	spausdinti_cmp proc near
		
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 109
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_cmp endp
;---------------------------------
	spausdinti_aas proc near
		
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_aas endp
;---------------------------------
	spausdinti_inc proc near
		
		mov spausdinimui[bx], 105
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_inc endp
;---------------------------------
	spausdinti_dec proc near
		
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_dec endp
;---------------------------------
	spausdinti_jo proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_jo endp
;---------------------------------
	spausdinti_jno proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_jno endp
;---------------------------------
	spausdinti_jb proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_jb endp
;---------------------------------
	spausdinti_jnb proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_jnb endp
;---------------------------------
	spausdinti_je proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_je endp
;---------------------------------
	spausdinti_jne proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_jne endp
;---------------------------------
	spausdinti_jbe proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_jbe endp
;---------------------------------
	spausdinti_ja proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_ja endp
;---------------------------------
	spausdinti_js proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_js endp
;---------------------------------
	spausdinti_jns proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_jns endp
;---------------------------------
	spausdinti_jp proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_jp endp
;---------------------------------
	spausdinti_jnp proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_jnp endp
;---------------------------------
	spausdinti_jl proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_jl endp
;---------------------------------
	spausdinti_jnl proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_jnl endp
;---------------------------------
	spausdinti_jng proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 103
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_jng endp
;---------------------------------
	spausdinti_jg proc near
		
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 103
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_jg endp
;---------------------------------
	spausdinti_test proc near
		
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_test endp
;---------------------------------
	spausdinti_xchg proc near
		
		mov spausdinimui[bx], 120
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 104
		inc bx
		mov spausdinimui[bx], 103
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_xchg endp
;---------------------------------
	spausdinti_mov proc near
		
		mov spausdinimui[bx], 109
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 118
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_mov endp
;---------------------------------
	spausdinti_lea proc near
		
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_lea endp
;---------------------------------
	spausdinti_nop proc near
		
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_nop endp
;---------------------------------
	spausdinti_cbw proc near
		
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 119
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_cbw endp
;---------------------------------
	spausdinti_cwd proc near
		
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 119
		inc bx
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_cwd endp
;---------------------------------
	spausdinti_call proc near
		
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_call endp
;---------------------------------
	spausdinti_wait proc near
		
		mov spausdinimui[bx], 119
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 105
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_wait endp
;---------------------------------
	spausdinti_pushf proc near
		
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 117
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 104
		inc bx
		mov spausdinimui[bx], 102
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_pushf endp
;---------------------------------
	spausdinti_popf proc near
		
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 102
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_popf endp
;---------------------------------
	spausdinti_sahf proc near
		
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 104
		inc bx
		mov spausdinimui[bx], 102
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_sahf endp
;---------------------------------
	spausdinti_lahf proc near
		
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 104
		inc bx
		mov spausdinimui[bx], 102
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_lahf endp
;---------------------------------
	spausdinti_movsb proc near
		
		mov spausdinimui[bx], 109
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 118
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_movsb endp
;---------------------------------
	spausdinti_movsw proc near
		
		mov spausdinimui[bx], 109
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 118
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 119
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_movsw endp
;---------------------------------
	spausdinti_cmpsb proc near
		
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 109
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_cmpsb endp
;---------------------------------
	spausdinti_cmpsw proc near
		
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 109
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 119
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_cmpsw endp
;---------------------------------
	spausdinti_stosb proc near
		
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_stosb endp
;---------------------------------
	spausdinti_stosw proc near
		
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 119
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_stosw endp
;---------------------------------
	spausdinti_lodsb proc near
		
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_lodsb endp
;---------------------------------
	spausdinti_lodsw proc near
		
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 119
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_lodsw endp
;---------------------------------
	spausdinti_scasb proc near
		
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_scasb endp
;---------------------------------
	spausdinti_scasw proc near
		
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 119
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_scasw endp
;---------------------------------
	spausdinti_ret proc near
		
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_ret endp
;---------------------------------
	spausdinti_les proc near
		
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_les endp
;---------------------------------
	spausdinti_lds proc near
		
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_lds endp
;---------------------------------
	spausdinti_retf proc near
		
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 102
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_retf endp
;---------------------------------
	spausdinti_int_3 proc near
		
		mov spausdinimui[bx], 105
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		mov spausdinimui[bx], 33h
		inc bx
		
		ret
	spausdinti_int_3 endp
;---------------------------------
	spausdinti_int proc near
		
		mov spausdinimui[bx], 105
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_int endp
;---------------------------------
	spausdinti_into proc near
		
		mov spausdinimui[bx], 105
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_into endp
;---------------------------------
	spausdinti_iret proc near
		
		mov spausdinimui[bx], 105
		inc bx
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_iret endp
;---------------------------------
	spausdinti_rol proc near
		
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 118
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_rol endp
;---------------------------------
	spausdinti_ror proc near
		
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_ror endp
;---------------------------------
	spausdinti_rcl proc near
		
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 118
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_rcl endp
;---------------------------------
	spausdinti_rcr proc near
		
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_rcr endp
;---------------------------------
	spausdinti_shl proc near
		
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 104
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_shl endp
;---------------------------------
	spausdinti_shr proc near
		
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 104
		inc bx
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_shr endp
;---------------------------------
	spausdinti_sar proc near
		
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_sar endp
;---------------------------------
	spausdinti_aam proc near
		
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 109
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_aam endp
;---------------------------------
	spausdinti_aad proc near
		
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_aad endp
;---------------------------------
	spausdinti_xlat proc near
		
		mov spausdinimui[bx], 120
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_xlat endp
;---------------------------------
	spausdinti_esc proc near
		
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		
		ret
	spausdinti_esc endp
;---------------------------------
	spausdinti_loop proc near
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_loop endp
;---------------------------------	
	spausdinti_loope proc near
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[si], 101
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_loope endp
;---------------------------------	
	spausdinti_loopne proc near
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[si], 101
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_loopne endp
;---------------------------------	
	spausdinti_jcxz proc near
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 120
		inc bx
		mov spausdinimui[bx], 122
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_jcxz endp
;---------------------------------	
	spausdinti_lock proc near
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 107
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_lock endp
;---------------------------------
	spausdinti_in proc near
		mov spausdinimui[bx], 105
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_in endp
;---------------------------------
	spausdinti_out proc near
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 117
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_out endp
;---------------------------------
	spausdinti_jmp proc near
		mov spausdinimui[bx], 106
		inc bx
		mov spausdinimui[bx], 109
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_jmp endp
;---------------------------------
	spausdinti_repne proc near
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[si], 101
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_repne endp
;---------------------------------
	spausdinti_rep proc near
		mov spausdinimui[bx], 114
		inc bx
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_rep endp
;---------------------------------
	spausdinti_hlt proc near
		mov spausdinimui[bx], 104
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_hlt endp
;---------------------------------
	spausdinti_cmc proc near
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 109
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_cmc endp
;---------------------------------
	spausdinti_clc proc near
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_clc endp
;---------------------------------
	spausdinti_stc proc near
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_stc endp
;---------------------------------
	spausdinti_cli proc near
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 105
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_cli endp
;---------------------------------
	spausdinti_sti proc near
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 105
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_sti endp
;---------------------------------
	spausdinti_cld proc near
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_cld endp
;---------------------------------
	spausdinti_std proc near
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_std endp
;---------------------------------
	spausdinti_not proc near
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 111
		inc bx
		mov spausdinimui[bx], 116
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_not endp
;---------------------------------
	spausdinti_neg proc near
		mov spausdinimui[bx], 110
		inc bx
		mov spausdinimui[bx], 101
		inc bx
		mov spausdinimui[bx], 103
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_neg endp
;---------------------------------
	spausdinti_mul proc near
		mov spausdinimui[bx], 109
		inc bx
		mov spausdinimui[bx], 117
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_mul endp
;---------------------------------
	spausdinti_imul proc near
		mov spausdinimui[bx], 105
		inc bx
		mov spausdinimui[bx], 109
		inc bx
		mov spausdinimui[bx], 117
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_imul endp
;---------------------------------
	spausdinti_div proc near
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 105
		inc bx
		mov spausdinimui[bx], 118
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_div endp
;---------------------------------
	spausdinti_idiv proc near
		mov spausdinimui[bx], 105
		inc bx
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 105
		inc bx
		mov spausdinimui[bx], 118
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
		ret
	spausdinti_idiv endp
;--------------------------------- nustatomas registras is mod reg r/m
	
	registarai proc near
		
		push ax
		
		cmp xd, 0
		je reik_naudot_rm
		mov al, xreg
		mov xd, 0
		jmp tikrinu_registro_dydi
	reik_naudot_rm:
		mov al, xrm
		mov xd, 1
		
	tikrinu_registro_dydi:
		cmp xw, 0
		je dydis_baitas
		jmp dydis_zodis
		
	dydis_baitas:
	
		cmp al, 0
		jne ne_al
		call spausdinti_al
		jmp exit_registrai
	ne_al:
		cmp al, 1
		jne ne_cl
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		jmp exit_registrai
	ne_cl:
		cmp al, 2
		jne ne_dl
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		jmp exit_registrai
	ne_dl:
		cmp al, 3
		jne ne_bl
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 108
		inc bx
		jmp exit_registrai
	ne_bl:
		cmp al, 4
		jne ne_ah
		mov spausdinimui[bx], 97
		inc bx
		mov spausdinimui[bx], 104
		inc bx
		jmp exit_registrai
	ne_ah:
		cmp al, 5
		jne ne_ch
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 104
		inc bx
		jmp exit_registrai
	ne_ch:
		cmp al, 6
		jne ne_dh
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 104
		inc bx
		jmp exit_registrai
	ne_dh:
		cmp al, 7
		jne exit_registrai
		mov spausdinimui[bx], 98
		inc bx
		mov spausdinimui[bx], 104
		inc bx
		jmp exit_registrai
	
	dydis_zodis:
	
		cmp al, 0
		jne ne_ax
		call spausdinti_ax
		jmp exit_registrai
	ne_ax:
		cmp al, 1
		jne ne_cx
		mov spausdinimui[bx], 99
		inc bx
		mov spausdinimui[bx], 120
		inc bx
		jmp exit_registrai
	ne_cx:
		cmp al, 2
		jne ne_dx
		mov spausdinimui[bx], 100
		inc bx
		mov spausdinimui[bx], 120
		inc bx
		jmp exit_registrai
	ne_dx:
		cmp al, 3
		jne ne_bx
		call spausdinti_bx
		jmp exit_registrai
	ne_bx:
		cmp al, 4
		jne ne_sp
		mov spausdinimui[bx], 115
		inc bx
		mov spausdinimui[bx], 112
		inc bx
		jmp exit_registrai
	ne_sp:
		cmp al, 5
		jne ne_bp
		call spausdinti_bp
		jmp exit_registrai
	ne_bp:
		cmp al, 6
		jne ne_si
		call spausdinti_si
		jmp exit_registrai
	ne_si:
		call spausdinti_di
		jmp exit_registrai
	
	exit_registrai:	
		pop ax
		
		ret
		
	registarai endp
;---------------------------------------------- atskiriami mod reg r/m
	modregrm proc near
	
		push ax
		
		mov al, nuskaityta[si]
		shr al, 6
		mov xmod, al
		
		mov al, nuskaityta[si]
		and al, 56
		shr al, 3
		mov xreg, al
		
		mov al, nuskaityta[si]
		and al, 7
		mov xrm, al
		
		pop ax
		
		ret 	
	modregrm endp
;------------------------------------------ nustatomi vm is operacijos kodo **** **vw
	nustatomi_vw proc near
	
		push ax
		
		mov al, nuskaityta[si]
		and al, 2
		shr al, 1
		mov xv, al
		
		mov al, nuskaityta[si]
		and al, 1
		mov xw, al
		
		pop ax
		
		ret
		
	nustatomi_vw endp	
;------------------------------------------ nustatomo dw is operacijos kodo **** **dw
	nustatomi_dw proc near
	
		push ax
		
		mov al, nuskaityta[si]
		and al, 2
		shr al, 1
		mov xd, al
		
		mov al, nuskaityta[si]
		and al, 1
		mov xw, al
		
		pop ax
		
		ret
		
	nustatomi_dw endp
;-------------------------------------------
	tarpas_pliusas_tarpas proc near
	
		mov spausdinimui[bx], 20h
		inc bx
		mov spausdinimui[bx], 43
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
	
		ret		
	tarpas_pliusas_tarpas endp
;-----------------------------------------------
	kablelis_ir_tarpas proc near
	
		mov spausdinimui[bx], 44
		inc bx
		mov spausdinimui[bx], 20h
		inc bx
	
		ret	
	kablelis_ir_tarpas endp
;--------------------------------------
	nauja proc near
	
		mov spausdinimui[bx], 13
		inc bx
		mov spausdinimui[bx], 10
		inc bx
		ret
	
	nauja endp
;---------------------------------------------- jei operacijos kodas turi prefiksa, ji ispausdina reikiamoje vietoje
	prefikso_isspausdinimas proc near
		
		cmp prefiksas, 0
		je prefiksas_pagal_nutilejima
		cmp prefiksas, 26h
		je prefiksas_ES
		cmp prefiksas, 2Eh
		je prefiksas_CS
		cmp prefiksas, 36h
		je prefiksas_SS
		jmp prefiksas_DS
	prefiksas_ES:
		call spausdinti_ES
		mov spausdinimui[bx], 58
		inc bx
		jmp prefiksas_pagal_nutilejima
	prefiksas_CS:
		call spausdinti_CS
		mov spausdinimui[bx], 58
		inc bx
		jmp prefiksas_pagal_nutilejima
	prefiksas_SS:
		call spausdinti_SS
		mov spausdinimui[bx], 58
		inc bx
		jmp prefiksas_pagal_nutilejima
	prefiksas_DS:
		call spausdinti_DS
		mov spausdinimui[bx], 58
		inc bx
	prefiksas_pagal_nutilejima:
	
		ret	
	prefikso_isspausdinimas endp
;---------------------------------------
	spausdinti_ES proc near
	
		mov spausdinimui[bx], 69
		inc bx
		mov spausdinimui[bx], 83
		inc bx
		
		ret
	spausdinti_ES endp
;---------------------------------------
	spausdinti_CS proc near
	
		mov spausdinimui[bx], 67
		inc bx
		mov spausdinimui[bx], 83
		inc bx
		
		ret
	spausdinti_CS endp
;---------------------------------------
	spausdinti_SS proc near
	
		mov spausdinimui[bx], 83
		inc bx
		mov spausdinimui[bx], 83
		inc bx
		
		ret
	spausdinti_SS endp
;---------------------------------------
	spausdinti_DS proc near
	
		mov spausdinimui[bx], 68
		inc bx
		mov spausdinimui[bx], 83
		inc bx
		
		ret
	spausdinti_DS endp
;--------------------------------------- apdoroja operacijos koda **** **dw mod reg r/m
	dwmodregrm proc near
		
		cmp xd, 0
		je pirmiau_eina_rm
		call registarai
		call kablelis_ir_tarpas
		call mod_sutvarkymas
		call nauja
		jmp exit_dwmodregrm
				
	pirmiau_eina_rm:
		call mod_sutvarkymas
		mov  xd, 1
		call kablelis_ir_tarpas
		call registarai
		call nauja
	
	exit_dwmodregrm:
	
		ret
		
	dwmodregrm endp
;--------------------------------------- procedura kuri atlieka mod r/m operacijos pobudzio atpazinima
	mod_sutvarkymas proc near
		
		cmp xmod, 3
		jl tai_ne_registras
		call registarai
		mov xd, 1
		jmp mod_jau_sutvarkytas
	tai_ne_registras:
		call tai_yra_atmintis

	mod_jau_sutvarkytas:
		ret	
	mod_sutvarkymas endp
;--------------------------------------- atspausdina atminties adresa
	tai_yra_atmintis proc near
	
		call prefikso_isspausdinimas
		
		mov spausdinimui[bx], 91
		inc bx
		cmp xrm, 0
		jne ne_bx_si
		call spausdinti_bx
		call tarpas_pliusas_tarpas
		call spausdinti_si
		jmp exit_tai_yra_atmintis
	ne_bx_si:
		cmp xrm, 1
		jne ne_bx_di
		call spausdinti_bx
		call tarpas_pliusas_tarpas
		call spausdinti_di
		jmp exit_tai_yra_atmintis
	ne_bx_di:
		cmp xrm, 2
		jne ne_bp_si
		call spausdinti_bp
		call tarpas_pliusas_tarpas
		call spausdinti_si
		inc bx
		jmp exit_tai_yra_atmintis
	ne_bp_si:
		cmp xrm, 3
		jne ne_bp_di
		call spausdinti_bp
		call tarpas_pliusas_tarpas
		call spausdinti_di
		jmp exit_tai_yra_atmintis
	ne_bp_di:
		cmp xrm, 4
		jne ne_si_xx
		call spausdinti_si
		jmp exit_tai_yra_atmintis
	ne_si_xx:
		cmp xrm, 5
		jne ne_di_xx
		call spausdinti_di
		jmp exit_tai_yra_atmintis
	ne_di_xx:
		cmp xrm, 6
		jne ne_xx_xx
		cmp xmod, 0
		je atmintyje_tiesioginis_adresas
		call spausdinti_bp
	atmintyje_tiesioginis_adresas:
		call zodinis_sesioliktainis_skaicius
		jmp exit_tai_yra_atmintis
	ne_xx_xx:
		call spausdinti_bx
	
	exit_tai_yra_atmintis:
		cmp xmod, 2
		jne atmintyje_ne_zodzio_poslinkis
		call tarpas_pliusas_tarpas
		call zodinis_sesioliktainis_skaicius
	atmintyje_ne_zodzio_poslinkis:
		cmp xmod, 1
		jne atmintyje_ne_baito_poslinkis
		call tarpas_pliusas_tarpas
		call baitinis_sesioliktaini_skaiciaus
	atmintyje_ne_baito_poslinkis:
		mov spausdinimui[bx], 93
		inc bx

		ret
	
	tai_yra_atmintis endp
;-------------------------------- atspausdina sesioliktaini skaiciu
	baitinis_sesioliktaini_skaiciaus proc near
	
		push ax
		
		inc si
		mov al, nuskaityta[si]
		shr al, 4
		mov skaitmuo, al
		call pirmas_sesioliktainis_skaitmuo
		
		mov al, nuskaityta[si]
		and al, 15
		mov skaitmuo, al
		call kitas_sesioliktainis_skaitmuo
		mov spausdinimui[bx], 104
		inc bx
		
		pop ax
		ret	
	baitinis_sesioliktaini_skaiciaus endp
;------------------------------------------ atspausdina 2 baitu siosiliktaini skaiciu
	zodinis_sesioliktainis_skaicius proc near
	
		push ax
		
		inc si
		inc si
		mov al, nuskaityta[si]
		shr al, 4
		mov skaitmuo, al
		call pirmas_sesioliktainis_skaitmuo
		
		mov al, nuskaityta[si]
		and al, 15
		mov skaitmuo, al
		call kitas_sesioliktainis_skaitmuo
		
		dec si
		mov al, nuskaityta[si]
		shr al, 4
		mov skaitmuo, al
		call kitas_sesioliktainis_skaitmuo
		
		mov al, nuskaityta[si]
		and al, 15
		mov skaitmuo, al
		call kitas_sesioliktainis_skaitmuo
		mov spausdinimui[bx], 104
		inc bx
		inc si
		
		pop ax
		ret
	zodinis_sesioliktainis_skaicius endp
;------------------------------------------- jei raide priekyje spausdins nuliuka
	pirmas_sesioliktainis_skaitmuo proc near
		push ax
		
		mov al, skaitmuo
		cmp al, 9
		ja pirmas_skaitmuo_raide
		add al, 30h
		mov spausdinimui[bx], al
		inc bx
		jmp exit_pirmas_sesioliktainis_skaitmuo	
	pirmas_skaitmuo_raide:
		mov spausdinimui[bx], 30h
		inc bx
		add al, 55
		mov spausdinimui[bx], al
		inc bx
	exit_pirmas_sesioliktainis_skaitmuo:
		pop ax
		ret
	pirmas_sesioliktainis_skaitmuo endp
;------------------------------------------------- spausdins tik sesioliktaini skaitmeni
	kitas_sesioliktainis_skaitmuo proc near	
		push ax
		
		mov skaitmuo, al
		cmp al, 9
		ja kitas_skaitmuo_raide
		add al, 30h
		mov spausdinimui[bx], al
		inc bx
		jmp exit_kitas_sesioliktainis_skaitmuo
	kitas_skaitmuo_raide:
		add al, 55
		mov spausdinimui[bx], al
		inc bx
	exit_kitas_sesioliktainis_skaitmuo:
		pop ax
		ret
	kitas_sesioliktainis_skaitmuo endp
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
	aass proc near
		mov spausdinimui[bx], 91
		inc bx
		call zodinis_sesioliktainis_skaicius
		mov spausdinimui[bx], 93
		call kablelis_ir_tarpas
		call zodinis_sesioliktainis_skaicius
		call nauja
		ret
	aass endp




	
		
exit:
	mov cx, bx
	mov ax, 4000h
	mov bx, filehandleout
	mov dx, offset spausdinimui
	int 21h

	mov ax, 4C00h
	int 21h
	
end start