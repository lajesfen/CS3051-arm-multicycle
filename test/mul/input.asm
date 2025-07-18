MOV R1, #0xFF
MOV R2, #0xFF
MOV R3, #0xFF
MOV R4, #0xFF
ORR R1, R1, R2          // R1 = 0xffff
ORR R1, R1, R3          // R1 = 0xffffff
ORR R1, R1, R4          // R1 = 0xffffffff

MOV R2, #2

UMUL {R3,R4}, R1,R2
SMUL {R5,R6}, R1,R2

SUB R7, R4, R6
ADD R8, R5, R3
SUBS R0, R7, R8

BEQ CHECKPOINT1
B ERROR

//CHECKPOINT1:
SMULS {R5,R6}, R1,R2
BLT CHECKPOINT2
B ERROR
//CHECKPOINT2:
MOV R1,#0x80000000
UMULS {R10,R3}, R1,R2
UMULEQ {R10,R3},R3,R10
B END
//ERROR:
MOV R10, #0
//END:

// RESULTADO DEBERIA SER R10=1, 
// SI ES R10=0 INCORRECTO