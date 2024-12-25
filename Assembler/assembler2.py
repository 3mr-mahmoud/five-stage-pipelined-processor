import re

def is_hex_number(value):
    """Check if the value is a hex number (with or without 0x prefix)"""
    # Remove any comments after #
    value = value.split('#')[0].strip()
    try:
        int(value, 16)
        return True
    except ValueError:
        return False

def convert_to_decimal(value):
    """Convert a hex string to decimal, stripping any '#' comments"""
    # Remove any comments after #
    value = value.split('#')[0].strip()
    # Convert hex to decimal
    try:
        if value.startswith('0x') or value.startswith('0X'):
            return int(value[2:], 16)
        else:
            return int(value, 16)  # Assume hex by default
    except ValueError as e:
        raise ValueError(f"Invalid hex number: {value}")

def assemble_instruction(line):
    # Remove comments from the line
    line = line.split('#')[0].strip()
    
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
    tokens = [t for t in re.split(r'[ ,()]+', line.strip()) if t]
    if not tokens:  # Skip empty lines after removing comments
        return []
        
    instruction = tokens[0]
    operands = tokens[1:]

    print(f"Instruction: {instruction}, Operands: {operands}")

    if instruction not in instruction_set:
        raise ValueError(f"Unknown instruction: {instruction}")

    opcode = instruction_set[instruction]
    binary_line = opcode

    def parse_register(reg):
        if not reg.startswith('R') or not reg[1:].isdigit():
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
        return [binary_line, f"{convert_to_decimal(operands[-1]):016b}"]
    elif instruction in ["LDD", "STD"]:
        binary_line += f"{parse_register(operands[0])}{parse_register(operands[2])}{'000'}"
        return [binary_line, f"{convert_to_decimal(operands[1]):016b}"]
    elif instruction == "LDM":
        binary_line += f"{parse_register(operands[0])}{'000000'}"
        return [binary_line, f"{convert_to_decimal(operands[1]):016b}"]
    elif instruction == "PUSH":
        binary_line += f"{'000'}{'000'}{parse_register(operands[0])}"
    elif instruction == "POP":
        binary_line += f"{parse_register(operands[0])}{'000'}{'000'}"
    elif instruction == "CALL":
        binary_line += f"{'000'}{'000'}{parse_register(operands[0])}"
    elif instruction == "IN":
        binary_line += f"{parse_register(operands[0])}{'000'}{'000'}"
    elif instruction == "OUT":
        binary_line += f"{'000'}{'000'}{parse_register(operands[0])}"
    elif instruction in ["JZ", "JN", "JC", "JMP"]:
        binary_line += f"{'000'}{parse_register(operands[0])}{'000'}"

    # Fill remaining bits with zeros for don't cares
    while len(binary_line) < 16:
        binary_line += "0"

    return [binary_line]

def assemble_file(input_file, output_file):
    max_memory_size = 65535  # Maximum memory size (65536 locations)
    current_address = 0
    memory = ["0000000000000000"] * (max_memory_size + 1)  # Initialize memory with NOPs

    with open(input_file, 'r') as infile:
        lines = infile.readlines()
        
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            
            # Skip empty lines and comments
            if not line or line.startswith('#'):
                i += 1
                continue
                
            # Handle .ORG directive
            if line.startswith('.ORG'):
                # Extract address after .ORG
                org_value = line.split('.ORG')[1].strip().split('#')[0].strip()
                current_address = convert_to_decimal(org_value)
                i += 1
                
                # Handle the immediate value after .ORG if it exists
                if i < len(lines):
                    next_line = lines[i].strip()
                    if next_line and not next_line.startswith('#') and not next_line.startswith('.'):
                        # Check if it's a hex number
                        next_line_value = next_line.split('#')[0].strip()
                        if is_hex_number(next_line_value):
                            value = convert_to_decimal(next_line_value)
                            memory[current_address] = f"{value:016b}"
                            current_address += 1
                            i += 1
                continue

            # Handle regular instructions
            if line and not line.startswith('#'):
                try:
                    binary_lines = assemble_instruction(line)
                    for binary_line in binary_lines:
                        memory[current_address] = binary_line
                        current_address += 1
                except ValueError as e:
                    print(f"Error at line {i+1}: {e}")
                    print(f"Line content: {line}")
            i += 1

    # Write the final memory contents to the output file
    with open(output_file, 'w') as outfile:
        for i in range(max_memory_size + 1):
            outfile.write(memory[i] + '\n')

# Example usage
assemble_file("input.txt", "output.txt")