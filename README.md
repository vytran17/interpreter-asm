# Assembly Language Interpreter

## Overview

This project is an assembly language interpreter written in MIPS assembly language. It is designed to read, parse, and execute a set of predefined instructions from the user input. The interpreter supports various operations, including managing labels, instructions, and symbols.

## Features

- **Input Buffer:** Can read lines of assembly code with a maximum of 256 characters.
- **Symbol Table:** Supports up to 100 entries for label management and symbol resolution.
- **Token Management:** Efficient handling and parsing of tokens from input.
- **Memory Management:** Manages a symbol table, token table, and character table for efficient parsing and execution.

## Data Structures

- **LOC:** Initializes the location counter.
- **tabToken:** A table for tokens generated during parsing.
- **tabSym:** A symbol table for managing labels and symbols.
- **inBuf:** A buffer to hold the input line.
- **MAX_ENTRIES:** The maximum number of entries in the symbol table.
- **prompt:** Prompt displayed to the user.
- **tabChar:** A lookup table for character-specific values used in parsing.

## Usage

1. **Load and Initialize:** Load initial values for the location counter and tables.
2. **Read Input:** Continuously read lines of input, ending with the `#` character.
3. **Parse Tokens:** Parse the input line into tokens and resolve symbols and labels.
4. **Execute:** Based on the parsed tokens, perform the appropriate actions, update the location counter, and handle labels and instructions.
5. **Output:** Print the symbol table and manage internal states.

## Assembly Sections

- `.data`: Defines all data needed for execution, including space reservations for tables and buffers.
- `.text`: Contains the main executable code including subroutines for reading input, parsing tokens, handling labels, and managing memory.

## Commands and Control Flow

The interpreter supports various commands and control structures, handling different token types and assembly instructions as per user input. It handles label definitions and usage, instruction parsing, and parameter management during runtime.

## Running the Interpreter

To run this interpreter, load the assembly file into a MIPS simulator that supports the MIPS instruction set. Follow the prompts to input assembly code, which will be interpreted and executed line by line.

## Dependencies

This project requires a MIPS environment or simulator for execution. No additional software dependencies are necessary.

## License

This project is open-source and available under the MIT license.

---

**Note:** This interpreter is intended for educational purposes and may not cover all aspects of MIPS assembly language or support all MIPS instructions.
