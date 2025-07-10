MOV R0, #0              // R0 = 0
ADD R1, R0, #5          // R1 = 5
MUL R2, R1, R1          // R2 = 25
UMUL R3, R4, R1, R1     // R3 = 25, R4 = 0
SUB R6, R0, #2          // R6 = -2
SMUL R3, R4, R6, R1     // R3 = -10 (0xFFFFFFF6)
SMUL R3, R4, R6, R6     // R3 = 4
DIV R7, R1, R1          // R7 = 1
SUB R6, R0, #1          // R6 = -1
UMUL R3, R4, R6, R6     // R3 = 1, R4 = 0xFFFFFFFE