org 0x0000
ori $10, $0, 8
sw $2, 0($10) #sw for PrWr?
sw $2, 4($10)
halt

0x0200
ori $11, $0, 8
sw $3, 0($11)
sw $3, 4($11)
halt

org 0x00F0
cfw 0xF000
