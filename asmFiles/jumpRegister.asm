main:
    addi $10, $0, 1
    addi $11, $0, 2

    jal jumpRegister
    
    sw $10, 0($29)
    sw $11, 4($29)
    halt

jumpRegister:
    sw $11, 0($29)
    jr $31
    sw $10, 4($29)
    halt
