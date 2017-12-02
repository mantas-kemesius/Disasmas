;-----Mazas disasemblerio prototipas

;Programa disasemblina tris asembleriniu komandu atvejus:
;   0100 0reg - INC registras (zodinis)
;   0101 1reg - POP registras (zodinis)
;   1100 1101 bojb - INT bojb (vieno baito betarpiskas operandas)

;   Programoje mazdaug padarytas 2 formatu atpazinimas:
;   Nr. 0 - neatpazinta komanda
;   Nr. 1 - xxxx xreg - KOM registras (zodinis)
;   Nr. 2 - xxxx xxxx bojb - Vieno baito OPK, vieno baito konstanta (betarp.op.)


;   Masininis kodas - imama 15 baitu is duomenu segmento ir bando atpazinti.
;   Darbo rezultatus spausdina ekrane
;   Programa padaryta taip, kad prasant 16-to baito reiksmes, ji tiesiog uzbaigia darba

;   Programa ne visiskai parodo kaip veiktu pilnai parasytas disasembleris
;   Kodas skirtas bendrai esmei apie disasm'a suvokti
;   T.y. darant realu lengviau rasyti is naujo, nei naudotis kazkuo is cia :)
;   Jis daugiau skirtas veiksmu eiliskumui parodyti

;   Iskart ispeju, kad siais atvejais prefiksu nebuna, tai neaprasiau ju apdorojimo
;   Skirtingai nuo realaus disasmo nerenku informacijos is failo
;   Ir neisvedu rezultatu i faila
   
;   Cia tik demonstracine mokomuoju tikslu rasyta programa :)

.model small
.stack 100h
.data
;-----------------
    enteris db 13,10,'$'


;---------------MASININIS KODAS (penkiolika baitu)
      Mas_kodas db 0ABh,41h, 42h, 43h, 59h
                db  0h,0ECh, 0CDh,21h, 12h
                db 26h,74h, 5Ch, 5Fh, 13h
                
;----------------DARBINIAI KINTAMIEJI
      reg_dalis db ?   ;pasidedam reg dali
      bojb_baitas db ? ;pasidedam bojb baita
      pirmas_baitas db ? ;pasidedam pirma komandos baita 
      
      dabar_frm db ? ;dabartines komandos formato numeris 
      
;---------------SPAUSDINAMU KOMANDU VARDAI
    k_INC db 'INC $'
    k_POP db 'POP $'
    k_INT db 'INT $'

;---------------SPAUSDINAMU REGISTRU VARDAI
    r_AX db 'ax$'
    r_CX db 'cx$'
    r_DX db 'dx$'
    r_BX db 'bx$'
    r_SP db 'sp$'
    r_BP db 'bp$'
    r_SI db 'si$'
    r_DI db 'di$'

;-------------Kiti pranesimai:
    neatp_pradzia db 'db $'
    neatp_pabaiga db ' ;Neatpazinau komandos$'
  
.code
   mov ax, @data
   mov ds, ax
   
   mov si, offset Mas_kodas ;pasizymim kur mas_kodas prasideda
   mov di, offset Mas_kodas+15 ;pasizymim kur mas_kodas baigiasi

;sukam pagrindini cikla, kiekvienam ciklo prasukime bandom atpazint kazkokia komanda   
pagr_ciklas:
    call get_byte ;bandom gauti pirma baita (cia gali pasitaikyt koks prefiksas, siuo atveju to visai neapdoroju)
    mov byte ptr[pirmas_baitas], al
    
    call surink_informacija ;procedura, kuri surenka informacija apie komanda is jos masininio kodo (nuskaito pozymius)
    call print_kodoeilute   ;spausdina asemblerinio kodo eilute i ekrana
        mov ah, 9 ;spausdinam enteri, einam i kita eilute
        mov dx, offset enteris
        int 21h
    jmp pagr_ciklas

    ;Gauna sekancio baito reiksme i AL registra
    ;Jei prasoma 16-to baito, nukillina programa
get_byte:
    mov al,[si]
    inc si
    cmp si, di  ;si>di? juk DI laikem, kur baigesi, vadinas skaitom eileje 16-taji baita
    
    ja gb_uzdarymo_tarpinis ;issisuku is padeties del tolimo salyginio jmp
    jmp get_byte_baigti
    
    gb_uzdarymo_tarpinis:
    jmp uzdarymas
    
    get_byte_baigti:
    RET


;Procedura surenkanti komandos detales (tarkim d,w,reg,mod,r/m ir kt reiksmes)   
surink_informacija:
    call gauk_formato_nr ;pagal pirma baita, koks formato_nr?
    
    cmp byte ptr[dabar_frm], 1 ;jei formato numeris 1
    je domisi_pirmu
    cmp byte ptr[dabar_frm], 2 ;jei formato numeris 2
    je domisi_antru
    jmp domisi_nuliniu ;kai netiko ne vienas atvejis
    
RET    
       
;Procedura, pagal pirmo baito reiksme padeta duomenu segmente pirmas_baitas vietoje
;nustato kurio numerio cia formatas
;rezultata iraso duomenu_segmente i baita (dabar_frm) 
gauk_formato_nr:
        
    cmp byte ptr[pirmas_baitas], 40h
    jb gal_antras
    cmp byte ptr[pirmas_baitas], 5Fh
    ja gal_antras
    
    ;patekom i intervala 40h-5Fh
    ;reiskia pirmas formatas
    mov byte ptr[dabar_frm], 1
    RET ;griztam jau dabar, toliau sios proceduros nevykdom
    
    gal_antras:
    cmp byte ptr[pirmas_baitas], 0CDh ;ar antras formatas, jo pirmas baitas CD
    je taip_antras
    jmp neatpazintas 
    
    taip_antras:
    mov byte ptr[dabar_frm], 2
    RET ;griztam jau dabar toliau nevykdom
    
    neatpazintas:
    mov byte ptr[dabar_frm], 0 ;vis tik nei pirmas, nei antras    
RET

;Surenka detales apie pirma formata (xxxx xreg) - reikalinga REG dalis ir pirmas baitas
;Pirma baita jau turim is pagr_ciklo
;I reg_dalis baita duom.segmente pasiimame reg'o reiksme
;(pasinaudodami pirmo baito reiksme)
domisi_pirmu:
    push ax
        mov al, byte ptr[pirmas_baitas]
        and al, 111b
        mov byte ptr[reg_dalis], al 
    pop ax
RET

;Surenka detales apie antra formata (CD numeris - kur numeris vieno baito betarp.op)
domisi_antru:
   push ax
        call get_byte ;gaunam i AL antro baito reiksme
        mov byte ptr[bojb_baitas], al ;pasidedam i pacio disasmo duom segmenta bet.op. baito reiksme
   pop ax
RET

;Surenka detales apie nulini formata (neatpazinta komanda)
domisi_nuliniu:
    ;nera ka gaut, pirma baita turim, kvieciu tik siaip sau del bendros tvarkos
RET   


;Procedura, kuri rupinasi asemblerines komandos spausdinimu, kai jau zino formata
;Realiai ji tik paziuri kuris formatas ir pagal ta spausdina
print_kodoeilute:
    ;pasiziurim, koks dabartines komandos formato numeris buvo nustatytas
    ;pagal tai kvieciam atitinkama procedura
    cmp byte ptr[dabar_frm], 1
    je pr_kod_kviesk1
    cmp byte ptr[dabar_frm], 2
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
        
;Spausdina komandos varda pagal pirma baita (bendru atveju pirma baita ir galbut antra, arba antro reg dali)
spausdink_varda:
    push ax ;procedura panaudoje nenorim sugadint registru reiksmiu, issisaugom
    push bx
    push cx
    push dx
    
    ;spejam, kad cia INC (pirmas baitas is intervalo 40-47h)
    cmp byte ptr[pirmas_baitas], 40h
    jb gal_komanda_pop
    cmp byte ptr[pirmas_baitas], 47h
    ja gal_komanda_pop
        ;vis tik cia INC
        mov bx, offset k_INC
        jmp vardo_spausdinimas
    
    ;spejam, kad cia POP (pirmas baitas is intervalo 58-5Fh)
    gal_komanda_pop:
    cmp byte ptr[pirmas_baitas], 58h
    jb gal_komanda_int
    cmp byte ptr[pirmas_baitas], 5Fh
    ja gal_komanda_int
        ;vis tik cia POP
        mov bx, offset k_POP
        jmp vardo_spausdinimas
                            
    gal_komanda_int:
    cmp byte ptr[pirmas_baitas], 0CDh
    jne returnfrom_vardo_spausd ;griztam is vardo spausdinimo, nes nepazistam komandos
        mov bx, offset k_INT
    
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

print_formatui1:
    push ax
    call spausdink_varda
    mov al, byte ptr[reg_dalis]
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

print_formatui0:
    push ax
    push bx
    push cx
    push dx
        mov ah, 9
        mov dx, offset neatp_pradzia
        int 21h
            mov al, byte ptr[pirmas_baitas] ;Argumentas sekanciai procedurai (parametras)
            call print_baita_hexu
        mov ah, 9
        mov dx, offset neatp_pabaiga
        int 21h
    pop dx
    pop cx
    pop bx
    pop ax
RET    

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

;spausdina zodini registra i ekrana
;koks tas registras pasakom AL baite (addr. baito lentoj r/m=000-111, mod=11, w=1)
print_reg_w1:
    push ax
    push bx
    push cx
    push dx
    
    test al, 100b
    je pr_reg_w1_0xx
    jmp pr_reg_w1_1xx
    
        pr_reg_w1_0xx:
        test al, 10b
        je pr_reg_w1_00x
        jmp pr_reg_w1_01x
        
        pr_reg_w1_1xx:
        test al, 10b
        je pr_reg_w1_10x
        jmp pr_reg_w1_11x
        
            pr_reg_w1_00x:
            test al, 1b
            je pr_reg_w1_000
            jmp pr_reg_w1_001
            
            pr_reg_w1_01x:
            test al, 1b
            je pr_reg_w1_010
            jmp pr_reg_w1_011
            
            pr_reg_w1_10x:
            test al, 1b
            je pr_reg_w1_100
            jmp pr_reg_w1_101
            
            pr_reg_w1_11x:
            test al, 1b
            je pr_reg_w1_110
            jmp pr_reg_w1_111
            
                pr_reg_w1_000:
                mov bx, offset r_AX
                jmp reg_w1_spausd
                
                pr_reg_w1_001:
                mov bx, offset r_CX
                jmp reg_w1_spausd
                
                pr_reg_w1_010:
                mov bx, offset r_DX
                jmp reg_w1_spausd
                
                pr_reg_w1_011:
                mov bx, offset r_BX
                jmp reg_w1_spausd
                ;----
                pr_reg_w1_100:
                mov bx, offset r_SP
                jmp reg_w1_spausd
                
                pr_reg_w1_101:
                mov bx, offset r_BP
                jmp reg_w1_spausd
                
                pr_reg_w1_110:
                mov bx, offset r_SI
                jmp reg_w1_spausd
                
                pr_reg_w1_111:
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
   
uzdarymas:
    mov ah, 9
    mov dx, offset enteris
    int 21h

    mov ah, 4Ch
    int 21h
END
