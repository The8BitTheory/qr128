#RetroDevStudio.MetaData.BASIC:7169,BASIC V7.0,uppercase,10,10
1 GRAPHIC1:GRAPHIC0:GRAPHIC5
5 BANK 15
10 T$="HTTPS://WWW.FORUM64.DE/INDEX.PHP?THREAD/141120-HALLOWEEN-LEVTY-SPEZIAL-GRUSELSCHOCKER-TURNIER/"
20 I=POINTER(T$)
30 BANK1:P1=PEEK(I+1):P2=PEEK(I+2):P=PEEK(I):BANK15

35 PRINT "CALLING INIT"
40 SYS DEC("1300"),P,P1,P2

45 PRINT "CALLING P2A"
50 SYS DEC("1303")

55 PRINT "CALLING BYTES2STREAM"
60 SYS DEC("1306")

65 PRINT "CALLING CALC-XOR-MASKS"
70 SYS DEC("1309")

75 PRINT "CALLING RS"
80 SYS DEC("130C")

85 PRINT "CALLING WRITE PATTERNS"
90 SYS DEC("130F")


95 REM PRINT "CALLING STREAM2MODULE"
100 REM SYS DEC("1312")



6000 SLOW:REM OUTPUT MATRIX TO SCREEN
6103 DIM CH$(15)
6104 CH$(0)=CHR$(32):CH$(1)=CHR$(190):CH$(2)=CHR$(188):CH$(3)=CHR$(18)+CHR$(162)+CHR$(146)
6105 CH$(4)=CHR$(187):CH$(5)=CHR$(161):CH$(6)=CHR$(18)+CHR$(191)+CHR$(146):CH$(7)=CHR$(18)+CHR$(172)+CHR$(146)
6106 CH$(8)=CHR$(172):CH$(9)=CHR$(191):CH$(10)=CHR$(18)+CHR$(161)+CHR$(146):CH$(11)=CHR$(18)+CHR$(187)+CHR$(146)
6107 CH$(12)=CHR$(162):CH$(13)=CHR$(18)+CHR$(188)+CHR$(146):CH$(14)=CHR$(18)+CHR$(190)+CHR$(146):CH$(15)=CHR$(18)+CHR$(32)+CHR$(146)

6150 SYS DEC("1315")
6160 PB=1
6170 PRINT "PRINTING VALUES THAT MATCH AND "PB

#6110 GOTO 6300
# R:ROW
# C:COL
# O:OFFSET
# F:START OF MATRIX
# G:END OF MATRIX
6200 BANK0:F=PEEK(1000)+PEEK(1001)*256:L=PEEK(1002)
6210 PRINT "START OF MATRIX="F", L="L
6220 O=F:C=0:R=0:GRAPHIC0:COLOR5,1:COLOR0,2:COLOR4,2:PRINT"":PRINT " ";

6222 DO WHILE R<(L-1)/2

6228  FT=4

6229  PO=PEEK(O)
6230  IF ((PO AND 64)=64) THEN V1=XOR(POAND1,ABS((PO AND FT)=FT)):ELSE V1=ABS((POANDPB)=PB)

6231  PO=PEEK(O+1)
6232  IF ((PO AND 64)=64) THEN V2=XOR(POAND1,ABS((PO AND FT)=FT)):ELSE V2=ABS((POANDPB)=PB)

6233  PO=PEEK(O+L)
6234  IF ((PO AND 64)=64) THEN V3=XOR(POAND1,ABS((PO AND FT)=FT)):ELSE V3=ABS((POANDPB)=PB)

6235  PO=PEEK(O+1+L)
6236  IF ((PO AND 64)=64) THEN V4=XOR(POAND1,ABS((PO AND FT)=FT)):ELSE V4=ABS((POANDPB)=PB)

6240  IF C<L-1 THEN V=V1+V2*2+V3*4+V4*8:ELSE V=V1+V3*4

6250  PRINT CH$(V);
6260  O=O+2
6265  C=C+2:IF C >= L THEN O=O+L-1:C=0:R=R+1:PRINT" ":PRINT" ";
6270 LOOP

# LAST ROW IS HANDLED INDIVIDUALLY
6271 FOR Y=0TO(L-1)/2

6273  PO=PEEK(O)
6274  IF ((PO AND 64)=64) THEN V1=XOR(POAND1,ABS((PO AND FT)=FT)):ELSE V1=ABS((POANDPB)=PB)

6275  PO=PEEK(O+1)
6276  IF ((PO AND 64)=64) THEN V2=XOR(POAND1,ABS((PO AND FT)=FT)):ELSE V2=ABS((POANDPB)=PB)

6277  IF C<L-1 THEN V=V1+V2*2:ELSE V=V1
6279  PRINT CH$(V);
6281  O=O+2:C=C+2
6283 NEXT
6285 PRINT " "

6290 PRINT:GRAPHIC5

6300 INPUT "WHICH AND VALUE TO PRINT";I$
6305 IF I$="X" THEN 6400
6310 PB=VAL(I$)
6320 GOTO 6170


6400 BANK15