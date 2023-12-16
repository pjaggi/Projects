#I TO S
org 0x0000
ori $10, $0, 8
lw $2, 0($10)
halt

#I TO S
org 0x0200
ori $11, $0, 8
lw $3, 0($11)
halt

org 0x00F0
cfw 0xF000