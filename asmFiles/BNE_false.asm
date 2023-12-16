main:
    addi $10, $0, 1
    addi $11, $0, 2

    bne $0, $0, jump

    #sw $11, 0($29)
    halt

jump:
    sw $10, 0($29)
    halt
