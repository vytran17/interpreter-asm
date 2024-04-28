.data
LOC:         .word 0x0400     # Location counter initialization
tabToken:    .space 1000      # Space for token table
tabSym:      .space 1000      # Space for symbol table
inBuf:       .space 256       # Input buffer for reading lines
MAX_ENTRIES: .word 100        # Max number of entries in symbol table
prompt:      .asciiz "Enter next line, ending in # \n\n"
tabChar: 
    .word	0x09, 6		# tab
    .word 	0x0a, 6		# line feed
    .word 	0x0d, 6		# carraige return
    .word 	' ', 6
    .word 	'#', 5
    .word 	'$', 4
    .word 	'(', 4 
    .word 	')', 4 
    .word 	'*', 3 
    .word 	'+', 3 
    .word 	',', 4 
    .word 	'-', 3 
    .word 	'.', 4 
    .word 	'/', 3 

    .word 	'0', 1
    .word 	'1', 1 
    .word 	'2', 1 
    .word 	'3', 1 
    .word 	'4', 1 
    .word 	'5', 1 
    .word 	'6', 1 
    .word 	'7', 1 
    .word 	'8', 1 
    .word 	'9', 1 

    .word 	':', 4 

    .word 	'A', 2
    .word 	'B', 2 
    .word 	'C', 2 
    .word 	'D', 2 
    .word 	'E', 2 
    .word 	'F', 2 
    .word 	'G', 2 
    .word 	'H', 2 
    .word 	'I', 2 
    .word 	'J', 2 
    .word 	'K', 2
    .word 	'L', 2 
    .word 	'M', 2 
    .word 	'N', 2 
    .word 	'O', 2 
    .word 	'P', 2 
    .word 	'Q', 2 
    .word 	'R', 2 
    .word 	'S', 2 
    .word 	'T', 2 
    .word 	'U', 2
    .word 	'V', 2 
    .word 	'W', 2 
    .word 	'X', 2 
    .word 	'Y', 2
    .word 	'Z', 2

    .word 	'a', 2 
    .word 	'b', 2 
    .word 	'c', 2 
    .word 	'd', 2 
    .word 	'e', 2 
    .word 	'f', 2 
    .word 	'g', 2 
    .word 	'h', 2 
    .word 	'i', 2 
    .word 	'j', 2 
    .word 	'k', 2
    .word 	'l', 2 
    .word 	'm', 2 
    .word 	'n', 2 
    .word 	'o', 2 
    .word 	'p', 2 
    .word 	'q', 2 
    .word 	'r', 2 
    .word 	's', 2 
    .word 	't', 2 
    .word 	'u', 2
    .word 	'v', 2 
    .word 	'w', 2 
    .word 	'x', 2 
    .word 	'y', 2
    .word 	'z', 2

    .word	0x5c, -1	# '\' used as the end-of-table symbol

.text

main:
    # Load initial values
    la $a0, LOC          # Load address of LOC into $a0
    lw $a1, 0($a0)       # Load value of LOC into $a1
    la $a2, tabToken     # Load base address of tabToken
    la $a3, tabSym       # Load base address of tabSym

nextLine:
    # Read input string, save tokens & types in tabToken
    jal readInputLineAndParseTokens
    li $t0, 0            # Initialize index i for tabToken

    # Load second token's first character
    addi $t1, $a2, 4     # Assuming each token is 4 bytes
    lb $t2, 0($t1)       # Load first byte of second token
    li $t3, ':'          # ASCII value for ':'
    bne $t2, $t3, instruction # Branch if not label definition

labelDef:
    #  VAR is a subroutine to store label in tabSym
    move $a0, $a2        # Pass address of first token
    li $a1, 1            # Status 1 for label definition
    jal VAR             # Call VAR subroutine
    addi $t0, $t0, 8     # Skip label, ‘:’, and instruction
    j chkForVar

instruction:
    addi $t0, $t0, 4     # Skip instruction
    li $t4, 1            # Set paramStart to true

chkForVar:
    # Assuming each token is null-terminated
    add $t5, $a2, $t0    # Address of current token
    lb $t6, 0($t5)       # Load first byte of current token
    li $t7, '#'          # ASCII value for '#'
    beq $t6, $t7, dump   # Branch to dump if end of line

    # Check for token type and paramStart
    # Assuming token type is stored in second byte
    lb $t8, 1($t5)       # Load second byte (token type)
    li $t9, 2            # Type 2 for label
    bne $t4, $zero, chkForComma  # Branch if paramStart is false
    bne $t8, $t9, chkForComma   # Branch if not type 2

    # Save current token
    move $a0, $t5        # Pass address of current token
    li $a1, 0            # Status 0 for label usage
    jal VAR             # Call VAR subroutine
    j nextToken

chkForComma:
    li $t3, ','          # ASCII value for ','
    beq $t6, $t3, setParamStartTrue
    li $t4, 0            # Set paramStart to false
    j nextToken

setParamStartTrue:
    li $t4, 1            # Set paramStart to true
    j nextToken

nextToken:
    addi $t0, $t0, 4     # Move to next token
    j chkForVar

dump:
    # Print symbol table and clear buffers
    jal printSymbolTable
    jal clearInBuf
    jal clearTabToken

    # Update LOC
    addi $a1, $a1, 4
    sw $a1, 0($a0)

    # Jump back to process next line
    j nextLine

##### SECTION FOR SAVING TOKENS INTO TABLE AND PRINTING TABLE
VAR:
    # Save label name
    la $t0, ($a3)               # Load address of next symbol table entry
    move $t1, $a0               # Address of label string

    # Initialize loop counter
    li $t2, 0                   # Loop counter for 8 characters

copyLoop:
    lb $t3, 0($t1)              # Load byte from label string
    sb $t3, 0($t0)              # Store byte in symbol table

    addi $t1, $t1, 1            # Move to next character in label string
    addi $t0, $t0, 1            # Move to next position in symbol table entry
    addi $t2, $t2, 1            # Increment loop counter

    li $t4, 8
    blt $t2, $t4, copyLoop      # Loop until 8 characters are copied

    # Save LOC value (assuming each label is 8 bytes)
    sw $a2, 8($t0)              # Store LOC value at 8-byte offset

    # Save status (assuming each label is 8 bytes and LOC value is 4 bytes)
    sb $a1, 12($t0)             # Store status at 12-byte offset

    # Update tabSym pointer for next entry
    addi $a3, $a3, 13           # Move to next symbol table entry (8+4+1 = 13 bytes per entry)
    jr $ra

printSymbolTable:
    li $t0, 0                  # Index for symbol table entries
    lw $t4, MAX_ENTRIES        # Load maximum number of entries

printLoop:
    bge $t0, $t4, endPrintLoop # Check if maximum number of entries reached

    add $t1, $a3, $t0          # Address of current symbol table entry

    # Print label name
    li $t5, 0                  # Character counter for label
printLabel:
    lb $t6, 0($t1)             # Load byte from label name
    beqz $t6, printLOC         # If zero (end of string), jump to print LOC
    li $v0, 11                 # syscall for print_char
    move $a0, $t6              # Move character to $a0
    syscall
    addi $t1, $t1, 1           # Increment label address
    addi $t5, $t5, 1           # Increment character counter
    li $t7, 8
    blt $t5, $t7, printLabel   # If 8 characters not yet reached, loop

printLOC:
    # Print space before LOC value
    li $v0, 11
    li $a0, ' '                # ASCII space
    syscall

    # Print LOC value in hex
    lw $t2, 8($t1)             # Load LOC value (8-byte offset)
    li $v0, 34                 # syscall for print_hex
    move $a0, $t2
    syscall

    # Print space before status
    li $v0, 11
    li $a0, ' '                # ASCII space
    syscall

    # Print status
    lb $t3, 12($t1)            # Load status (12-byte offset)
    li $v0, 1                  # syscall for print_int
    move $a0, $t3
    syscall

    # Newline after each entry
    li $v0, 11                 # syscall for print_char
    li $a0, 10                 # ASCII newline
    syscall

    addi $t0, $t0, 13          # Move to next entry (13 bytes per entry)
    j printLoop

endPrintLoop:
    jr $ra
 
#### CLEANING UP SECTION 
 
clearInBuf:
    la $a0, inBuf       # Load the address of inBuf into $a0
    li $t0, 0           # Initialize loop counter to 0

clearInBufLoop:
    li $t1, 256         # Total size of inBuf
    beq $t0, $t1, endClearInBuf  # End loop if counter reaches 256
    sb $zero, 0($a0)    # Set current byte to 0
    addi $a0, $a0, 1    # Move to the next byte
    addi $t0, $t0, 1    # Increment loop counter
    j clearInBufLoop

endClearInBuf:
    jr $ra

clearTabToken:
    la $a0, tabToken    # Load the address of tabToken into $a0
    li $t0, 0           # Initialize loop counter to 0

clearTabTokenLoop:
    li $t1, 1000        # Total size of tabToken
    beq $t0, $t1, endClearTabToken  # End loop if counter reaches 1000
    sb $zero, 0($a0)    # Set current byte to 0
    addi $a0, $a0, 1    # Move to the next byte
    addi $t0, $t0, 1    # Increment loop counter
    j clearTabTokenLoop

endClearTabToken:
    jr $ra
    
##### LINE READING AND PARSING TOKENS BELOW
##### NOT DOING STATE MACHINE FROM HW5 JUST SIMPLE PARSE

readInputLineAndParseTokens:
    # Display prompt
    li $v0, 4                 # syscall for print_string
    la $a0, prompt            # Load address of prompt string
    syscall

    # Read input string
    li $v0, 8                 # syscall for read_string
    la $a0, inBuf             # Load address of input buffer
    li $a1, 256               # Maximum number of characters to read
    syscall

    # Parsing logic
    la $t0, inBuf        # Address of inBuf
    la $t1, tabToken     # Address of tabToken
    li $t2, 0            # Token count
    li $t3, 0            # Character count within the current token

parseLoop:
    lb $t4, 0($t0)       # Load byte from inBuf
    beqz $t4, endParse   # End of line, jump to endParse

    # Check for separators (space, comma, colon, newline)
    li $t5, ' '
    beq $t4, $t5, foundSeparator
    li $t5, ','
    beq $t4, $t5, foundSeparator
    li $t5, ':'
    beq $t4, $t5, foundSeparator
    li $t5, '#'
    beq $t4, $t5, foundSeparator

    # If not a separator, check if start of a new token
    beqz $t3, newToken
    j continueToken

foundSeparator:
    sb $zero, 0($t1)     # Null-terminate the token
    addi $t1, $t1, 12    # Move to next token (12 bytes per token)
    li $t3, 0            # Reset character count within token
    j nextChar

newToken:
    move $t1, $t0        # Start of a new token
    li $t3, 1            # Set new token flag

continueToken:
    # Copy the current character to the current token in tabToken
    lb $t5, 0($t0)       # Load the current character from inBuf
    sb $t5, 0($t1)       # Store the character in tabToken

    # Move to the next character in both inBuf and tabToken
    addi $t0, $t0, 1     # Increment inBuf pointer
    addi $t1, $t1, 1     # Increment tabToken pointer

    # Check if we reached the end of the token (maximum length)
    li $t6, 11           # Maximum character count within token (11 + null terminator)
    blt $t3, $t6, parseLoop # If token length is less than maximum, continue parsing
    j foundSeparator    # Otherwise, end the token and find the next one

nextChar:
    addi $t0, $t0, 1     # Move to next character
    j parseLoop

endParse:
    # End of parsing
    jr $ra