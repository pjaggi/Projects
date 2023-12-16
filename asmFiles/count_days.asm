org 0x0000
main:
    ori $29, $0, 0xFFFC #for 29
    ori $16, $0, 0x0016 #day - 22
    ori $1, $0, 0x0008 #month - 8
    ori $2, $0, 0x07E7 #year - 2023

    ori $s1, $0, 4 #constant value of 4

    ori $3, $0, 0x001E #30
    ori $4, $0, 0x0001 #1
    ori $5, $0, 0x016D #365
    ori $6, $0, 0x07D0 #2000

    subu $7, $1, $4 #month - 1
    subu $8, $2, $6 #year - 2000

    sw $8, 0($29) #store year - 2000
    subu $29, $29, $s1
    sw $5, 0($29) #store 365
    subu $29, $29, $s1
    sw $7, 0($29) #store month - 1
    subu $29, $29, $s1
    sw $3, 0($29) #store 30
    subu $29, $29, $s1

    jal multiplication

    add $18, $10, $16 #add day plus result
    ori $10, $0, 0
    #ori $20, $0, 0 #initialize register
    #sw $20, 0($29) #store 20
    #subu $29, $29, $s1
    jal multiplication

    
    #lw $20, 0($29)
    add $18, $18, $10 #result reg being added my temporary result reg
    halt

multiplication:
    lw $12, 8($29) #load the first number off the stack
    addu $29, $29, $s1
    lw $13, 0($29) #load second number off the stack
    addu $29, $29, $s1
    ori $14, $0, 0 #initialize the counter

multiplication_procedure:
    beq $12, $14, end #check to see if first number is same as the counter
    add $10, $10, $13 #keep adding the number to the result
    addi $14, $14, 1
    j multiplication_procedure
    
end:
    jr $31
