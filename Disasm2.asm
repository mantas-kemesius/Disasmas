.model small
.stack 100h
.data
;------ Tarpiniai pranesimai

    enteris db 13,10,'$'
    neatp_pradzia db 'db $'
    neatp_pabaiga db ' ;Neatpazinau komandos$'
    temp_for_al db ?


;---------------MASININIS KODAS
    Mas_kodas db 41h, 42h, 43h, 59h,13h
              db  0h,0ECh, 0CDh,21h, 12h
              db 26h,74h, 5Ch, 5Fh

;----------------DARBINIAI KINTAMIEJI  

    reg_part db ?
    rm_part db ?
    mod_part db ?
    d_part db ?
    w_part db ?
    sr_part db ?
      
    bojb_baitas db ? ;pasidedam bojb baita 
      
    firstByte db ? ;pasidedam pirma komandos baita
    secondByte db ? ;pasidedam pirma komandos baita
    thirdByte db ? ;pasidedam pirma komandos baita

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
    
    c_LOOP db 'LOPP $'

;---------------SPAUSDINAMU REGISTRU VARDAI
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

   mov ax, @data
   mov ds, ax

   mov si, offset Mas_kodas
   mov di, offset Mas_kodas+14

;------------------------------------------------------------------------------------------------------

MainLoop:

    call getFirstByte
    mov byte ptr[firstByte], al

    call getInfo
    call print_kodoeilute
	
    mov ah, 9
    mov dx, offset enteris
    int 21h  
        
jmp MainLoop

;------------------------------------------------------------------------------------------------------
    
getFirstByte:
    mov al,[si]
    inc si
    
    cmp si, di
    ja getFirstByte_temp_jmp_to_end_program   
    
    jmp getFirstByte_end

    getFirstByte_temp_jmp_to_end_program:
    jmp exit

    getFirstByte_end:
    RET

;------------------------------------------------------------------------------------------------------   

;get data according firstByte AND Procedura surenkanti komandos detales (tarkim d,w,reg,mod,r/m ir kt reiksmes)
getInfo:
   
    call getD
    call getW
    
    call gauk_formato_nr 

    cmp byte ptr[format_nr], 1 ;jei formato numeris 1
    je domisi_pirmu
    cmp byte ptr[format_nr], 2 ;jei formato numeris 2
    je domisi_antru
    jmp domisi_nuliniu ;kai netiko ne vienas atvejis

RET


getD:
  mov byte ptr[temp_for_al], al 
  mov al, byte ptr[firstByte]
  and al, 00000010b
  mov byte ptr[d_part], al
  mov al, byte ptr[firstByte]
ret

getW:
  mov byte ptr[temp_for_al], al
  mov al, byte ptr[firstByte]
  and al, 00000010b
  mov byte ptr[w_part], al
  mov al, byte ptr[temp_for_al]
ret

getMOD:
  mov byte ptr[temp_for_al], al
  mov al, byte ptr[secondByte]
  and al, 11000000b
  mov byte ptr[mod_part], al
  mov al, byte ptr[temp_for_al]
ret
;------------------------------------------------------------------------------------------------------

;Procedura, pagal pirmo baito reiksme padeta duomenu segmente firstByte vietoje nustato kurio numerio cia formatas
;rezultata iraso duomenu_segmente i baita (format_nr)

gauk_formato_nr:

    cmp byte ptr[firstByte], 40h
    jb gal_antras
    cmp byte ptr[firstByte], 5Fh
    ja gal_antras

    ;patekom i intervala 40h-5Fh
    ;reiskia pirmas formatas
    mov byte ptr[format_nr], 1
    RET 

    gal_antras:
    cmp byte ptr[firstByte], 0CDh ;ar antras formatas, jo pirmas baitas CD - (INT)
    je taip_antras
    jmp neatpazintas

    taip_antras:
    mov byte ptr[format_nr], 2
    RET

    neatpazintas:
    mov byte ptr[format_nr], 0
RET            

;------------------------------------------------------------------------------------------------------

;Surenka detales apie pirma formata (xxxx xreg) - reikalinga REG dalis ir pirmas baitas
;Pirma baita jau turim is pagr_ciklo
;I reg_part baita duom.segmente pasiimame reg'o reiksme
;(pasinaudodami pirmo baito reiksme)

domisi_pirmu:

    push ax
        mov al, byte ptr[firstByte]
        and al, 111b
        mov byte ptr[reg_part], al
    pop ax 
    
RET

;Surenka detales apie antra formata (CD numeris - kur numeris vieno baito betarp.op) 

domisi_antru:  

   push ax
        call getFirstByte ;gaunam i AL antro baito reiksme
        mov byte ptr[bojb_baitas], al ;pasidedam i pacio disasmo duom segmenta bet.op. baito reiksme
   pop ax
   
RET

domisi_nuliniu:  
RET

;------------------------------------------------------------------------------------------------------


;*************************************************************************************************************************
;=========================================================================================================================
;*************************************************************************************************************************

;Procedura, kuri rupinasi asemblerines komandos spausdinimu, kai jau zino formata
;Realiai ji tik paziuri kuris formatas ir pagal ta spausdina    

print_kodoeilute:
    ;pasiziurim, koks dabartines komandos formato numeris buvo nustatytas
    ;pagal tai kvieciam atitinkama procedura
    cmp byte ptr[format_nr], 1
    je pr_kod_kviesk1
    cmp byte ptr[format_nr], 2
    je pr_kod_kviesk2
    jmp pr_kod_kviesk0

    pr_kod_kviesk1:
        call print_formatui1
        RET
    pr_kod_kviesk2:
        call print_formatui2
        RET
    pr_kod_kviesk0:
        call print_formatui0
        RET    
        
        
;------------------------------------------------------------------------------------------------------

;****************** GAVUS INFO APIE BAITA ATLIEKAME TAM TIKRUS VEIKSMUS, JOG ATVAIZDUOTUME JI **************************************

print_formatui1:
    push ax
    call spausdink_varda
    mov al, byte ptr[reg_part]
    call print_reg_w1
    pop ax
RET

print_formatui2:
    push ax
    call spausdink_varda
    mov al, byte ptr[bojb_baitas]
    call print_baita_hexu
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



;Spausdina komandos varda pagal pirma baita (bendru atveju pirma baita ir galbut antra, arba antro reg dali)

spausdink_varda:
    push ax
    push bx
    push cx
    push dx

    ;spejam, kad cia INC (pirmas baitas is intervalo 40-47h)  
    
    cmp byte ptr[firstByte], 40h
    jb gal_komanda_pop
    cmp byte ptr[firstByte], 47h
    ja gal_komanda_pop
    
    ;vis tik cia INC
    mov bx, offset c_INC
    jmp vardo_spausdinimas

    ;spejam, kad cia POP (pirmas baitas is intervalo 58-5Fh)
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

;------------------------------------------------------------------------------------------------------


;spausdina konstantos baita sesioliktaine sistema, su h raide po jo
;ir nuliu priekyj (nes skaicius negali prasidet raide, paprastumo delei nuli priekyj)
;prirasau visais atvejais, ir kai raide ir kai skaicius
;ENTRY: AL (AL spausdina AL padeta 16taini skaiciu)
;Naudojantis loginiu funkciju savybem nedarau konversijos su dalyba :)
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

;Spausdina i ekrana nurodyta sesioliktaini skaitmeni
;(ta skaitmeni randa jaunesniam AL pusbaityj)
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


;------------------------------------------------------------------------------------------------------

;spausdina zodini registra i ekrana
;koks tas registras pasakom AL baite (addr. baito lentoj r/m=000-111, mod=11, w=1)
print_reg_w1:
    push ax
    push bx
    push cx
    push dx

    test al, 100b
    je reg_w1_0xx
    jmp reg_w1_1xx

        reg_w1_0xx:
        test al, 10b
        je reg_w1_00x
        jmp reg_w1_01x

        reg_w1_1xx:
        test al, 10b
        je reg_w1_10x
        jmp reg_w1_11x

            reg_w1_00x:
            test al, 1b
            je reg_w1_000
            jmp reg_w1_001

            reg_w1_01x:
            test al, 1b
            je reg_w1_010
            jmp reg_w1_011

            reg_w1_10x:
            test al, 1b
            je reg_w1_100
            jmp reg_w1_101

            reg_w1_11x:
            test al, 1b
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

;spausdina zodini registra i ekrana
;koks tas registras pasakom AL baite (addr. baito lentoj r/m=000-111, mod=11, w=1)
print_reg_w0:
    push ax
    push bx
    push cx
    push dx

    test al, 100b
    je reg_w0_0xx
    jmp reg_w0_1xx

        reg_w0_0xx:
        test al, 10b
        je reg_w0_00x
        jmp reg_w0_01x

        reg_w0_1xx:
        test al, 10b
        je reg_w0_10x
        jmp reg_w0_11x

            reg_w0_00x:
            test al, 1b
            je reg_w0_000
            jmp reg_w0_001

            reg_w0_01x:
            test al, 1b
            je reg_w0_010
            jmp reg_w0_011

            reg_w0_10x:
            test al, 1b
            je reg_w0_100
            jmp reg_w0_101

            reg_w0_11x:
            test al, 1b
            je reg_w0_110
            jmp reg_w0_111

                reg_w0_000:
                mov bx, offset r_AX
                jmp reg_w0_spausd

                reg_w0_001:
                mov bx, offset r_CX
                jmp reg_w0_spausd

                reg_w0_010:
                mov bx, offset r_DX
                jmp reg_w0_spausd

                reg_w0_011:
                mov bx, offset r_BX
                jmp reg_w0_spausd
                ;----
                reg_w0_100:
                mov bx, offset r_SP
                jmp reg_w0_spausd

                reg_w0_101:
                mov bx, offset r_BP
                jmp reg_w0_spausd

                reg_w0_110:
                mov bx, offset r_SI
                jmp reg_w0_spausd

                reg_w0_111:
                mov bx, offset r_DI
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



exit:
    mov ah, 9
    mov dx, offset enteris
    int 21h

    mov ah, 4Ch
    int 21h
END
