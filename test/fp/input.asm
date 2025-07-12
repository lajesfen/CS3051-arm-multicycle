MOV R0, #128;

MOV R1, 0.0f;   // X VALUE 
MOV R2, 3.0f;   // DX VALUE
MOV R3, 0.1f;  // DT

MOV R4, -0.4f;   // A
MOV R5, 0.1f;   // B

//FOR:
MOV R6, R2;
FMUL R6, R6, R3;

MOV R7,R1;
FMUL R7, R7, R4; // A * X
MOV R8,R2;
FMUL R8, R8, R5; // B * DX

FADD R7, R7, R8; // A * X + B * DX
FMUL R7, R7, R3; // DT * (A * X + B * DX)

FADD R1, R1, R6; // X = X + DF(X,DX)
FADD R2, R2, R7; // DX = DX + DF(V,DT)
SUBS R0, R0, #1;
BEQ END_FOR;
B FOR;

//END_FOR:


// RESULTADO DEBERIA SER R1=11.4 (0x41366666) -> 32 bits