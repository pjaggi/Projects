main:
    addi $10, $0, 1
    addi $11, $0, 2

    addi $1, $0, 1
    bne $0, $1, jump

    sw $10, 0($29)
    halt

jump:
    halt
