import re
import sys


TOKEN_SPEC = {
    "LABEL": r"[A-Za-z_][A-Za-z0-9_]*:",
    "REG": r"R(?:1[0-5]|[0-9])",
    "POINTER": r"[A-Za-z_][A-Za-z0-9_]*",
    # "OP": r'[A-Z]{1,5}(EQ|NE|CS|CC|MI|PL|VS|VC|HI|LS|GE|LT|GT|LE|AL)?S?',
    "IMM": r"#(?:0x[0-9a-fA-F]+|[0-9]+)",
    "COMMA": r",",
    "S_COLON": r";",
    "L_BRACKET": r"\\[",
    "R_BRACKET": r"\\]",
}


class ARM_Assembler:
    def __init__(self):
        pattern = "|".join(f"(?P<{name}>{regex})" for name, regex in TOKEN_SPEC.items())
        self.regex = re.compile(pattern, re.IGNORECASE)

        #################################
        #                               #
        # You can change encodings HERE #
        #                               #
        #################################

        self.dp_instr = {
            "AND": 0b0010,
            "SUB": 0b0001,
            "ADD": 0b0000,
            "ORR": 0b0011,
            "MOV": 0b1101,
            "LSL": 0b1101,
            "LSR": 0b1101,
            "MUL": 0b0100,
        }
        self.mem_instr = {
            "STR": 0b00,
            "LDR": 0b01,
            "STRB": 0b10,
            "LDRB": 0b11,
        }
        self.b_instr = {"B": 0b0}
        self.conds = {
            "EQ": 0b0000,
            "NE": 0b0001,
            "CS": 0b0010,
            "HS": 0b0010,
            "CC": 0b0011,
            "LO": 0b0011,
            "MI": 0b0100,
            "PL": 0b0101,
            "VS": 0b0110,
            "VC": 0b0111,
            "HI": 0b1000,
            "LS": 0b1001,
            "GE": 0b1010,
            "LT": 0b1011,
            "GT": 0b1100,
            "LE": 0b1101,
            "AL": 0b1110,
        }

        #
        # Use this section to implement you own encodings with their respective "VALUE", these will have OP type of 11
        #
        self.spc_instr = {
            "ADDLNG": 0,  # Special instruction example
        }

        self.labels = {}
        self.valid_ops = (
            list(self.dp_instr.keys())
            + list(self.mem_instr.keys())
            + list(self.b_instr.keys())
            + list(self.spc_instr.keys())
        )

    # Only for tokenization purposes
    def tokenize_instruction(self, instr: str):
        tokens = []
        for match in self.regex.finditer(instr):
            kind = match.lastgroup
            value = match.group()

            if kind == "POINTER":
                possible_instr, cond, S = self.decode_mnemonic(value)
                if possible_instr in self.valid_ops and cond in self.conds:
                    kind = "OP"
            tokens.append((kind, value))
        return tokens

    def decode_mnemonic(self, instr: str):
        instr = instr.upper()
        flags = instr.endswith("S")
        if flags:
            instr = instr[:-1]
        cond = "AL"
        for suffix in self.conds:
            if instr.endswith(suffix):
                cond = suffix
                instr = instr[: -len(suffix)]
                break
        return instr, cond, flags

    #
    # MAIN INSTRUCTION ENCODER
    #
    def assemble_instruction(self, tokens: list[tuple[str, str]], pc) -> int:
        def reg_val(r):
            return int(r[1:])

        def imm_val(s):
            return int(s[1:], 0)

        it = iter(tokens)
        w = next(it)

        # IGNORE LABEL
        while w[0] == "LABEL":
            if len(tokens) > 1:
                w = next(it)
            else:
                return -1

        if w[0] != "OP":
            raise RuntimeError(f"Instrucción no implementada: {w[1]}")

        instr, cond, S = self.decode_mnemonic(w[1])

        # OP == DP
        if instr in self.dp_instr:
            regs = [reg_val(v) for (k, v) in tokens if k == "REG"]
            imms = [imm_val(v) for (k, v) in tokens if k == "IMM"]

            # Custom DP exceptions
            if instr == "MOV":
                S = 0
                Rn = 0
                cmd = self.dp_instr[instr]

                if len(regs) == 1 and len(imms) == 1:
                    # MOV Rd, #imm
                    Rd = regs[0]
                    operand2 = imms[0]
                    I = 1
                elif len(regs) == 2 and len(imms) == 0:
                    # MOV Rd, Rm
                    Rd, Rm = regs
                    I = 0
                    operand2 = Rm
                else:
                    raise RuntimeError(
                        f"Formato MOV no válido: se esperaba MOV Rd, Rm o MOV Rd, #imm"
                    )

                return (
                    (self.conds[cond] << 28)
                    | (0b00 << 26)
                    | (I << 25)
                    | (cmd << 21)
                    | (S << 20)
                    | (Rn << 16)
                    | (Rd << 12)
                    | operand2
                )

            if instr in ["LSL", "LSR"]:
                if len(regs) != 2 or not imms:
                    raise RuntimeError(
                        f"Formato {instr} no soportado: {instr} Rd, Rm, #imm"
                    )
                Rd, Rm = regs
                shift_imm = imms[0]
                shift_type = 0b00 if instr == "LSL" else 0b01
                shift = (shift_imm << 7) | (shift_type << 5) | Rm
                cmd = self.dp_instr[instr]
                return (
                    (self.conds[cond] << 28)
                    | (0b00 << 26)
                    | (0 << 25)
                    | (cmd << 21)
                    | (S << 20)
                    | (0 << 16)
                    | (Rd << 12)
                    | shift
                )

            # General purpose encoding (eor, add, sub, etc)
            if len(regs) == 3:
                Rd, Rn, Rm = regs
                I = 0
                operand2 = Rm
            elif len(regs) == 2 and imms:
                Rd, Rn = regs
                I = 1
                operand2 = imms[0]
            else:
                raise RuntimeError("Formato DP inválido")
            cmd = self.dp_instr[instr]

            return (
                (self.conds[cond] << 28)
                | (0b00 << 26)
                | (I << 25)
                | (cmd << 21)
                | (S << 20)
                | (Rn << 16)
                | (Rd << 12)
                | operand2
            )

        # OP == MEM
        if instr in self.mem_instr:
            regs = [reg_val(v) for (k, v) in tokens if k == "REG"]
            if len(regs) != 2:
                raise RuntimeError("Formato MEM inválido")
            Rd, Rn = regs
            code = self.mem_instr[instr]
            L = code & 1
            B = (code >> 1) & 1
            return (
                (self.conds[cond] << 28)
                | (1 << 26)
                | (1 << 24)
                | (Rn << 16)
                | (Rd << 12)
                | (B << 22)
                | (L << 20)
            )

        # OP == B
        if instr in self.b_instr:
            label_tok = next((v for (k, v) in tokens if k == "POINTER"), None)
            if label_tok is None:
                raise RuntimeError("Falta label en B")
            if label_tok not in self.labels:
                raise RuntimeError(f"Label no definido: {label_tok}")
            offset = self.labels[label_tok] - (pc + 2)
            return (self.conds[cond] << 28) | (0b101 << 25) | (offset & 0xFFFFFF)

        #
        # Implement your own special encodings here with OP == SPC
        #
        if instr in self.spc_instr:
            # Example of fictional function with 4 registers input
            regs = [reg_val(v) for (k, v) in tokens if k == "REG"]
            if len(regs) != 4:
                raise RuntimeError(f"{instr} requiere 4 registros")

            # Make sure register numbers are between 0-15
            RdLo, RdHi, RmLo, RmHi = regs  # The are already ints

            # Simple example codification
            return (
                (self.conds[cond] << 28)
                | (0b11 << 26)
                | (self.spc_instr[instr] << 20)
                | (RdLo << 16)
                | (RdHi << 12)
                | (RmLo << 8)
                | (RmHi << 4)
            )

        raise RuntimeError(f"Instrucción no implementada: {instr}")

    def assemble_program(self, program: str) -> list[int]:
        lines = program.strip().splitlines()
        lines = [l.split('//', 1)[0].strip() for l in lines]
        lines = [l for l in lines if l != ""]

        extract = []
        token_lines = []
        pc = 0  
        for line in lines:
            tokens = self.tokenize_instruction(line)
            if not tokens:
                continue

            if tokens[0][0] == "LABEL":
                label_name = tokens[0][1][:-1]
                self.labels[label_name] = pc  # No se incrementa el PC
                # ¿Hay una instrucción en esta línea?
                if len(tokens) > 1:
                    instr_tokens = tokens[1:]
                    extract.append(line)
                    token_lines.append((pc, instr_tokens))
                    pc += 1  # Ahora sí hay instrucción
            else:
                extract.append(line)
                token_lines.append((pc, tokens))
                pc += 1  # Instrucción normal

        result = []
        for pc_val, tokens in token_lines:
            result.append(self.assemble_instruction(tokens, pc_val))
        return result, extract



#
# main entrypoint, reads asm and writes to file
#
if __name__ == "__main__":
    print("ARMv7 - Simple assembler. (Arch - CS2201) - 2025")
    if len(sys.argv) < 2:
        print("Execute as: python asm.py <input file> [<output file>]")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else "memfile.mem"

    assembler = ARM_Assembler()
    with open(input_file, "r") as infile:
        source_code = infile.read()

    lines = source_code.strip().splitlines()
    lines = [l for l in lines if l != ""]
    instrs, extract = assembler.assemble_program(source_code)

    print("\n== Instructions ==")
    for i, instr in enumerate(instrs):
        text = extract[i].lstrip().ljust(18)
        print(f"{i:02d} {text} : 0x{instr:08X}")

    with open(output_file, "w") as f:
        for instr in instrs:
            f.write(f"{instr:08X}\n")

    print(f"\nSUCCESS: Hex memory written to {output_file}")
