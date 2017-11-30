<h1>Asemblerio komandų operacijos kodų sąrašas</h1>
</br></br>
<strong>Visi MOV variantai (6):</strong></br>
1. 1000 10dw mod reg r/m [poslinkis] – MOV registras  registras/atmintis</br>
2. 1000 11d0 mod 0sr r/m [poslinkis] – MOV segmento registras  registras/atmintis</br> 
3. 1010 000w ajb avb – MOV akumuliatorius  atmintis</br>
4. 1010 001w ajb avb – MOV atmintis  akumuliatorius</br>
5. 1011 wreg bojb [bovb] – MOV registras  betarpiškas operandas</br>
6. 1100 011w mod 000 r/m [poslinkis] bojb [bovb] – MOV registras/atmintis  betarpiškas operandas</br>
1. 88 - 8B  </br>2. 8C - 8E </br>3. A0 - A1 </br>4. C2 - C3 </br>5. B0 - BF </br>6. C6 - C7</br>

</br></br>
<strong>Visi PUSH variantai (3);</strong></br>
000sr 110 – PUSH segmento registras</br>
0101 0reg – PUSH registras (žodinis)</br>
1111 1111 mod 110 r/m [poslinkis] – PUSH registras/atmintis</br>
</br></br>
<strong>Visi POP variantai (3);</strong></br>
0101 1reg – POP registras (žodinis)</br>
000sr 111 – POP segmento registras</br>
1000 1111 mod 000 r/m [poslinkis] – POP registras/atmintis</br>
</br></br>
<strong>Visi ADD variantai (3);</strong></br>
0000 010w bojb [bovb] – ADD akumuliatorius += betarpiškas operandas</br>
0000 00dw mod reg r/m [poslinkis] – ADD registras += registras/atmintis</br>
1000 00sw mod 000 r/m [poslinkis] bojb [bovb] – ADD registras/atmintis += betarpiškas operandas</br>
</br></br>
<strong>Visi INC variantai (2);</strong></br>
0100 0reg – INC registras (žodinis)</br>
1111 111w mod 000 r/m [poslinkis] – INC registras/atmintis</br>
</br></br>
<strong>Visi DEC variantai (2);</strong></br>
0100 1reg – DEC registras (žodinis)</br>
1111 111w mod 001 r/m [poslinkis] – DEC registras/atmintis</br>
</br></br>
<strong>Visi SUB variantai (3);</strong></br>
0010 110w bojb [bovb] – SUB akumuliatorius -= betarpiškas operandas</br>
1000 00sw mod 101 r/m [poslinkis] bojb [bovb] – SUB registras/atmintis -= betarpiškas operandas</br>
0010 10dw mod reg r/m [poslinkis] – SUB registras -= registras/atmintis</br>
</br></br>
<strong>Visi CMP variantai (3);</strong></br>
0011 10dw mod reg r/m [poslinkis] – CMP registras ~ registras/atmintis</br>
0011 110w bojb [bovb] – CMP akumuliatorius ~ betarpiškas operandas</br>
1000 00sw mod 111 r/m [poslinkis] bojb [bovb] – CMP registras/atmintis ~ betarpiškas operandas</br>
</br></br>
<strong>Komanda MUL;</strong></br>
1111 011w mod 100 r/m [poslinkis] – MUL registras/atmintis</br>
</br></br>
<strong>Komanda DIV;</strong></br>
1111 011w mod 110 r/m [poslinkis] – DIV registras/atmintis</br>
</br></br>
<strong>Visi CALL variantai (4);</strong></br>
1001 1010 ajb avb srjb srvb – CALL žymė (išorinis tiesioginis)</br>
1110 1000 pjb pvb – CALL žymė (vidinis tiesioginis)</br>
1111 1111 mod 010 r/m [poslinkis] – CALL adresas (vidinis netiesioginis)</br>
1111 1111 mod 011 r/m [poslinkis] – CALL adresas (išorinis netiesioginis)</br>
</br></br>
<strong>Visi RET variantai (4);</strong></br>
1100 0010 bojb bovb – RET betarpiškas operandas; RETN betarpiškas operandas</br>
1100 0011 – RET; RETN</br>
1100 1010 bojb bovb – RETF betarpiškas operandas</br>
1100 1011 – RETF</br>
1100 1111 – IRET</br>
</br></br>
<strong>Visi JMP variantai (5);</strong></br>
1110 1001 pjb pvb – JMP žymė (vidinis tiesioginis)</br>
1110 1010 ajb avb srjb srvb – JMP žymė (išorinis tiesioginis)</br>
1110 1011 poslinkis – JMP žymė (vidinis artimas)</br>
1111 1111 mod 100 r/m [poslinkis] – JMP adresas (vidinis netiesioginis)</br>
1111 1111 mod 101 r/m [poslinkis] – JMP adresas (išorinis netiesioginis)</br>
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
</br></br>
<strong>Komanda LOOP;</strong></br>
1110 0010 poslinkis – LOOP žymė</br>
</br></br>
<strong>Komanda INT;</strong></br>
1100 1101 numeris – INT numeris</br>
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
