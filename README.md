<h1>Asemblerio komandų operacijos kodų sąrašas</h1>
</br></br>
<h2>Skirstau pagal formatus:</h2>
1000 10dw mod reg r/m [poslinkis] – MOV registras  registras/atmintis</br>
1000 11d0 mod 0sr r/m [poslinkis] – MOV segmento registras  registras/atmintis</br> 
1000 1111 mod 000 r/m [poslinkis] – POP registras/atmintis</br>

</br></br>
</br></br>
<strong>Visi MOV variantai (6):</strong></br>
1000 10dw mod reg r/m [poslinkis] – MOV registras  registras/atmintis</br>
1000 11d0 mod 0sr r/m [poslinkis] – MOV segmento registras  registras/atmintis</br> 
1010 000w ajb avb – MOV akumuliatorius  atmintis</br>
1010 001w ajb avb – MOV atmintis  akumuliatorius</br>
1011 wreg bojb [bovb] – MOV registras  betarpiškas operandas</br>
1100 011w mod 000 r/m [poslinkis] bojb [bovb] – MOV registras/atmintis  betarpiškas operandas</br>
88 - 8B</br>8C - 8E </br>A0 - A1 </br>C2 - C3 </br>B0 - BF </br>C6 - C7</br>

</br></br>
<strong>Visi PUSH variantai (3);</strong></br>
000sr 110 – PUSH segmento registras</br>
0101 0reg – PUSH registras (žodinis)</br>
1111 1111 mod 110 r/m [poslinkis] – PUSH registras/atmintis</br>
06 - 1E</br>50 - 57 </br>FF </br>
</br></br>
<strong>Visi POP variantai (3);</strong></br>
0101 1reg – POP registras (žodinis)</br>
000sr 111 – POP segmento registras</br>
1000 1111 mod 000 r/m [poslinkis] – POP registras/atmintis</br>
58 - 5F</br>07 - 1F</br>8F</br>

</br></br>
<strong>Visi ADD variantai (3);</strong></br>
0000 010w bojb [bovb] – ADD akumuliatorius += betarpiškas operandas</br>
0000 00dw mod reg r/m [poslinkis] – ADD registras += registras/atmintis</br>
1000 00sw mod 000 r/m [poslinkis] bojb [bovb] – ADD registras/atmintis += betarpiškas operandas</br>
04 - 05</br>00 - 03</br>80 - 83</br>
</br></br>
<strong>Visi INC variantai (2);</strong></br>
0100 0reg – INC registras (žodinis)</br>
1111 111w mod 000 r/m [poslinkis] – INC registras/atmintis</br>
40 - 47</br>FE - FF</br>
</br></br>
<strong>Visi DEC variantai (2);</strong></br>
0100 1reg – DEC registras (žodinis)</br>
1111 111w mod 001 r/m [poslinkis] – DEC registras/atmintis</br>
48 - 4F</br>FF - FE</br>
</br></br>
<strong>Visi SUB variantai (3);</strong></br>
0010 110w bojb [bovb] – SUB akumuliatorius -= betarpiškas operandas</br>
1000 00sw mod 101 r/m [poslinkis] bojb [bovb] – SUB registras/atmintis -= betarpiškas operandas</br>
0010 10dw mod reg r/m [poslinkis] – SUB registras -= registras/atmintis</br>
2C - 2D</br>80 - 83</br>28 - 2B</br>
</br></br>
<strong>Visi CMP variantai (3);</strong></br>
0011 10dw mod reg r/m [poslinkis] – CMP registras ~ registras/atmintis</br>
0011 110w bojb [bovb] – CMP akumuliatorius ~ betarpiškas operandas</br>
1000 00sw mod 111 r/m [poslinkis] bojb [bovb] – CMP registras/atmintis ~ betarpiškas operandas</br>
38 - 3B</br>3C - 3B</br>80 - 83</br>
</br></br>
<strong>Komanda MUL;</strong></br>
1111 011w mod 100 r/m [poslinkis] – MUL registras/atmintis</br>
F6 - F7</br>
</br></br>
<strong>Komanda DIV;</strong></br>
1111 011w mod 110 r/m [poslinkis] – DIV registras/atmintis</br>
F6 - F7</br>
</br></br>
<strong>Visi CALL variantai (4);</strong></br>
1001 1010 ajb avb srjb srvb – CALL žymė (išorinis tiesioginis)</br>
1110 1000 pjb pvb – CALL žymė (vidinis tiesioginis)</br>
1111 1111 mod 010 r/m [poslinkis] – CALL adresas (vidinis netiesioginis)</br>
1111 1111 mod 011 r/m [poslinkis] – CALL adresas (išorinis netiesioginis)</br>
9A</br>D8</br>FF</br>FF</br>
</br></br>
<strong>Visi RET variantai (4);</strong></br>
1100 0010 bojb bovb – RET betarpiškas operandas; RETN betarpiškas operandas</br>
1100 0011 – RET; RETN</br>
1100 1010 bojb bovb – RETF betarpiškas operandas</br>
C2</br>C3</br>CA</br>
</br></br>
<strong>Visi JMP variantai (5);</strong></br>
1110 1001 pjb pvb – JMP žymė (vidinis tiesioginis)</br>
1110 1010 ajb avb srjb srvb – JMP žymė (išorinis tiesioginis)</br>
1110 1011 poslinkis – JMP žymė (vidinis artimas)</br>
1111 1111 mod 100 r/m [poslinkis] – JMP adresas (vidinis netiesioginis)</br>
1111 1111 mod 101 r/m [poslinkis] – JMP adresas (išorinis netiesioginis)</br>
E9</br>EA</br>EB</br>FF</br>FF</br>
</br></br>
<strong>Visos sąlyginio valdymo perdavimo komandos (17);</strong></br>
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
B0</br>B1</br>B2</br>B3</br>B4</br>B5</br>B6</br>B7</br>B8</br>B9</br>BA</br>BB</br>BC</br>BD</br>BE</br>
</br></br>
<strong>Komanda LOOP;</strong></br>
1110 0010 poslinkis – LOOP žymė</br>
D2</br>
</br></br>
<strong>Komanda INT;</strong></br>
1100 1101 numeris – INT numeris</br>
CD</br>
</br></br></br></br></br></br>
<hr>
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

<hr>
<h2>Reikalinga paleidimui</h2>
TASM: http://klevas.mif.vu.lt/~julius/Tools/asm/TASM.zip<br>
DOS emuliatorius DOSBox: http://www.dosbox.com/<br>
EMU8086: http://www.emu8086.com/<br>
