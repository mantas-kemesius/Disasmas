# Disasmas
Kompiuteriu architektura - disasembleris

TASM: http://klevas.mif.vu.lt/~julius/Tools/asm/TASM.zip
DOS emuliatorius DOSBox: http://www.dosbox.com/
EMU8086: http://www.emu8086.com/


<h1>Asemblerio komandų operacijos kodų sąrašas/h1>

0000 00dw mod reg r/m [poslinkis] – ADD registras += registras/atmintis
0000 010w bojb [bovb] – ADD akumuliatorius += betarpiškas operandas
000sr 110 – PUSH segmento registras
000sr 111 – POP segmento registras
0000 10dw mod reg r/m [poslinkis] – OR registras V registras/atmintis
0000 110w bojb [bovb] – OR akumuliatorius V betarpiškas operandas
0001 00dw mod reg r/m [poslinkis] – ADC registras += registras/axtmintis
0001 010w bojb [bovb] – ADC akumuliatorius += betarpiškas operandas
0001 10dw mod reg r/m [poslinkis] – SBB registras -= registras/atmintis
0001 110w bojb [bovb] – SBB akumuliatorius -= betarpiškas operandas
0010 00dw mod reg r/m [poslinkis] – AND registras & registras/atmintis
0010 010w bojb [bovb] – AND akumuliatorius & betarpiškas operandas
001sr 110 – segmento registro keitimo prefiksas
0010 0111 – DAA
0010 10dw mod reg r/m [poslinkis] – SUB registras -= registras/atmintis
0010 110w bojb [bovb] – SUB akumuliatorius -= betarpiškas operandas
0010 1111 – DAS
0011 00dw mod reg r/m [poslinkis] – XOR registras | registras/atmintis
0011 010w bojb [bovb] – XOR akumuliatorius | betarpiškas operandas
0011 0111 – AAA
0011 10dw mod reg r/m [poslinkis] – CMP registras ~ registras/atmintis
0011 110w bojb [bovb] – CMP akumuliatorius ~ betarpiškas operandas
0011 1111 – AAS
0100 0reg – INC registras (žodinis)
0100 1reg – DEC registras (žodinis)
0101 0reg – PUSH registras (žodinis)
0101 1reg – POP registras (žodinis)
0111 0000 poslinkis – JO žymė
0111 0001 poslinkis – JNO žymė
0111 0010 poslinkis – JNAE žymė; JB žymė; JC žymė
0111 0011 poslinkis – JAE žymė; JNB žymė; JNC žymė
0111 0100 poslinkis – JE žymė; JZ žymė
0111 0101 poslinkis – JNE žymė; JNZ žymė
0111 0110 poslinkis – JBE žymė; JNA žymė
0111 0111 poslinkis – JA žymė; JNBE žymė
0111 1000 poslinkis – JS žymė
0111 1001 poslinkis – JNS žymė
0111 1010 poslinkis – JP žymė; JPE žymė
0111 1011 poslinkis – JNP žymė; JPO žymė
0111 1100 poslinkis – JL žymė; JNGE žymė
0111 1101 poslinkis – JGE žymė; JNL žymė
0111 1110 poslinkis – JLE žymė; JNG žymė
0111 1111 poslinkis – JG žymė; JNLE žymė
1000 00sw mod 000 r/m [poslinkis] bojb [bovb] – ADD registras/atmintis += betarpiškas operandas
1000 00sw mod 001 r/m [poslinkis] bojb [bovb] – OR registras/atmintis V betarpiškas operandas
1000 00sw mod 010 r/m [poslinkis] bojb [bovb] – ADC registras/atmintis += betarpiškas operandas
1000 00sw mod 011 r/m [poslinkis] bojb [bovb] – SBB registras/atmintis -= betarpiškas operandas
1000 00sw mod 100 r/m [poslinkis] bojb [bovb] – AND registras/atmintis & betarpiškas operandas
1000 00sw mod 101 r/m [poslinkis] bojb [bovb] – SUB registras/atmintis -= betarpiškas operandas
1000 00sw mod 110 r/m [poslinkis] bojb [bovb] – XOR registras/atmintis | betarpiškas operandas
1000 00sw mod 111 r/m [poslinkis] bojb [bovb] – CMP registras/atmintis ~ betarpiškas operandas
1000 010w mod reg r/m [poslinkis] – TEST registras ? registras/atmintis
1000 011w mod reg r/m [poslinkis] – XCHG registras  registras/atmintis
1000 10dw mod reg r/m [poslinkis] – MOV registras  registras/atmintis
1000 11d0 mod 0sr r/m [poslinkis] – MOV segmento registras  registras/atmintis
1000 1101 mod reg r/m [poslinkis] – LEA registras  atmintis
1000 1111 mod 000 r/m [poslinkis] – POP registras/atmintis
1001 0000 – NOP; XCHG ax, ax
1001 0reg – XCHG registras  ax
1001 1000 – CBW
1001 1001 – CWD
1001 1010 ajb avb srjb srvb – CALL žymė (išorinis tiesioginis)
1001 1011 – WAIT
1001 1100 – PUSHF
1001 1101 – POPF
1001 1110 – SAHF
1001 1111 – LAHF
1010 000w ajb avb – MOV akumuliatorius  atmintis
1010 001w ajb avb – MOV atmintis  akumuliatorius
1010 010w – MOVSB; MOVSW
1010 011w – CMPSB; CMPSW
1010 100w bojb [bovb] – TEST akumuliatorius ? betarpiškas operandas
1010 101w – STOSB; STOSW
1010 110w – LODSB; LODSW
1010 111w – SCASB; SCASW
1011 wreg bojb [bovb] – MOV registras  betarpiškas operandas
1100 0010 bojb bovb – RET betarpiškas operandas; RETN betarpiškas operandas
1100 0011 – RET; RETN
1100 0100 mod reg r/m [poslinkis] – LES registras  atmintis
1100 0101 mod reg r/m [poslinkis] – LDS registras  atmintis
1100 011w mod 000 r/m [poslinkis] bojb [bovb] – MOV registras/atmintis  betarpiškas operandas
1100 1010 bojb bovb – RETF betarpiškas operandas
1100 1011 – RETF
1100 1100 – INT 3
1100 1101 numeris – INT numeris
1100 1110 – INTO
1100 1111 – IRET
1101 00vw mod 000 r/m [poslinkis] – ROL registras/atmintis, {1; CL}
1101 00vw mod 001 r/m [poslinkis] – ROR registras/atmintis, {1; CL}
1101 00vw mod 010 r/m [poslinkis] – RCL registras/atmintis, {1; CL}
1101 00vw mod 011 r/m [poslinkis] – RCR registras/atmintis, {1; CL}
1101 00vw mod 100 r/m [poslinkis] – SHL registras/atmintis, {1; CL}; SAL registras/atmintis, {1; CL}
1101 00vw mod 101 r/m [poslinkis] – SHR registras/atmintis, {1; CL}
1101 00vw mod 111 r/m [poslinkis] – SAR registras/atmintis, {1; CL}
1101 0100 0000 1010 – AAM
1101 0101 0000 1010 – AAD
1101 0111 – XLAT
1101 1xxx mod yyy r/m [poslinkis] – ESC komanda, registras/atmintis
1110 0000 poslinkis – LOOPNE žymė; LOOPNZ žymė
1110 0001 poslinkis – LOOPE žymė; LOOPZ žymė
1110 0010 poslinkis – LOOP žymė
1110 0011 poslinkis – JCXZ žymė
1110 010w portas – IN akumuliatorius  portas
1110 011w portas – OUT akumuliatorius  portas
1110 1000 pjb pvb – CALL žymė (vidinis tiesioginis)
1110 1001 pjb pvb – JMP žymė (vidinis tiesioginis)
1110 1010 ajb avb srjb srvb – JMP žymė (išorinis tiesioginis)
1110 1011 poslinkis – JMP žymė (vidinis artimas)
1110 110w – IN akumuliatorius  dx portas
1110 111w – OUT akumuliatorius  dx portas
1111 0000 – LOCK
1111 0010 – REPNZ; REPNE
1111 0011 – REP; REPZ; REPE
1111 0100 – HLT
1111 0101 – CMC
1111 011w mod 000 r/m [poslinkis] bojb [bovb] – TEST registras/atmintis ? betarpiškas operandas
1111 011w mod 010 r/m [poslinkis] – NOT registras/atmintis
1111 011w mod 011 r/m [poslinkis] – NEG registras/atmintis
1111 011w mod 100 r/m [poslinkis] – MUL registras/atmintis
1111 011w mod 101 r/m [poslinkis] – IMUL registras/atmintis
1111 011w mod 110 r/m [poslinkis] – DIV registras/atmintis
1111 011w mod 111 r/m [poslinkis] – IDIV registras/atmintis
1111 1000 – CLC
1111 1001 – STC
1111 1010 – CLI
1111 1011 – STI
1111 1100 – CLD
1111 1101 – STD
1111 111w mod 000 r/m [poslinkis] – INC registras/atmintis
1111 111w mod 001 r/m [poslinkis] – DEC registras/atmintis
1111 1111 mod 010 r/m [poslinkis] – CALL adresas (vidinis netiesioginis)
1111 1111 mod 011 r/m [poslinkis] – CALL adresas (išorinis netiesioginis)
1111 1111 mod 100 r/m [poslinkis] – JMP adresas (vidinis netiesioginis)
1111 1111 mod 101 r/m [poslinkis] – JMP adresas (išorinis netiesioginis)
1111 1111 mod 110 r/m [poslinkis] – PUSH registras/atmintis
akumuliatorius – 2 baitų  AX; 1 baito  AL;
ajb – adreso jaunesnysis baitas;
avb – adreso vyresnysis baitas;
bojb – betarpiško operando jaunesnysis baitas;
bovb – betarpiško operando vyresnysis baitas;
[bovb] – betarpiško operando vyresnysis baitas, kuris nėra privalomas;
pjb – poslinkio jaunesnysis baitas;
pvb – poslinkio vyresnysis baitas;
poslinkis – 1 baito dydžio poslinkis;
[poslinkis] – poslinkis, kuris priklausomai nuo mod reikšmės gali būti 1 arba 2 baitų, arba jo iš viso nebūti;
srjb – betarpiško operando, rodančio segmento registro reikšmę jaunesnysis baitas;
srvb – betarpiško operando, rodančio segmento registro reikšmę vyresnysis baitas;
numeris – vieno baito dydžio betarpiškas operandas
portas – vieno baito dydžio porto numeris
dx portas – dx reikšmė naudojama kaip porto numeris
xxx, yyy – naudojama formuojant preprocesoriaus komandos numerį;
