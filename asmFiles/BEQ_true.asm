main:
    addi $10, $0, 1
    addi $11, $0, 2

    beq $0, $0, jump
    sw $10, 0($29)
    halt

jump:
    sw $11, 0($29)
    halt
