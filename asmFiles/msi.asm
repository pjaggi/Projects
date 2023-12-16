#I TO M
org 0x0000
ori $10, $0, data1
ori $1, $0, 4
sw $1, 0($10)
ori $4, $0, 4
lw $3, 0($10)
sw $4, 0($10)
halt

org 0x0200
ori $11, $0, data2
ori $2, $0, 4
nop
sw $2, 0($11)
nop
nop
halt

org 0x0400
data1:
    cfw 0xF000
data2:
    cfw 0xDEAD
