#M TO M
org 0x0000
ori $10, $0, 8
lw $2, 0($10)
sw $3, 4($10)
halt

org 0x0200
ori $11, $0, 8
lw $4, 0($11)
sw $5, 4($11)
halt

org 0x00F0
cfw 0xF000