# Disasmas
Kompiuteriu architektura - disasembleris

<h1>Asemblerio komandų operacijos kodų sąrašas</h1>

0000 00dw mod reg r/m [poslinkis] – ADD registras += registras/atmintis</br>
0000 010w bojb [bovb] – ADD akumuliatorius += betarpiškas operandas</br>
000sr 110 – PUSH segmento registras</br>
000sr 111 – POP segmento registras</br>
0000 10dw mod reg r/m [poslinkis] – OR registras V registras/atmintis</br>
0000 110w bojb [bovb] – OR akumuliatorius V betarpiškas operandas</br>
0001 00dw mod reg r/m [poslinkis] – ADC registras += registras/axtmintis</br>
0001 010w bojb [bovb] – ADC akumuliatorius += betarpiškas operandas</br>
0001 10dw mod reg r/m [poslinkis] – SBB registras -= registras/atmintis</br>
0001 110w bojb [bovb] – SBB akumuliatorius -= betarpiškas operandas</br>
0010 00dw mod reg r/m [poslinkis] – AND registras & registras/atmintis</br>
0010 010w bojb [bovb] – AND akumuliatorius & betarpiškas operandas</br>
001sr 110 – segmento registro keitimo prefiksas</br>
0010 0111 – DAA</br>
0010 10dw mod reg r/m [poslinkis] – SUB registras -= registras/atmintis</br>
0010 110w bojb [bovb] – SUB akumuliatorius -= betarpiškas operandas</br>
0010 1111 – DAS</br>
0011 00dw mod reg r/m [poslinkis] – XOR registras | registras/atmintis</br>
0011 010w bojb [bovb] – XOR akumuliatorius | betarpiškas operandas</br>
0011 0111 – AAA</br>
0011 10dw mod reg r/m [poslinkis] – CMP registras ~ registras/atmintis</br>
0011 110w bojb [bovb] – CMP akumuliatorius ~ betarpiškas operandas</br>
0011 1111 – AAS</br>
0100 0reg – INC registras (žodinis)</br>
0100 1reg – DEC registras (žodinis)</br>
0101 0reg – PUSH registras (žodinis)</br>
0101 1reg – POP registras (žodinis)</br>
0111 0000 poslinkis – JO žymė</br>
0111 0001 poslinkis – JNO žymė</br>
0111 0010 poslinkis – JNAE žymė; JB žymė; JC žymė</br>
0111 0011 poslinkis – JAE žymė; JNB žymė; JNC žymė</br>
0111 0100 poslinkis – JE žymė; JZ žymė</br>
0111 0101 poslinkis – JNE žymė; JNZ žymė</br>
0111 0110 poslinkis – JBE žymė; JNA žymė</br>
0111 0111 poslinkis – JA žymė; JNBE žymė</br>
0111 1000 poslinkis – JS žymė</br>
0111 1001 poslinkis – JNS žymė</br>
0111 1010 poslinkis – JP žymė; JPE žymė</br>
0111 1011 poslinkis – JNP žymė; JPO žymė</br>
0111 1100 poslinkis – JL žymė; JNGE žymė</br>
0111 1101 poslinkis – JGE žymė; JNL žymė</br>
0111 1110 poslinkis – JLE žymė; JNG žymė</br>
0111 1111 poslinkis – JG žymė; JNLE žymė</br>
1000 00sw mod 000 r/m [poslinkis] bojb [bovb] – ADD registras/atmintis += betarpiškas operandas</br>
1000 00sw mod 001 r/m [poslinkis] bojb [bovb] – OR registras/atmintis V betarpiškas operandas</br>
1000 00sw mod 010 r/m [poslinkis] bojb [bovb] – ADC registras/atmintis += betarpiškas operandas</br>
1000 00sw mod 011 r/m [poslinkis] bojb [bovb] – SBB registras/atmintis -= betarpiškas operandas</br>
1000 00sw mod 100 r/m [poslinkis] bojb [bovb] – AND registras/atmintis & betarpiškas operandas</br>
1000 00sw mod 101 r/m [poslinkis] bojb [bovb] – SUB registras/atmintis -= betarpiškas operandas</br>
1000 00sw mod 110 r/m [poslinkis] bojb [bovb] – XOR registras/atmintis | betarpiškas operandas</br>
1000 00sw mod 111 r/m [poslinkis] bojb [bovb] – CMP registras/atmintis ~ betarpiškas operandas</br>
1000 010w mod reg r/m [poslinkis] – TEST registras ? registras/atmintis</br>
1000 011w mod reg r/m [poslinkis] – XCHG registras  registras/atmintis</br>
1000 10dw mod reg r/m [poslinkis] – MOV registras  registras/atmintis</br>
1000 11d0 mod 0sr r/m [poslinkis] – MOV segmento registras  registras/atmintis</br>
1000 1101 mod reg r/m [poslinkis] – LEA registras  atmintis</br>
1000 1111 mod 000 r/m [poslinkis] – POP registras/atmintis</br>
1001 0000 – NOP; XCHG ax, ax</br>
1001 0reg – XCHG registras  ax</br>
1001 1000 – CBW</br>
1001 1001 – CWD</br>
1001 1010 ajb avb srjb srvb – CALL žymė (išorinis tiesioginis)</br>
1001 1011 – WAIT</br>
1001 1100 – PUSHF</br>
1001 1101 – POPF</br>
1001 1110 – SAHF</br>
1001 1111 – LAHF</br>
1010 000w ajb avb – MOV akumuliatorius  atmintis</br>
1010 001w ajb avb – MOV atmintis  akumuliatorius</br>
1010 010w – MOVSB; MOVSW</br>
1010 011w – CMPSB; CMPSW</br>
1010 100w bojb [bovb] – TEST akumuliatorius ? betarpiškas operandas</br>
1010 101w – STOSB; STOSW</br>
1010 110w – LODSB; LODSW</br>
1010 111w – SCASB; SCASW</br>
1011 wreg bojb [bovb] – MOV registras  betarpiškas operandas</br>
1100 0010 bojb bovb – RET betarpiškas operandas; RETN betarpiškas operandas</br>
1100 0011 – RET; RETN</br>
1100 0100 mod reg r/m [poslinkis] – LES registras  atmintis</br>
1100 0101 mod reg r/m [poslinkis] – LDS registras  atmintis</br>
1100 011w mod 000 r/m [poslinkis] bojb [bovb] – MOV registras/atmintis  betarpiškas operandas</br>
1100 1010 bojb bovb – RETF betarpiškas operandas</br>
1100 1011 – RETF</br>
1100 1100 – INT 3</br>
1100 1101 numeris – INT numeris</br>
1100 1110 – INTO</br>
1100 1111 – IRET</br>
1101 00vw mod 000 r/m [poslinkis] – ROL registras/atmintis, {1; CL}</br>
1101 00vw mod 001 r/m [poslinkis] – ROR registras/atmintis, {1; CL}</br>
1101 00vw mod 010 r/m [poslinkis] – RCL registras/atmintis, {1; CL}</br>
1101 00vw mod 011 r/m [poslinkis] – RCR registras/atmintis, {1; CL}</br>
1101 00vw mod 100 r/m [poslinkis] – SHL registras/atmintis, {1; CL}; SAL registras/atmintis, {1; CL}</br>
1101 00vw mod 101 r/m [poslinkis] – SHR registras/atmintis, {1; CL}</br>
1101 00vw mod 111 r/m [poslinkis] – SAR registras/atmintis, {1; CL}</br>
1101 0100 0000 1010 – AAM</br>
1101 0101 0000 1010 – AAD</br>
1101 0111 – XLAT</br>
1101 1xxx mod yyy r/m [poslinkis] – ESC komanda, registras/atmintis</br>
1110 0000 poslinkis – LOOPNE žymė; LOOPNZ žymė</br>
1110 0001 poslinkis – LOOPE žymė; LOOPZ žymė</br>
1110 0010 poslinkis – LOOP žymė</br>
1110 0011 poslinkis – JCXZ žymė</br>
1110 010w portas – IN akumuliatorius  portas</br>
1110 011w portas – OUT akumuliatorius  portas</br>
1110 1000 pjb pvb – CALL žymė (vidinis tiesioginis)</br>
1110 1001 pjb pvb – JMP žymė (vidinis tiesioginis)</br>
1110 1010 ajb avb srjb srvb – JMP žymė (išorinis tiesioginis)</br>
1110 1011 poslinkis – JMP žymė (vidinis artimas)</br>
1110 110w – IN akumuliatorius  dx portas</br>
1110 111w – OUT akumuliatorius  dx portas</br>
1111 0000 – LOCK</br>
1111 0010 – REPNZ; REPNE</br>
1111 0011 – REP; REPZ; REPE</br>
1111 0100 – HLT</br>
1111 0101 – CMC</br>
1111 011w mod 000 r/m [poslinkis] bojb [bovb] – TEST registras/atmintis ? betarpiškas operandas</br>
1111 011w mod 010 r/m [poslinkis] – NOT registras/atmintis</br>
1111 011w mod 011 r/m [poslinkis] – NEG registras/atmintis</br>
1111 011w mod 100 r/m [poslinkis] – MUL registras/atmintis</br>
1111 011w mod 101 r/m [poslinkis] – IMUL registras/atmintis</br>
1111 011w mod 110 r/m [poslinkis] – DIV registras/atmintis</br>
1111 011w mod 111 r/m [poslinkis] – IDIV registras/atmintis</br>
1111 1000 – CLC</br>
1111 1001 – STC</br>
1111 1010 – CLI</br>
1111 1011 – STI</br>
1111 1100 – CLD</br>
1111 1101 – STD</br>
1111 111w mod 000 r/m [poslinkis] – INC registras/atmintis</br>
1111 111w mod 001 r/m [poslinkis] – DEC registras/atmintis</br>
1111 1111 mod 010 r/m [poslinkis] – CALL adresas (vidinis netiesioginis)</br>
1111 1111 mod 011 r/m [poslinkis] – CALL adresas (išorinis netiesioginis)</br>
1111 1111 mod 100 r/m [poslinkis] – JMP adresas (vidinis netiesioginis)</br>
1111 1111 mod 101 r/m [poslinkis] – JMP adresas (išorinis netiesioginis)</br>
1111 1111 mod 110 r/m [poslinkis] – PUSH registras/atmintis</br>

<h3>VERTIMAS:</h3>
akumuliatorius – 2 baitų  AX; 1 baito  AL;</br>
ajb – adreso jaunesnysis baitas;</br>
avb – adreso vyresnysis baitas;</br>
bojb – betarpiško operando jaunesnysis baitas;</br>
bovb – betarpiško operando vyresnysis baitas;</br>
[bovb] – betarpiško operando vyresnysis baitas, kuris nėra privalomas;</br>
pjb – poslinkio jaunesnysis baitas;</br>
pvb – poslinkio vyresnysis baitas;</br>
poslinkis – 1 baito dydžio poslinkis;</br>
[poslinkis] – poslinkis, kuris priklausomai nuo mod reikšmės gali būti 1 arba 2 baitų, arba jo iš viso nebūti;</br>
srjb – betarpiško operando, rodančio segmento registro reikšmę jaunesnysis baitas;</br>
srvb – betarpiško operando, rodančio segmento registro reikšmę vyresnysis baitas;</br>
numeris – vieno baito dydžio betarpiškas operandas</br>
portas – vieno baito dydžio porto numeris</br>
dx portas – dx reikšmė naudojama kaip porto numeris</br>
xxx, yyy – naudojama formuojant preprocesoriaus komandos numerį;</br>


<h2>Reikalinga paleidimui</h2>
TASM: http://klevas.mif.vu.lt/~julius/Tools/asm/TASM.zip<br>
DOS emuliatorius DOSBox: http://www.dosbox.com/<br>
EMU8086: http://www.emu8086.com/<br>
