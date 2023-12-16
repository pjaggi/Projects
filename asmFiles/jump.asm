main:
    addi $10, $0, 1
    addi $11, $0, 2
    
    j jump
    
    sw $10, 0($29)
    halt

jump:
    sw $11, 0($29)
    halt
