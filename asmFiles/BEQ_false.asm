main:
    addi $10, $0, 1
    addi $11, $0, 2

    beq $10, $11, jump
    sw $11, 0($29)
    halt

jump:
    sw $10, 0($29)
    halt
