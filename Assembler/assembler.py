import re

def assemble_instruction(line):
    # Define instruction formats
    instruction_set = {
        "NOP": "0000000",
        "SETC": "0000001",
        "MOV": "0000010",
        "NOT": "0000011",
        "AND": "0000100",
        "INC": "0000101",
        "ADD": "0000110",
        "SUB": "0000111",
        "IADD": "0001000",
        "LDD": "0001001",
        "STD": "0001010",
        "LDM": "0001011",
        "PUSH": "0001100",
        "POP": "0001101",
        "CALL": "0001110",
        "RET": "0001111",
        "RTI": "0010000",
        "IN": "0010001",
        "OUT": "0010010",
        "JZ": "0010011",
        "JN": "0010100",
        "JC": "0010101",
        "JMP": "0010110",
        "INT": "000000",
        "HLT": "1100000",
    }

    # Extract instruction and operands
    tokens = re.split(r'[ ,()]+', line.strip())
    instruction = tokens[0]
    operands = tokens[1:]

    print(f"Instruction: {instruction}, Operands: {operands}")

    if instruction not in instruction_set:
        raise ValueError(f"Unknown instruction: {instruction}")

    opcode = instruction_set[instruction]
    binary_line = opcode

    def parse_register(reg):
        if not reg.startswith('$') or not reg[1:].isdigit():
            raise ValueError(f"Invalid register format: {reg}")
        reg_num = int(reg[1:])
        if reg_num < 0 or reg_num > 7:
            raise ValueError(f"Register out of range: {reg}")
        return f"{reg_num:03b}"

    if instruction in ["NOP", "SETC", "RET", "RTI", "HLT", "INT"]:
        if instruction == "INT":
            if operands[0] == "2":
                binary_line = "10"+binary_line[1:]  # Set the interrupt bit
            else:
                binary_line = "01"+binary_line[1:]  # Set the interrupt bit
        
        binary_line += "000000000"  # Fill don't care bits with zeros
        return [binary_line]  # No operands

    if instruction == "MOV":
        binary_line += f"{parse_register(operands[0])}{'000'}{parse_register(operands[1])}"
    elif instruction == "NOT":
        binary_line += f"{parse_register(operands[0])}{parse_register(operands[1])}{'000'}"
    elif instruction in ["AND", "ADD", "SUB"]:
        binary_line += f"{parse_register(operands[0])}{parse_register(operands[1])}{parse_register(operands[2])}"
    elif instruction == "INC":
        binary_line += f"{parse_register(operands[0])}{parse_register(operands[1])}{'000'}"
    elif instruction == "IADD":
        binary_line += f"{parse_register(operands[0])}{parse_register(operands[1])}{'000'}"
        return [binary_line, f"{int(operands[-1]):016b}"]
    elif instruction in ["LDD", "STD"]:
        binary_line += f"{parse_register(operands[0])}{parse_register(operands[2])}{'000'}"
        return [binary_line, f"{int(operands[1]):016b}"]
    elif instruction == "LDM":
        binary_line += f"{parse_register(operands[0])}{'000000'}"
        return [binary_line, f"{int(operands[1]):016b}"]
    elif instruction == "PUSH":
        binary_line += f"{'000'}{'000'}{parse_register(operands[0])}"
    elif instruction == "POP":
        binary_line += f"{parse_register(operands[0])}{'000'}{'000'}"
    elif instruction == "CALL":
        binary_line += f"{'000'}{'000'}{parse_register(operands[0])}"
    elif instruction in ["IN", "OUT"]:
        binary_line += f"{parse_register(operands[0])}{'000'}{'000'}"
    elif instruction in ["JZ", "JN", "JC", "JMP"]:
        binary_line += f"{'000'}{parse_register(operands[0])}{'000'}"

    # Fill remaining bits with zeros for don't cares
    while len(binary_line) < 16:
        binary_line += "0"

    return [binary_line]

def assemble_file(input_file, output_file):
    max_memory_size = 65535  # Maximum memory size (65536 locations)
    hlt_opcode = "1100000"  # HLT opcode
    hlt_instruction = hlt_opcode + "000000000"  # HLT instruction with padding

    instruction_count = 0
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if line.strip():  # Skip empty lines
                try:
                    binary_lines = assemble_instruction(line)
                    for binary_line in binary_lines:
                        instruction_count += 1
                        outfile.write(binary_line + "\n")
                    
                except ValueError as e:
                    print(f"Error: {e}")
    
        remaining_instructions = max_memory_size - instruction_count
        for i in range(remaining_instructions):
            line = hlt_instruction
            if i != remaining_instructions - 1:
                line += "\n"
            outfile.write(line)  # Write HLT instruction to fill memory

# Example usage
assemble_file("input.txt", "output.txt")
